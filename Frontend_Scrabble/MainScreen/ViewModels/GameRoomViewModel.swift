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
    @Published var navigateToGameScreen = false
    var newRoomId: UUID?
    
    private var cancellables = Set<AnyCancellable>()
    
    private let baseURL = "http://127.0.0.1:8080/gameRooms"
    private let apiKey = "6ef0b419-5387-4129-b693-82b1dc779b53"
    private let jwtToken = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySUQiOiIwNjkxRjNFOC0zNzcwLTRGOTYtOTMwNS1BMjA1OEJERjhEMjEiLCJleHAiOjE3MTg1NDgyMTEuNjQ0MzA0fQ.kGukSZIZj14oeJ8QC7H7VviIh-jqIInMvQeOh7mV5w0"
    let adminNickname = "yaroslav22"
    
    init() {
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
                self?.newRoomId = createdRoom.id
                self?.gameRooms.append(createdRoom)
                completion()
            })
            .store(in: &cancellables)
    }
    
    func addGamerToRoom(roomId: UUID?, gamerId: UUID, completion: @escaping () -> Void) {
        guard let roomId = roomId else { return }
        
        let url = URL(string: "\(baseURL)/addGamer")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "ApiKey")
        request.setValue(jwtToken, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let gamerIntoRoom = GamerIntoRoom(id: nil, gamerId: gamerId, roomId: roomId, enteredPassword: nil)
        
        do {
            request.httpBody = try JSONEncoder().encode(gamerIntoRoom)
        } catch {
            print("Error encoding gamer into room: \(error)")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: GamerIntoRoom.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error adding gamer to room: \(error)")
                }
            }, receiveValue: { _ in
                completion()
            })
            .store(in: &cancellables)
    }
    
    func leaveRoom(completion: @escaping () -> Void) {
        guard let roomId = newRoomId else { return }
        
        let url = URL(string: "\(baseURL)/\(roomId)/leaveRoom")!
        
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
        guard let roomId = newRoomId else { return }
        
        let url = URL(string: "\(baseURL)/\(roomId)")!
        
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
