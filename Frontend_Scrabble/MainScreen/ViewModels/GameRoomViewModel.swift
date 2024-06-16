//
//  GameRoomViewModel.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI
import Combine

class GameRoomViewModel: ObservableObject {
    @Published var gameRooms: [GameRoom] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let baseURL = AppConfig.apiUrl + "gameRooms"
    private let apiKey = AppConfig.apiKey
    private var jwtToken: String
    private var adminNickname: String
    
    init() {
        self.jwtToken = AuthService.shared.getToken() ?? ""
        self.adminNickname = AuthService.shared.getNickname() ?? ""
        print(self.jwtToken, self.adminNickname)
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
                self?.gameRooms.append(createdRoom)
                completion()
            })
            .store(in: &cancellables)
    }
}
