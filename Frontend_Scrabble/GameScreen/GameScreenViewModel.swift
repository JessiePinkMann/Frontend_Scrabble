import SwiftUI
import Combine

class GameScreenViewModel: ObservableObject {
    @Published var players: [User] = []
    @Published var isLoading = true
    @Published var isAdmin = false
    @Published var room: GameRoom?

    private let baseURL = AppConfig.apiUrl
    private let apiKey = AppConfig.apiKey
    private var jwtToken: String
    private var gamerId: String
    private var roomId: UUID
    @Published var isAdmin: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    init(roomId: UUID) {
        self.jwtToken = AuthService.shared.getToken() ?? ""
        self.gamerId = AuthService.shared.getId() ?? ""
        self.roomId = roomId
        fetchRoomDetails()
        fetchPlayers()
        startPolling()
    }
    
    func fetchRoomDetails() {
        guard let url = URL(string: "\(baseURL)gameRooms/\(roomId)") else {
            print("Invalid URL for fetching room details")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: GameRoom.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching room details: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] room in
                self?.room = room
                self?.checkIfAdmin()
            })
            .store(in: &cancellables)
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
        
    private func startPolling() {
        timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect().sink { [weak self] _ in
            self?.fetchPlayers()
        }
    }
    
    private func checkIfAdmin() {
        guard let adminNickname = room?.adminNickname else { return }
        guard let currentUserNickname = AuthService.shared.getNickname() else { return }
        isAdmin = adminNickname == currentUserNickname
    }

    func makePlayerAdmin(player: User) {
        guard let url = URL(string: "\(baseURL)gameRooms/\(roomId)/changeAdmin/\(player.nickName)") else {
            print("Invalid URL for changing admin")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error changing admin: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchRoomDetails()
            })
            .store(in: &cancellables)
    }

    func kickPlayer(player: User) {
        guard let url = URL(string: "\(baseURL)gamersIntoRoom/deleteGamer/\(player.id)/withRoom/\(roomId)") else {
            print("Invalid URL for kicking player")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue("\(jwtToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error kicking player: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchPlayers()
            })
            .store(in: &cancellables)
    }
    
    deinit {
        timer?.cancel()
    }
}
