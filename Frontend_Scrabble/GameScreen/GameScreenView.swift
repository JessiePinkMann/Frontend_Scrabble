import SwiftUI

struct GameScreenView: View {
    @ObservedObject var viewModel: GameScreenViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Welcome to the Game Room")
                .font(.largeTitle)
                .padding()
            
            if viewModel.isLoading {
                ProgressView("Loading players...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                List(viewModel.players) { player in
                    Text(player.nickName)
                }
                .frame(maxHeight: 300)
            }
            
            Spacer()
            
            Button(action: {
                leaveRoom()
            }) {
                Text("Back")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding()
            }
        }
        .navigationTitle("Game Room")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            leaveRoom()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
        })
    }
    
    private func leaveRoom() {
        viewModel.leaveRoom {
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
}
