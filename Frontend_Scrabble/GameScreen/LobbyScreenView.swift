//
//  LobbyScreenView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct LobbyScreenView: View {
    @ObservedObject var viewModel: GameRoomViewModel
    @Binding var room: GameRoom?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    leaveRoom()
                }) {
                    Text("Leave Room")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
                Spacer()
                Button(action: {
                    deleteRoom()
                }) {
                    Text("Delete Room")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            Spacer()
            
            Text("Room: \(room?.roomCode ?? "")")
                .font(.largeTitle)
                .padding()
            
            Text("Status: \(room?.gameStatus ?? "")")
                .font(.title)
                .padding()
            
            Text("Chips: \(room?.currentNumberOfChips ?? 0)")
                .font(.title)
                .padding()
            
            Spacer()
        }
        .navigationBarTitle("Lobby", displayMode: .inline)
    }
    
    private func leaveRoom() {
        guard let roomId = room?.id else { return }
        
        viewModel.leaveRoom(roomId: roomId) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func deleteRoom() {
        guard let roomId = room?.id else { return }
        
        viewModel.deleteRoom(roomId: roomId) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct LobbyScreenView_Previews: PreviewProvider {
    @State static var room: GameRoom? = GameRoom(id: UUID(), adminNickname: "yaroslav22", roomCode: "123", gameStatus: "Not Started", currentNumberOfChips: 123)
    
    static var previews: some View {
        LobbyScreenView(viewModel: GameRoomViewModel(), room: $room)
    }
}
