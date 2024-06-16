import SwiftUI

struct MainGameRoomView: View {
    @StateObject private var viewModel = GameRoomViewModel()
    @State private var showCodeInputView = false
    @State private var selectedRoom: GameRoom?
    @State private var enteredCode = ""
    @State private var showError = false
    @State private var errorMessage = ""
    var onLogout: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                ActiveRoomsNowView(viewModel: viewModel)
                
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.gameRooms) { room in
                            Button(action: {
                                selectedRoom = room
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    showCodeInputView = true
                                }
                            }) {
                                RoomRowView(room: room)
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
            .sheet(isPresented: $showCodeInputView) {
                if let room = selectedRoom {
                    CodeInputView(
                        room: room,
                        enteredCode: $enteredCode,
                        showError: $showError,
                        errorMessage: $errorMessage,
                        onSuccess: {
                            viewModel.addGamerToRoom(roomId: room.id, roomCode: enteredCode) {
                                viewModel.navigateToGameScreen = true
                            }
                            showCodeInputView = false
                        },
                        onCancel: {
                            showCodeInputView = false
                        }
                    )
                }
            }
        }
        .onAppear {
            viewModel.fetchGameRooms()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}
