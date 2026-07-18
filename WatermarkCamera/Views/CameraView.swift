import SwiftUI
import AVFoundation
import CoreLocation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var watermarkText: String
    @Binding var watermarkDate: Date
    @Binding var showPhotoPreview: Bool
    @Binding var locationText: String

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(capturedImage: $capturedImage,
                     watermarkText: $watermarkText,
                     watermarkDate: $watermarkDate,
                     showPhotoPreview: $showPhotoPreview,
                     locationText: $locationText)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var capturedImage: Binding<UIImage?>
        var watermarkText: Binding<String>
        var watermarkDate: Binding<Date>
        var showPhotoPreview: Binding<Bool>
        var locationText: Binding<String>

        init(capturedImage: Binding<UIImage?>,
             watermarkText: Binding<String>,
             watermarkDate: Binding<Date>,
             showPhotoPreview: Binding<Bool>,
             locationText: Binding<String>) {
            self.capturedImage = capturedImage
            self.watermarkText = watermarkText
            self.watermarkDate = watermarkDate
            self.showPhotoPreview = showPhotoPreview
            self.locationText = locationText
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                capturedImage.wrappedValue = image
                showPhotoPreview.wrappedValue = true
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
