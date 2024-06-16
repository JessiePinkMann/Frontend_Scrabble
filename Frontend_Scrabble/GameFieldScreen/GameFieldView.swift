import SwiftUI

struct GameFieldView: View {
    @State private var symbols: [[String]] = Array(repeating: Array(repeating: "", count: 15), count: 15)
    @State private var lastWord = ""
    @State private var startCoordinate: (Int, Int)?
    @State private var endCoordinate: (Int, Int)?
    @State private var isWordCorrect = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }
            
            Spacer().frame(height: 64)
            VStack(spacing: 0) {
                ForEach(0..<15, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<15, id: \.self) { col in
                            SingleCharacterTextField(text: Binding(
                                get: { symbols[row][col] },
                                set: { newValue in
                                    if !newValue.isEmpty {
                                        symbols[row][col] = newValue
                                        endCoordinate = (row, col)
                                        if startCoordinate == nil {
                                            startCoordinate = (row, col)
                                        }
                                    }
                                }
                            ))
                            .frame(width: 23, height: 23)
                            .background(.tertiary)
                            .cornerRadius(6)
                            .padding(1)
                        }
                    }
                }
                Spacer().frame(height: 24)
                Button("Submit", action: submitAction)
                    .frame(width: 234, height: 34)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }
    
    func submitAction() {
        guard let start = startCoordinate, let end = endCoordinate else {
            lastWord = "Nothing to submit"
            print(lastWord)
            return
        }
        
        let formedWord = WordProcessor.formWord(from: symbols, start: start, end: end, rowCount: 15, colCount: 15)
        lastWord = formedWord.isEmpty ? "Nothing to submit" : formedWord
        
        startCoordinate = nil
        endCoordinate = nil
        
        WordService.shared.submitWordToServer(word: lastWord) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    isWordCorrect = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isWordCorrect = false
                    errorMessage = "Word doesn't exist!"
                }
            }
        }
    }
    
}

struct SingleCharacterTextField: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.keyboardType = .asciiCapable
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SingleCharacterTextField
        
        init(_ textField: SingleCharacterTextField) {
            self.parent = textField
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            let currentText = textField.text ?? ""
            let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string).uppercased()
            
            if prospectiveText.count <= 1 && prospectiveText.allSatisfy(allowedCharacters.contains) {
                parent.text = prospectiveText
                return true
            }
            return false
        }
    }
}

#Preview {
    GameFieldView()
}
