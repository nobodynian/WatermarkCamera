import SwiftUI

struct PhotoPreviewView: View {
    let originalImage: UIImage
    @Binding var watermarkDate: Date
    @Binding var locationText: String
    @Binding var customNote: String
    var onSave: (UIImage) -> Void
    var onDismiss: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Watermarked image preview
                Image(uiImage: renderWatermarkedImage())
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)

                // Settings panel
                VStack(spacing: 12) {
                    DatePicker("水印日期时间", selection: $watermarkDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(.horizontal)

                    TextField("地点（可选）", text: $locationText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    TextField("备注（可选）", text: $customNote)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    HStack(spacing: 16) {
                        Button("取消") {
                            onDismiss()
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)

                        Button("保存到相册") {
                            let watermarked = renderWatermarkedImage()
                            onSave(watermarked)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 8)
                }
                .padding(.top, 12)
                .background(Color(UIColor.secondarySystemBackground))
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("预览")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func renderWatermarkedImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: originalImage.size)
        return renderer.image { context in
            // Draw original image
            originalImage.draw(in: CGRect(origin: .zero, size: originalImage.size))

            // Watermark info
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateStr = formatter.string(from: watermarkDate)

            // Build watermark lines
            var lines: [String] = [dateStr]
            if !locationText.isEmpty {
                lines.append(locationText)
            }
            if !customNote.isEmpty {
                lines.append(customNote)
            }

            let fullText = lines.joined(separator: " | ")
            let fontSize: CGFloat = originalImage.size.width * 0.03
            let font = UIFont.systemFont(ofSize: max(fontSize, 12), weight: .medium)

            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
                .shadow: NSShadow(
                    shadowColor: UIColor.black.withAlphaComponent(0.6),
                    shadowOffset: CGSize(width: 1, height: 1),
                    shadowBlurRadius: 3
                )
            ]

            let textWidth = (fullText as NSString).size(withAttributes: textAttributes).width
            let padding: CGFloat = originalImage.size.width * 0.03
            let lineHeight = fontSize * 1.5
            let labelHeight = lineHeight * CGFloat(lines.count) + padding * 2
            let labelWidth = max(textWidth + padding * 2, originalImage.size.width * 0.4)
            let labelX: CGFloat = originalImage.size.width - labelWidth - padding
            let labelY: CGFloat = originalImage.size.height - labelHeight - padding

            // Draw background rect
            let bgRect = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            UIColor.black.withAlphaComponent(0.45).setFill()
            let path = UIBezierPath(roundedRect: bgRect, cornerRadius: padding * 0.5)
            path.fill()

            // Draw text lines
            for (i, line) in lines.enumerated() {
                let y = labelY + padding + lineHeight * CGFloat(i) + lineHeight * 0.7
                let rect = CGRect(x: labelX + padding, y: y - fontSize, width: labelWidth - padding * 2, height: fontSize * 1.5)
                (line as NSString).draw(in: rect, withAttributes: textAttributes)
            }
        }
    }
}
