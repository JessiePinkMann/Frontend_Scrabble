import Foundation


class WordService {
    static let shared = WordService()
    let apiUrl = AppConfig.apiUrl
    let apiKey = AppConfig.apiKey
    private let userDefaultsTokenKey = "authToken"
    private let userDefaultsNicknameKey = "nickname"
    private let userDefaultsIdKey = "id"

    func submitWordToServer(word: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = URL(string: "\(apiUrl)moves/checkWord/\(word)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(AppConfig.apiKey, forHTTPHeaderField: "ApiKey")
        request.addValue(AuthService.shared.getToken() ?? "", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse)
                if httpResponse.statusCode == 200 {
                    completion(.success(()))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Wrong word"])))
                }
            } else {
                let errorMessage = "Unexpected response from server"
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }.resume()
    }
}
