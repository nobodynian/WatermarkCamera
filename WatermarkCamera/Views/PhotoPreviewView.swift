import SwiftUI
import UIKit

struct WatermarkEditView: View {
    let originalImage: UIImage
    @Binding var watermarkDate: Date
    @Binding var locationText: String
    @Binding var workContent: String
    @Binding var weatherText: String
    var onSave: (UIImage) -> Void
    var onDismiss: () -> Void

    // 渲染缓存 - 避免每次 body 重算都渲染大图
    @State private var renderedImage: UIImage? = nil
    @State private var renderTask: DispatchWorkItem?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 水印预览（缓存结果，打字时不重新渲染）
                if let rendered = renderedImage {
                    Image(uiImage: rendered)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black)
                } else {
                    Color.black
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // 编辑面板
                ScrollView {
                    VStack(spacing: 14) {
                        // 拍摄时间
                        VStack(alignment: .leading, spacing: 4) {
                            Text("拍摄时间")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            DatePicker("", selection: $watermarkDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(.horizontal)

                        // 工作内容
                        VStack(alignment: .leading, spacing: 4) {
                            Text("工作内容")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("例如：设备巡检、现场记录等", text: $workContent)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: workContent) { _ in
                                    scheduleRender()
                                }
                        }
                        .padding(.horizontal)

                        // 天气（自动获取，可手动修改）
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("天气")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button("刷新") {
                                    LocationWeatherService.shared.startUpdating()
                                    // 等 2 秒后更新预览
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                        weatherText = LocationWeatherService.shared.weatherText
                                        locationText = LocationWeatherService.shared.locationText
                                        renderNow()
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                            TextField("例如：晴 28\u{00B0}C", text: $weatherText)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: weatherText) { _ in
                                    scheduleRender()
                                }
                        }
                        .padding(.horizontal)

                        // 地点（自动获取，可手动修改）
                        VStack(alignment: .leading, spacing: 4) {
                            Text("地点（自动获取，可修改）")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            TextField("例如：XX市·XX项目部", text: $locationText)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: locationText) { _ in
                                    scheduleRender()
                                }
                        }
                        .padding(.horizontal)

                        // 操作按钮
                        HStack(spacing: 16) {
                            Button("取消") {
                                onDismiss()
                            }
                            .buttonStyle(.bordered)
                            .tint(.gray)
                            .frame(maxWidth: .infinity)

                            Button("保存到相册") {
                                renderNow()
                                if let img = renderedImage {
                                    onSave(img)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                }
                .background(Color(UIColor.secondarySystemBackground))
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("编辑水印")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("关闭") { onDismiss() }
                }
            }
            .onAppear {
                // 自动获取位置和天气
                LocationWeatherService.shared.requestPermission()
                LocationWeatherService.shared.startUpdating()
                // 延迟 1.5 秒等待数据返回后同步并首次渲染
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    let service = LocationWeatherService.shared
                    if !service.weatherText.isEmpty {
                        weatherText = service.weatherText
                    }
                    if !service.locationText.isEmpty {
                        locationText = service.locationText
                    }
                    renderNow()
                }
                // 也立即渲染一版
                renderNow()
            }
        }
    }

    // 防抖渲染：打字停止 500ms 后才重新渲染预览图
    private func scheduleRender() {
        renderTask?.cancel()
        let task = DispatchWorkItem { renderNow() }
        renderTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: task)
    }

    // 立即渲染
    private func renderNow() {
        renderTask?.cancel()
        renderedImage = WatermarkRenderer.render(
            image: originalImage,
            date: watermarkDate,
            location: locationText,
            workContent: workContent,
            weather: weatherText
        )
    }
}

// ========== 卡片式水印渲染器 ==========
struct WatermarkRenderer {
    static func render(image: UIImage, date: Date, location: String, workContent: String, weather: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))

            let scale = image.size.width / 414.0

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd HH:mm"
            let dateStr = formatter.string(from: date)

            let cardWidth: CGFloat = image.size.width * 0.85
            let headerHeight: CGFloat = 36 * scale
            let rowHeight: CGFloat = 30 * scale
            let padding: CGFloat = 12 * scale
            let labelPadding: CGFloat = 10 * scale

            var rowCount = 3
            if !location.isEmpty { rowCount += 1 }
            let bodyHeight = rowHeight * CGFloat(rowCount) + padding * 2 + (CGFloat(rowCount) - 1) * 2 * scale
            let cardHeight = headerHeight + bodyHeight

            let cardX = (image.size.width - cardWidth) / 2
            let cardY = image.size.height * 0.05

            // 阴影
            let shadowRect = CGRect(x: cardX + 2 * scale, y: cardY + 2 * scale, width: cardWidth, height: cardHeight)
            UIColor.black.withAlphaComponent(0.15).setFill()
            UIBezierPath(roundedRect: shadowRect, cornerRadius: 10 * scale).fill()

            // 卡片背景
            let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
            UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: cardRect, cornerRadius: 10 * scale).fill()

            UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0).setStroke()
            UIBezierPath(roundedRect: cardRect, cornerRadius: 10 * scale).stroke()

            // 头部
            let headerRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: headerHeight)
            let headerColor = UIColor(red: 0.32, green: 0.35, blue: 0.58, alpha: 1.0)
            headerColor.setFill()
            let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: 10 * scale)
            headerPath.addClip()
            headerColor.setFill()
            UIRectFill(headerRect)
            UIRectFill(CGRect(x: cardX, y: cardY + headerHeight - 10 * scale, width: cardWidth, height: 10 * scale))

            // 黄色圆点
            let dotRadius: CGFloat = 4 * scale
            let dotCenter = CGPoint(x: cardX + padding + dotRadius, y: cardY + headerHeight / 2)
            UIColor(red: 0.95, green: 0.75, blue: 0.2, alpha: 1.0).setFill()
            UIBezierPath(ovalIn: CGRect(x: dotCenter.x - dotRadius, y: dotCenter.y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)).fill()

            // 标题
            let titleFont = UIFont.systemFont(ofSize: 15 * scale, weight: .bold)
            let titleText = "工作记录" as NSString
            let titleSize = titleText.size(withAttributes: [.font: titleFont])
            titleText.draw(at: CGPoint(x: dotCenter.x + dotRadius + 8 * scale, y: cardY + (headerHeight - titleSize.height) / 2), withAttributes: [
                .font: titleFont,
                .foregroundColor: UIColor.white
            ])

            // 内容行
            let labelFont = UIFont.systemFont(ofSize: 12 * scale, weight: .regular)
            let valueFont = UIFont.systemFont(ofSize: 12 * scale, weight: .medium)
            let labelColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
            let valueColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

            let labelWidth: CGFloat = 70 * scale
            let colonWidth: CGFloat = 16 * scale
            let contentX = cardX + padding + labelWidth + colonWidth + labelPadding
            let contentWidth = cardWidth - (contentX - cardX) - padding

            let rightAlign = { () -> NSMutableParagraphStyle in
                let p = NSMutableParagraphStyle()
                p.alignment = .right
                return p
            }()

            func drawRow(y: CGFloat, label: String, value: String) {
                let labelText = (label + "\u{FF1A}") as NSString
                labelText.draw(in: CGRect(x: cardX + padding, y: y, width: labelWidth + colonWidth, height: rowHeight), withAttributes: [
                    .font: labelFont,
                    .foregroundColor: labelColor,
                    .paragraphStyle: rightAlign
                ])
                let valueNSString = value as NSString
                valueNSString.draw(in: CGRect(x: contentX, y: y, width: contentWidth, height: rowHeight), withAttributes: [
                    .font: valueFont,
                    .foregroundColor: valueColor
                ])
            }

            var currentY = cardY + headerHeight + padding
            drawRow(y: currentY, label: "工作内容", value: workContent.isEmpty ? "未填写" : workContent)
            currentY += rowHeight + 2 * scale
            drawRow(y: currentY, label: "拍摄时间", value: dateStr)
            currentY += rowHeight + 2 * scale
            drawRow(y: currentY, label: "天气", value: weather.isEmpty ? "未知" : weather)
            currentY += rowHeight + 2 * scale
            if !location.isEmpty {
                drawRow(y: currentY, label: "地点", value: location)
            }
        }
    }
}
