import Foundation


class AuthService {
    static let shared = AuthService()
    private let baseURL = AppConfig.apiUrl + "auth"
    private let userDefaultsTokenKey = "authToken"

    func register(nickname: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(AppConfig.apiKey, forHTTPHeaderField: "ApiKey")
        request.httpBody = try? JSONEncoder().encode(["nickName": nickname, "password": password])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    completion(.success(()))
                } else {
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            let errorMessage = errorResponse.reason
                            completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    }
                }
            } else {
                let errorMessage = "Unexpected response from server"
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }.resume()
    }

    func login(nickname: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(baseURL)/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(AppConfig.apiKey, forHTTPHeaderField: "ApiKey")
        request.httpBody = try? JSONEncoder().encode(["nickName": nickname, "password": password])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let data = data, let token = String(data: data, encoding: .utf8) else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                        return
                    }
                    self.saveToken(token)
                    completion(.success(()))
                } else {
                    if let data = data {
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            let errorMessage = errorResponse.reason
                            completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                        } catch {
                            completion(.failure(error))
                        }
                    } else {
                        let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    }
                }
            } else {
                let errorMessage = "Unexpected response from server"
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
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
