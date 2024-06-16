import SwiftUI
import Combine

class GameScreenViewModel: ObservableObject {
    private let baseURL = AppConfig.apiUrl + "gameRooms"
    private let apiKey = AppConfig.apiKey
    private var jwtToken: String
    private var gamerId: String
    private var roomId: UUID
    @Published var isAdmin: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(roomId: UUID) {
        self.jwtToken = AuthService.shared.getToken() ?? ""
        self.gamerId = AuthService.shared.getId() ?? ""
        self.roomId = roomId
        checkIfAdmin()
    }
    
    func leaveRoom(completion: @escaping () -> Void) {
        guard let gamerUUID = UUID(uuidString: gamerId) else { return }
        guard let url = URL(string: "\(AppConfig.apiUrl)gamersIntoRoom/deleteGamer/\(gamerUUID)/withRoom/\(roomId)") else { return }
        
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
    
    func checkIfAdmin() {
        guard let url = URL(string: "\(AppConfig.apiUrl)gameRooms/\(roomId)/admin") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching admin: \(error)")
                }
            }, receiveValue: { [weak self] user in
                self?.isAdmin = (user.id?.uuidString == self?.gamerId)
            })
            .store(in: &cancellables)
    }
    
    func deleteRoom(completion: @escaping () -> Void) {
        guard let url = URL(string: "\(AppConfig.apiUrl)gamersIntoRoom/deleteRoomWithId/\(roomId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error deleting room: \(error)")
                }
            }, receiveValue: { _ in
                completion()
            })
            .store(in: &cancellables)
    }
}
