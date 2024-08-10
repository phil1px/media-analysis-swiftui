import SwiftUI
import UIKit

// ImagePicker component for selecting images
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var completion: (Data) -> Void
    var sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, completion: completion)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        var completion: (Data) -> Void
        
        init(_ parent: ImagePicker, completion: @escaping (Data) -> Void) {
            self.parent = parent
            self.completion = completion
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                let optimizedData = uiImage.optimizeForUpload(maxWidth: 4096, maxFileSizeMB: 19)
                if let data = optimizedData {
                    parent.image = UIImage(data: data)
                    completion(data)
                }
            }
            picker.dismiss(animated: true)
        }
    }
}

extension UIImage {
    func optimizeForUpload(maxWidth: CGFloat, maxFileSizeMB: Double) -> Data? {
        var currentQuality: CGFloat = 1.0
        var imageData = self.resized(toWidth: maxWidth)?.compressed(toQuality: currentQuality)
        
        while let data = imageData, Double(data.count) / (1024 * 1024) > maxFileSizeMB {
            currentQuality -= 0.1
            imageData = self.resized(toWidth: maxWidth)?.compressed(toQuality: currentQuality)
            if currentQuality <= 0.1 {
                break
            }
        }
        
        return imageData
    }
    
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width / size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func compressed(toQuality quality: CGFloat) -> Data? {
        return jpegData(compressionQuality: quality)
    }
}
