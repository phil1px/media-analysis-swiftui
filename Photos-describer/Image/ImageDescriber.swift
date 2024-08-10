import SwiftUI
import Foundation
import UIKit

struct ImageDescriber: View {
    let email: String
    @State private var image: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var imageDescription = "Selecione uma imagem para obter título, descrição e preço sugerido."
    
    var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 300)
            }
            
            ScrollView {
                Text(imageDescription)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            
            HStack {
                Button("Tirar Foto") {
                    sourceType = .camera
                    isShowingImagePicker = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                
                Button("Selecionar da Biblioteca") {
                    sourceType = .photoLibrary
                    isShowingImagePicker = true
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image, completion: uploadImage, sourceType: sourceType)
        }
    }
    
    func uploadImage(_ imageData: Data) {
        let serverURL = "http://192.168.1.98:3000/describe"
        guard let url = URL(string: serverURL) else {
            print("Invalid server URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(email)\r\n".data(using: .utf8)!)
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }
            
            guard let responseData else {
                print("No response data received")
                return
            }
            
            do {
                if let responseDict = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let description = responseDict["description"] as? String {
                    DispatchQueue.main.async {
                        self.imageDescription = description
                    }
                }
            } catch {
                print("Error parsing response data: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}

struct ImageDescriber_Previews: PreviewProvider {
    static var previews: some View {
        ImageDescriber(email: "")
    }
}
