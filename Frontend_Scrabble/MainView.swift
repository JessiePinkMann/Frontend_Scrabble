import SwiftUI

struct MainView: View {
    @StateObject var viewModel = GameRoomViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Active rooms now: \(viewModel.gameRooms.count)")
                    .font(.title)
                    .padding()
                
                List(viewModel.gameRooms) { room in
                    Text(room.roomCode ?? "Unknown Room")
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
