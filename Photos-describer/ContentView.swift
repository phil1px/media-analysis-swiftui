import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var isAuthorized: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            if isAuthorized {
                
                NavigationView {
                    VStack {
                        NavigationLink(destination: AudioView(email: email)) {
                            Text("Análise de audio")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        
                        NavigationLink(destination: ImageDescriber(email: email)) {
                            Text("Análise de Imagem")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .navigationTitle("Selecione o tipo de Análise")
                }
                
            } else {
                VStack {
                    TextField("Entre com seu email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    Button("Email") {
                        authenticateUser()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                .navigationTitle("Login")
            }
        }
    }
    
    func authenticateUser() {
        guard !email.isEmpty else {
            errorMessage = "Por favor, entre com um email valido."
            return
        }
        
        let serverURL = URL(string: "http://192.168.1.98:3000/authenticate")!
        var request = URLRequest(url: serverURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = ["email": email]
        let jsonData = try? JSONSerialization.data(withJSONObject: jsonBody)
        
        URLSession.shared.uploadTask(with: request, from: jsonData) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = "Sem autorização para usar essa aplicação."
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isAuthorized = true
            }
        }.resume()
    }
}
