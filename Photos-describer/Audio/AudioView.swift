import SwiftUI
import AVFoundation
import Combine

struct AudioView: View {
    let email: String 
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var analysisResult: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if audioRecorder.isRecording {
                Text("Gravando...")
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding(.bottom)
                
                AudioWaveView(amplitude: audioRecorder.amplitude)
                    .frame(height: 100)
                    .padding(.bottom)
                
                Button("Parar Gravação") {
                    audioRecorder.stopRecording()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("Iniciar Gravação") {
                    audioRecorder.startRecording()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Button("Upload e Análise") {
                uploadAndAnalyzeAudio()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(audioRecorder.audioFileURL == nil)
            
            Text("Resultado da análise:")
                .font(.headline)
                .padding(.top)
            
            ScrollView {
                Text(analysisResult)
                    .padding()
            }
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .alert(isPresented: Binding<Bool>(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Alert(title: Text("Erro"), message: Text(errorMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }
    
    private func uploadAndAnalyzeAudio() {
        guard let audioFileURL = audioRecorder.audioFileURL else {
            print("No audio file available")
            return
        }
        
        let serverURL = URL(string: "http://192.168.1.98:3000/analyze-audio")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let data = createMultipartFormData(fileURL: audioFileURL, boundary: boundary, email: email)
        
        URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error {
                print("Upload error: \(error)")
                return
            }
            
            guard let data else {
                print("No data received")
                return
            }
            
            do {
                let analysis = try JSONDecoder().decode(AnalysisResponse.self, from: data)
                DispatchQueue.main.async {
                    self.analysisResult = analysis.transcribedText.text
                }
            } catch {
                print("Failed to decode JSON response: \(error)")
            }
        }.resume()
    }
    
    private func createMultipartFormData(fileURL: URL, boundary: String, email: String) -> Data {
        var data = Data()
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"email\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(email)\r\n".data(using: .utf8)!)
        
        let filename = fileURL.lastPathComponent
        let mimetype = "audio/m4a"
        let fileData = try! Data(contentsOf: fileURL)
        
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        data.append(fileData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
}
