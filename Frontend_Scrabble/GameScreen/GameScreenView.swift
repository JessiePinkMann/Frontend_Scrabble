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
                    HStack {
                        Text(player.nickName)
                        Spacer()
                        if viewModel.isAdmin {
                            Button("Make Admin") {
                                viewModel.makePlayerAdmin(player: player)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.trailing, 10)

                            Button("Kick") {
                                viewModel.kickPlayer(player: player)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                }
            }
            
            Spacer()
            
            if viewModel.isAdmin {
                Button(action: {
                    viewModel.deleteRoom {
                        DispatchQueue.main.async {
                            dismiss()
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            
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
