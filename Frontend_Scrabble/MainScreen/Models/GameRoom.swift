//
//  GameRoom.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import Foundation

struct GameRoom: Identifiable, Codable {
    var id: UUID?
    var adminNickname: String
    var roomCode: String?
    var gameStatus: String
    var currentNumberOfChips: Int
    
    init(id: UUID? = nil, adminNickname: String, roomCode: String? = nil,
         gameStatus: String, currentNumberOfChips: Int) {
        self.id = id
        self.adminNickname = adminNickname
        self.roomCode = roomCode
        self.gameStatus = gameStatus
        self.currentNumberOfChips = currentNumberOfChips
    }
}


