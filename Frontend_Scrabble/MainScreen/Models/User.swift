//
//  UserModel.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import Foundation

struct User: Identifiable, Codable {
    var id: UUID?
    var nickName: String
    var password: String
    
    init(id: UUID? = nil, nickName: String, password: String) {
        self.id = id
        self.nickName = nickName
        self.password = password
    }
}

