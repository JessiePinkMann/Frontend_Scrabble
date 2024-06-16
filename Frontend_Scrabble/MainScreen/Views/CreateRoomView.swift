//
//  CreateRoomView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct CreateRoomView: View {
    @ObservedObject var viewModel: GameRoomViewModel
    @State private var roomCode: String = ""
    @State private var currentNumberOfChips: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Room Code", text: $roomCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Number of Chips", text: $currentNumberOfChips)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
            
            Spacer()
            
            Button(action: {
                createRoom()
            }) {
                Text("Create!")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .padding()
        .navigationBarTitle("Create Game Room", displayMode: .inline)
    }
    
    private func createRoom() {
        guard !roomCode.isEmpty, let chips = Int(currentNumberOfChips) else {
            // Handle validation error
            return
        }
        
        viewModel.createGameRoom(roomCode: roomCode, currentNumberOfChips: chips) {
            if let newRoomId = viewModel.newRoomId {
                viewModel.addGamerToRoom(roomId: newRoomId, gamerId: UUID()) {  // Вставьте сюда правильный gamerId
                    presentationMode.wrappedValue.dismiss()
                    viewModel.navigateToGameScreen = true
                }
            }
        }
    }
}

