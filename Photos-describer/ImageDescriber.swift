import SwiftUI

struct ImageDescriber: View {
    @State private var image: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var imageDescription = "Selecione uma imagem para obter titulo, descrição e preço sugerido."

    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            } else {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(height: 300)
            }
            
            Text(imageDescription)
                .padding()
                .multilineTextAlignment(.center)
            
            Button("Selecione uma imagem") {
                isShowingImagePicker = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(image: $image, completion: uploadImage)
        }
    }
    
    func uploadImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let serverURL = "http://192.168.1.98:3000/describe"
        let url = URL(string: serverURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()

        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            
            guard let responseData = responseData else {
                print("No response data received")
                return
            }

            if let responseDict = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
               let description = responseDict["description"] as? String {
                DispatchQueue.main.async {
                    self.imageDescription = description
                }
            }
        }
        
        task.resume()
    }
}
