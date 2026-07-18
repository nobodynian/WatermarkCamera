import SwiftUI
import Photos

struct MainView: View {
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var showEditView = false
    @State private var watermarkDate = Date()
    @State private var locationText: String = ""
    @State private var workContent: String = ""
    @State private var weatherText: String = ""
    @State private var showSaveAlert = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 预览区域
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("点击下方按钮拍照")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                }

                // 操作按钮区域
                VStack(spacing: 12) {
                    Button {
                        showCamera = true
                    } label: {
                        Label("拍照", systemImage: "camera.fill")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.horizontal)

                    if capturedImage != nil {
                        Button {
                            guard capturedImage != nil else { return }
                            showEditView = true
                        } label: {
                            Label("编辑水印并保存", systemImage: "doc.text.viewfinder")
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 16)
                .background(Color(UIColor.secondarySystemBackground))
            }
            .navigationTitle("水印相机")
            .alert("提示", isPresented: $showSaveAlert) {
                Button("好", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(
                    capturedImage: $capturedImage,
                    watermarkDate: $watermarkDate,
                    locationText: $locationText,
                    workContent: $workContent,
                    weatherText: $weatherText,
                    isPresented: $showCamera
                )
            }
            .fullScreenCover(isPresented: $showEditView) {
                WatermarkEditView(
                    originalImage: capturedImage ?? UIImage(),
                    watermarkDate: $watermarkDate,
                    locationText: $locationText,
                    workContent: $workContent,
                    weatherText: $weatherText,
                    onSave: { watermarked in
                        saveToPhotoLibrary(image: watermarked)
                        showEditView = false
                    },
                    onDismiss: {
                        showEditView = false
                    }
                )
            }
        }
    }

    private func saveToPhotoLibrary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        DispatchQueue.main.async {
            alertMessage = "已保存到相册！"
            showSaveAlert = true
        }
    }
}
