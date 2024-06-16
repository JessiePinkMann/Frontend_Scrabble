import SwiftUI

struct GameScreenView: View {
    @ObservedObject var viewModel: GameScreenViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            Text("Welcome to the Game Room")
                .font(.largeTitle)
                .padding()
            
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
