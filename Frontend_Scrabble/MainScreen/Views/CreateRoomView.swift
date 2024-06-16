import SwiftUI

struct CreateRoomView: View {
    @ObservedObject var viewModel: GameRoomViewModel
    @State private var roomCode: String = ""
    @State private var currentNumberOfChips: String = ""
    
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
            
            NavigationLink(destination: GameScreenView(viewModel: GameScreenViewModel(roomId: viewModel.newRoomId ?? UUID())), isActive: $viewModel.navigateToGameScreen) {
                EmptyView()
            }
            
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
        .navigationTitle("Create Game Room")
    }
    
    private func createRoom() {
        guard !roomCode.isEmpty, let chips = Int(currentNumberOfChips) else {
            print("Validation failed: Room code or chips are invalid.")
            return
        }
        
        print("Attempting to create room with code: \(roomCode) and chips: \(chips)")
        
        viewModel.createGameRoom(roomCode: roomCode, currentNumberOfChips: chips) {
            if viewModel.newRoomId != nil {
                print("Room created with ID: \(viewModel.newRoomId!.uuidString)")
                viewModel.navigateToGameScreen = true
            }
        }
    }
}
