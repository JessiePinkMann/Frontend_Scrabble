//
//  GamerIntoRoom.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import Foundation

struct GamerIntoRoom: Identifiable, Codable {
    var id: UUID?
    var gamerId: UUID
    var roomId: UUID
    var enteredPassword: String?
    var chips: [Chip]?
    
    init(id: UUID? = nil, gamerId: UUID, roomId: UUID, enteredPassword: String? = nil, chips: [Chip]? = nil) {
        self.id = id
        self.gamerId = gamerId
        self.roomId = roomId
        self.enteredPassword = enteredPassword
        self.chips = chips
    }
}
