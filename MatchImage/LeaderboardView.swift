//
//  LeaderboardView.swift
//  MatchImage
//
//  Created by Tapan Raut on 21/07/25.
//

import SwiftUI

struct LeaderboardView: View {
    let entries: [ScoreEntry]
    let difficulty: Difficulty

    var body: some View {
        NavigationView {
            List(entries) { entry in
                VStack(alignment: .leading) {
                    Text("Score: \(entry.score), Moves: \(entry.moves)")
                        .font(.headline)
                    Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("🏆 \(difficulty.rawValue.capitalized) Leaderboard")
        }
    }
}

#Preview {
    LeaderboardView(
        entries: [
            ScoreEntry(score: 150, moves: 20, date: Date()),
            ScoreEntry(score: 120, moves: 22, date: Date().addingTimeInterval(-86400)),
            ScoreEntry(score: 100, moves: 25, date: Date().addingTimeInterval(-172800))
        ],
        difficulty: .medium
    )
}
