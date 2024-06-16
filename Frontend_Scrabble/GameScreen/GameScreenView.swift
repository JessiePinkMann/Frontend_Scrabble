//
//  GameScreenView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct GameScreenView: View {
    @ObservedObject var viewModel: GameRoomViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    leaveRoom()
                }) {
                    Text("Leave Room")
                        .foregroundColor(.red)
                        .padding()
                }
                Spacer()
                Button(action: {
                    deleteRoom()
                }) {
                    Text("Delete Room")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            Spacer()
            // Ваши игровые элементы здесь
        }
        .padding()
        .navigationBarTitle("Game Room", displayMode: .inline)
    }
    
    private func leaveRoom() {
        viewModel.leaveRoom {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func deleteRoom() {
        viewModel.deleteRoom {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct GameScreenView_Previews: PreviewProvider {
    static var previews: some View {
        GameScreenView(viewModel: GameRoomViewModel())
    }
}
