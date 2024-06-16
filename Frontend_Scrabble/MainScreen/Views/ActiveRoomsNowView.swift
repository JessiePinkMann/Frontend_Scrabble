//
//  ActiveRoomsNowView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct ActiveRoomsNowView: View {
    @ObservedObject var viewModel: GameRoomViewModel
    
    var body: some View {
        Text("Active rooms now: \(viewModel.gameRooms.count)")
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

