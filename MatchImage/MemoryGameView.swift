//
//  MemoryGameView.swift
//  MatchImage
//
//  Created by Tapan Raut on 20/07/25.
//

import SwiftUI

struct Card: Identifiable {
    let id: UUID
    let imageName: String
    var isRevealed: Bool = false
    var isMatched: Bool = false
}
struct MemoryGameView: View {
    // 1. Initialize the cards
       @State private var cards: [Card] = {
           let images = ["flower", "star", "moon", "heart"]
           // Duplicate and shuffle
           var pairs = images + images
           pairs.shuffle()
           return pairs.map { Card(id: UUID(), imageName: $0) }
       }()
    
    @State private var firstSelectedIndex: Int? = nil
    @State private var disableCards = false
    let columns = [GridItem(.adaptive(minimum: 80))]
    
    var body: some View {
        LazyVGrid(columns: columns) {
                   ForEach(cards.indices, id: \.self) { index in
                       let card = cards[index]
                       CardView(card: card)
                           .onTapGesture {
                               flipCard(at: index)
                           }
                           .opacity(card.isMatched ? 0 : 1)
                   }
               }
               .padding()
           }
    func flipCard(at index: Int) {
            guard !cards[index].isRevealed && !cards[index].isMatched && !disableCards else { return }
            
            // Reveal the tapped card
            cards[index].isRevealed = true
            
            if let firstIndex = firstSelectedIndex {
                // Second card tapped
                disableCards = true
                if cards[firstIndex].imageName == cards[index].imageName {
                    // Match found
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        cards[firstIndex].isMatched = true
                        cards[index].isMatched = true
                        resetSelection()
                    }
                } else {
                    // Not a match, hide after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        cards[firstIndex].isRevealed = false
                        cards[index].isRevealed = false
                        resetSelection()
                    }
                }
            } else {
                // First card selected
                firstSelectedIndex = index
            }
        }
        
        func resetSelection() {
            firstSelectedIndex = nil
            disableCards = false
        }
    }


#Preview {
    MemoryGameView()
}
