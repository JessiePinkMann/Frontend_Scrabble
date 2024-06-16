import SwiftUI
import Combine

class GameScreenViewModel: ObservableObject {
    private let baseURL = AppConfig.apiUrl + "gameRooms"
    private let apiKey = AppConfig.apiKey
    private var jwtToken: String
    private var gamerId: String
    private var roomId: UUID
    
    private var cancellables = Set<AnyCancellable>()
    
    init(roomId: UUID) {
        self.jwtToken = AuthService.shared.getToken() ?? ""
        self.gamerId = AuthService.shared.getId() ?? ""
        self.roomId = roomId
    }
    
    func leaveRoom(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(baseURL)/\(roomId)/leaveRoom") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error leaving room: \(error)")
                }
            }, receiveValue: { _ in
                completion()
            })
            .store(in: &cancellables)
    }
}
