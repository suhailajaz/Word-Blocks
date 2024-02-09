//
//  ContentView.swift
//  Project5-WordBlocks
//
//  Created by suhail on 09/02/24.
//

import SwiftUI

struct ContentView: View {
    @State private var allWords = [String]()
    @State private var usedWords = [String]()
    @State private var rootWord = String()
    @State private var newWord = String()
    @State private var errorTitle = String()
    @State private var errorMessage = String()
    @State private var isPresented = false
    @State private var score = 0
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                        .onSubmit(addNewWord)
                }
                
                Section{
                    ForEach(usedWords,id: \.self){ word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $isPresented) {
                Button("Ok"){ }
            }message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("New Word"){
                    differentWord()
                }
            }
            Spacer()
            Text("Score: \(score)")
        }
        
        
    }
    
}
// MARK: - USer defined methods
extension ContentView{
    
    func startGame(){
        if let fileURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            let contents = try! String(contentsOf: fileURL)
            allWords = contents.components(separatedBy: "\n")
            differentWord()
            return
        }
        fatalError("Could not load start.txt from the bundle.")
    }
    func differentWord(){
        score = 0
        usedWords = [String]()
        rootWord = allWords.randomElement() ?? "Mediocre"
    }
    func addNewWord(){
        
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count>2 else{
            showError(title: "Too Short", message: "The word should be more than three letters long")
            return
        }
        guard answer != rootWord else{
            showError(title: "Too Subtle", message: "The word you enter cannot be equal to the word which you have to guess")
            return
        }
        
        //word validation methods
        
        guard isOriginal(word: answer) else{
            showError(title: "Word already used", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else{
            showError(title: "Word not possible", message: "You cant spell that from \(rootWord)")
            return
        }
        guard isReal(word: answer) else{
            showError(title: "Word not real", message: "That's not even a word!")
            return
        }
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            
        }
        score += 1
        newWord = String()
    }
    //word validation methods
    func isOriginal(word: String)-> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String)->Bool{
        var tempWord = rootWord
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    func isReal(word: String)-> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    //error alert triggering function
    func showError(title: String,message: String){
        errorTitle = title
        errorMessage = message
        newWord = ""
        isPresented = true
    }
    
}
#Preview {
    ContentView()
}
