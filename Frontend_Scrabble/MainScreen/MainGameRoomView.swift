//
//  MainGameRoomView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct MainGameRoomView: View {
    @StateObject private var viewModel = GameRoomViewModel()
    @State private var showCreateRoomView = false
    var onLogout: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                ActiveRoomsNowView(viewModel: viewModel)
                
                ActiveRoomsListView(gameRooms: viewModel.gameRooms)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                Button(action: {
                    showCreateRoomView.toggle()
                }) {
                    Text("Create Game Room")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding()
                }
                .sheet(isPresented: $showCreateRoomView) {
                    CreateRoomView(viewModel: viewModel)
                }
                
                Button(action: {
                    onLogout()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .padding()
            .navigationBarTitle("Game Rooms", displayMode: .inline)
        }
    }
}

#Preview {
    MainGameRoomView(onLogout: {})
}
