import SwiftUI

struct AuthorizationView: View {
    @State private var nickname = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoggedIn {
                Button("Logout", action: logout)
            } else {
                Spacer()
                
                Text("Scrabble Game")
                    .font(.title)
                
                Spacer()
                
                VStack {
                    TextField("Nickname", text: $nickname)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                    
                    Button("Register", action: register)
                    
                    Button("Login", action: login)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage).foregroundColor(.red)
                    }
                }
                .onAppear {
                    if AuthService.shared.getToken() != nil {
                        isLoggedIn = true
                    }
                }
                .background(.white)
                .cornerRadius(20)
                .padding()
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
        }
        .padding()
    }
    
    func register() {
        AuthService.shared.register(nickname: nickname, password: password) { result in
            switch result {
            case .success:
                login()
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func login() {
        AuthService.shared.login(nickname: nickname, password: password) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    isLoggedIn = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func logout() {
        AuthService.shared.logout()
        isLoggedIn = false
    }
}

#Preview {
    AuthorizationView()
}
