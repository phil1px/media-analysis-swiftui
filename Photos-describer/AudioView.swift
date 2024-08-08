import SwiftUI
import AVFoundation

struct AudioView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var analysisResult: String = ""

    var body: some View {
        VStack {
            if audioRecorder.isRecording {
                Button("Stop Recording") {
                    audioRecorder.stopRecording()
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("Start Recording") {
                    audioRecorder.startRecording()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            Button("Upload and Analyze") {
                uploadAndAnalyzeAudio()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(audioRecorder.audioFileURL == nil)

            Text("Analysis Result:")
                .font(.headline)
                .padding(.top)

            ScrollView {
                Text(analysisResult)
                    .padding()
            }
        }
        .padding()
    }

    private func uploadAndAnalyzeAudio() {
        guard let audioFileURL = audioRecorder.audioFileURL else {
            print("No audio file available")
            return
        }

//        let serverURL = URL(string: "http://localhost:3000/analyze-audio")!
        let serverURL = URL(string: "http://192.168.1.98:3000/analyze-audio")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let data = createMultipartFormData(fileURL: audioFileURL, boundary: boundary)

        URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if let error = error {
                print("Upload error: \(error)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            if let analysis = try? JSONDecoder().decode(AnalysisResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.analysisResult = analysis.analysis
                }
            }
        }.resume()
    }

    private func createMultipartFormData(fileURL: URL, boundary: String) -> Data {
        var data = Data()

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

struct AnalysisResponse: Decodable {
    let analysis: String
}
