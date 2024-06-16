import SwiftUI

struct RoomRowView: View {
    var room: GameRoom
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(room.roomCode ?? "Unknown Room")
                    .font(.headline)
                Text("Admin: \(room.adminNickname)")
                    .font(.subheadline)
                Text("Chips: \(room.currentNumberOfChips)")
                    .font(.subheadline)
            }
            Spacer()
            Text(room.gameStatus)
                .font(.subheadline)
                .foregroundColor(room.gameStatus == "Not Started" ? .green : .red)
        }
        .padding()
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
    }
}


