import SwiftUI

struct MainView: View {
    @State private var capturedImage: UIImage?
    @State private var showCamera = false
    @State private var showPhotoPreview = false
    @State private var watermarkDate = Date()
    @State private var locationText: String = ""
    @State private var customNote: String = ""
    @State private var showSaveAlert = false
    @State private var alertMessage: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        Text("点击下方按钮拍照")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemGroupedBackground))
                }

                VStack(spacing: 12) {
                    if showCamera {
                        CameraView(
                            capturedImage: $capturedImage,
                            watermarkText: .constant(""),
                            watermarkDate: $watermarkDate,
                            showPhotoPreview: $showPhotoPreview,
                            locationText: $locationText
                        )
                        .frame(height: 0)
                        .opacity(0)
                    }

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
                            showPhotoPreview = true
                        } label: {
                            Label("编辑水印并保存", systemImage: "text.badge.plus")
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
            .fullScreenCover(isPresented: $showPhotoPreview) {
                if let image = capturedImage {
                    PhotoPreviewView(
                        originalImage: image,
                        watermarkDate: $watermarkDate,
                        locationText: $locationText,
                        customNote: $customNote,
                        onSave: { watermarked in
                            saveToPhotoLibrary(image: watermarked)
                            showPhotoPreview = false
                        },
                        onDismiss: {
                            showPhotoPreview = false
                        }
                    )
                }
            }
        }
    }

    private func saveToPhotoLibrary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        alertMessage = "已保存到相册！"
        showSaveAlert = true
    }
}
