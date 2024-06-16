import SwiftUI
import Combine

class GameScreenViewModel: ObservableObject {
    @Published var players: [User] = []
    @Published var isLoading = true

    private let baseURL = AppConfig.apiUrl
    private let apiKey = AppConfig.apiKey
    private var jwtToken: String
    private var gamerId: String
    private var roomId: UUID
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    init(roomId: UUID) {
        self.jwtToken = AuthService.shared.getToken() ?? ""
        self.gamerId = AuthService.shared.getId() ?? ""
        self.roomId = roomId
//        fetchPlayers()
        startPolling()
    }
    
    func fetchPlayers() {
        guard let url = URL(string: "\(baseURL)gamersIntoRoom/roomId/\(roomId)/gamersIds") else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [String].self, decoder: JSONDecoder())
            .flatMap { playerIds -> AnyPublisher<[User], Error> in
                let publishers = playerIds.map { self.fetchUserDetails(for: $0) }
                return Publishers.MergeMany(publishers).collect().eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching players: \(error.localizedDescription)")
                }
                self.isLoading = false
            }, receiveValue: { [weak self] players in
                self?.players = players
                self?.isLoading = false
                print(self?.players)
            })
            .store(in: &cancellables)
        
        
    }
    
    private func fetchUserDetails(for userId: String) -> AnyPublisher<User, Error> {
        guard let url = URL(string: "\(baseURL)auth/getUserById/\(userId)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: User.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
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
    
    private func startPolling() {
        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.fetchPlayers()
        }
    }
    
    deinit {
        timer?.cancel()
    }
}
