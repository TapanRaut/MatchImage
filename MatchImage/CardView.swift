//
//  CardView.swift
//  MatchImage
//
//  Created by Tapan Raut on 20/07/25.
//

import SwiftUI

struct CardView: View {
    let card: Card
    var body: some View {
        ZStack {
                   if card.isRevealed || card.isMatched {
                       Image(card.imageName)
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                   } else {
                       Rectangle()
                           .fill(Color.blue)
                   }
               }
               .frame(width: 70, height: 70)
               .clipShape(RoundedRectangle(cornerRadius: 8))
               .shadow(radius: 2)
    }
}

#Preview {
    CardView(card: Card(id: UUID(), imageName: "flower", isRevealed: false, isMatched: false))
}
