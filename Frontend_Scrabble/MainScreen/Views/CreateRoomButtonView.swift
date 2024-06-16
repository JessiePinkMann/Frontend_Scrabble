//
//  CreateRoomButtonView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct CreateRoomButtonView: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
}


