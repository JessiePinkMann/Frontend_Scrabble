//
//  ActiveRoomsListView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct ActiveRoomsListView: View {
    let gameRooms: [GameRoom]
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(gameRooms) { room in
                    VStack(alignment: .leading) {
                        Text(room.adminNickname)
                            .font(.headline)
                        Text("Status: \(room.gameStatus)")
                            .font(.subheadline)
                        Text("Chips: \(room.currentNumberOfChips)")
                            .font(.subheadline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}



