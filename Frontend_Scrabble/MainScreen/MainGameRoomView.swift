import SwiftUI

struct MainGameRoomView: View {
    @StateObject private var viewModel = GameRoomViewModel()
    var onLogout: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                ActiveRoomsNowView(viewModel: viewModel)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.gameRooms) { room in
                            NavigationLink(destination: GameScreenView(viewModel: GameScreenViewModel(roomId: room.id!))) {
                                RoomRowView(room: room)
                                    .onTapGesture {
                                        viewModel.addGamerToRoom(roomId: room.id, roomCode: room.roomCode ?? "") {
                                            viewModel.navigateToGameScreen = true
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                NavigationLink(destination: CreateRoomView(viewModel: viewModel)) {
                    Text("Create Game Room")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                        .padding()
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
            .navigationTitle("Game Rooms")
            .navigationDestination(isPresented: $viewModel.navigateToGameScreen) {
                if let roomId = viewModel.newRoomId {
                    GameScreenView(viewModel: GameScreenViewModel(roomId: roomId))
                }
            }
        }
        .onAppear {
            viewModel.fetchGameRooms()
        }
    }
}

struct MainGameRoomView_Previews: PreviewProvider {
    static var previews: some View {
        MainGameRoomView(onLogout: {})
    }
}
