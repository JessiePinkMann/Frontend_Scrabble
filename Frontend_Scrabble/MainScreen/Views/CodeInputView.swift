//
//  CodeInputView.swift
//  Frontend_Scrabble
//
//  Created by Egor Anoshin on 16.06.2024.
//

import SwiftUI

struct CodeInputView: View {
    var room: GameRoom
    @Binding var enteredCode: String
    @Binding var showError: Bool
    @Binding var errorMessage: String
    var onSuccess: () -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Text("Enter Code for \(room.roomCode ?? "Room")")
                .font(.title)
                .padding()
            
            TextField("Enter Code", text: $enteredCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: {
                    validateCode()
                }) {
                    Text("Enter")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding()
                }
                
                Button(action: {
                    onCancel()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .padding()
    }
    
    private func validateCode() {
        if enteredCode == room.roomCode {
            onSuccess()
        } else {
            showError = true
            errorMessage = "Incorrect code. Please try again."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showError = false
            }
        }
        enteredCode = ""
    }
}
