import SwiftUI
import Combine

class GameRoomViewModel: ObservableObject {
    @Published var gameRooms: [GameRoom] = []
    @Published var newRoomId: UUID?
    @Published var navigateToGameScreen = false
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = AppConfig.apiUrl + "gameRooms"
    private let apiKey = AppConfig.apiKey
    private var jwtToken: String
    private var adminNickname: String
    
    init() {
        self.jwtToken = AuthService.shared.getToken() ?? ""
        self.adminNickname = AuthService.shared.getNickname() ?? ""
        fetchGameRooms()
    }
    
    func fetchGameRooms() {
        guard let url = URL(string: baseURL) else { return }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [GameRoom].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching game rooms: \(error)")
                }
            }, receiveValue: { [weak self] gameRooms in
                self?.gameRooms = gameRooms
            })
            .store(in: &cancellables)
    }
    
    func createGameRoom(roomCode: String, currentNumberOfChips: Int, completion: @escaping () -> Void) {
        guard let url = URL(string: baseURL) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let newRoom = GameRoom(id: nil, adminNickname: adminNickname, roomCode: roomCode, gameStatus: "Not Started", currentNumberOfChips: currentNumberOfChips)
        
        do {
            request.httpBody = try JSONEncoder().encode(newRoom)
        } catch {
            print("Error encoding game room: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: GameRoom.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error creating game room: \(error)")
                }
            }, receiveValue: { [weak self] createdRoom in
                print("Game room created with ID: \(createdRoom.id?.uuidString ?? "unknown")")
                self?.newRoomId = createdRoom.id
                self?.gameRooms.append(createdRoom)
                self?.addGamerToRoom(roomId: createdRoom.id, roomCode: roomCode) {
                    print("Gamer added to room with ID: \(createdRoom.id?.uuidString ?? "unknown")")
                    completion()
                }
            })
            .store(in: &cancellables)
    }
    
    func addGamerToRoom(roomId: UUID?, roomCode: String, completion: @escaping () -> Void) {
        guard let roomId = roomId, let gamerIdString = AuthService.shared.getId(), let gamerId = UUID(uuidString: gamerIdString) else {
            print("Failed to get gamerId from UserDefaults")
            return
        }
        
        let url = URL(string: "\(AppConfig.apiUrl)gamersIntoRoom")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let gamerIntoRoom = GamerIntoRoom(gamerId: gamerId, roomId: roomId, enteredPassword: roomCode)
        
        do {
            let jsonData = try JSONEncoder().encode(gamerIntoRoom)
            request.httpBody = jsonData
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("GamerIntoRoom JSON: \(jsonString)")
            }
        } catch {
            print("Error encoding gamer into room: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                print("HTTP Status Code: \(response.statusCode)")
                print("Response Headers: \(response.allHeaderFields)")
                return output.data
            }
            .map { String(data: $0, encoding: .utf8) ?? "No response body" }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error adding gamer to room: \(error)")
                }
            }, receiveValue: { responseBody in
                print("Response Body: \(responseBody)")
                completion()
            })
            .store(in: &cancellables)
    }
}
