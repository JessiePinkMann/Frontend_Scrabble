//
//  Chip.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import Foundation

struct Chip: Identifiable, Codable, Equatable {
    var id: UUID
    var alpha: String
    var point: Int
}

