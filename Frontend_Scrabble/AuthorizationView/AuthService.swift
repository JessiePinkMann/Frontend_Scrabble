import Foundation

struct AuthResponse: Codable {
    let token: String
}

class AuthService {
    static let shared = AuthService()
    private let apiKey = "8463ad36-f7fc-41d0-9d22-d7624562bc30"
    private let baseURL = "http://127.0.0.1:8080/auth"
    private let userDefaultsTokenKey = "authToken"

    func register(nickname: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.httpBody = try? JSONEncoder().encode(["nickName": nickname, "password": password])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("register: ", request.httpBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }.resume()
    }

    func login(nickname: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.httpBody = try? JSONEncoder().encode(["nickName": nickname, "password": password])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        print("login: ", request.httpBody)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self.saveToken(authResponse.token)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: userDefaultsTokenKey)
    }
    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: userDefaultsTokenKey)
    }
    
    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: userDefaultsTokenKey)
    }
}
