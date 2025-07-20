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

enum Difficulty: String, CaseIterable, Identifiable {
    case easy, medium, hard
    var id: String { rawValue }

    var pairCount: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 10
        }
    }

    var timeLimit: Int {
        switch self {
        case .easy: return 60
        case .medium: return 45
        case .hard: return 30
        }
    }

    var backgroundColor: Color {
        switch self {
        case .easy: return .green.opacity(0.2)
        case .medium: return .orange.opacity(0.2)
        case .hard: return .red.opacity(0.2)
        }
    }
}

struct ScoreEntry: Codable, Identifiable {
    var id = UUID()
    let score: Int
    let moves: Int
    let date: Date
}

struct MemoryGameView: View {
    @State private var cards: [Card] = []
    @State private var firstSelectedIndex: Int? = nil
    @State private var disableCards = false
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var timeLeft: Int = 0
    @State private var timer: Timer?
    @State private var score: Int = 0
    @State private var moves: Int = 0
    @State private var highScore: Int = 0
    @State private var showWin = false
    @State private var showLeaderboard = false
    @Namespace private var animation

    let columns = [GridItem(.adaptive(minimum: 70))]

    var highScoreKey: String {
        "HighScore_\(selectedDifficulty.rawValue)"
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(Difficulty.allCases) { level in
                        Text(level.rawValue.capitalized).tag(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedDifficulty) { _ in
                    restartGame()
                }

                Text("Current Level: \(selectedDifficulty.rawValue.capitalized)")
                    .font(.headline)

                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Text("Score: \(score) | Moves: \(moves) | ⏱️ \(timeLeft)s")
                    .font(.footnote)
                    .padding(.bottom, 4)

                Text("Average Score: \(averageScore())")
                    .font(.caption)
                    .foregroundColor(.gray)

                LazyVGrid(columns: columns) {
                    ForEach(cards.indices, id: \.self) { index in
                        CardView(card: cards[index])
                            .onTapGesture {
                                flipCard(at: index)
                            }
                            .opacity(cards[index].isMatched ? 0 : 1)
                            .animation(.easeInOut(duration: 0.3), value: cards[index].isMatched)
                    }
                }

                HStack {
                    Button("Restart Game") {
                        restartGame()
                    }

                    Button("Reset High Score") {
                        highScore = 0
                        UserDefaults.standard.removeObject(forKey: highScoreKey)
                    }
                    .foregroundColor(.red)
                }
                .padding()

                Button("🏆 View Leaderboard") {
                    showLeaderboard = true
                }
                .padding()
                .sheet(isPresented: $showLeaderboard) {
                    LeaderboardView(entries: loadLeaderboard(), difficulty: selectedDifficulty)
                }
            }
            .padding()
            .background(
                selectedDifficulty.backgroundColor
                    .animation(.easeInOut, value: selectedDifficulty)
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("Memory Game")
            .onAppear(perform: restartGame)
            .alert("🎉 You Won!", isPresented: $showWin) {
                Button("OK") {
                    restartGame()
                }
            } message: {
                Text("Your Score: \(score)\nMoves: \(moves)")
            }
        }
    }

    func restartGame() {
        let images = ["flower", "star", "moon", "heart", "sun.max", "cloud", "bolt", "leaf", "flame", "drop"]
        let selectedImages = Array(images.shuffled().prefix(selectedDifficulty.pairCount))
        var pairs = (selectedImages + selectedImages).shuffled()
        cards = pairs.map { Card(id: UUID(), imageName: $0) }
        firstSelectedIndex = nil
        disableCards = false
        timeLeft = selectedDifficulty.timeLimit
        score = 0
        moves = 0
        highScore = UserDefaults.standard.integer(forKey: highScoreKey)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer?.invalidate()
            }
        }
    }

    func flipCard(at index: Int) {
        guard !cards[index].isRevealed && !cards[index].isMatched && !disableCards else { return }
        cards[index].isRevealed = true

        if let firstIndex = firstSelectedIndex {
            disableCards = true
            moves += 1
            if cards[firstIndex].imageName == cards[index].imageName {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    cards[firstIndex].isMatched = true
                    cards[index].isMatched = true
                    score += 10
                    resetSelection()
                    checkWin()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cards[firstIndex].isRevealed = false
                    cards[index].isRevealed = false
                    resetSelection()
                }
            }
        } else {
            firstSelectedIndex = index
        }
    }

    func resetSelection() {
        firstSelectedIndex = nil
        disableCards = false
    }

    func checkWin() {
        if cards.allSatisfy({ $0.isMatched }) {
            timer?.invalidate()
            if score > highScore {
                highScore = score
                UserDefaults.standard.set(score, forKey: highScoreKey)
            }
            saveScoreEntry(score: score, moves: moves)
            showWin = true
        }
    }

    func saveScoreEntry(score: Int, moves: Int) {
        var entries = loadLeaderboard()
        entries.append(ScoreEntry(score: score, moves: moves, date: Date()))
        entries.sort { $0.score > $1.score }
        entries = Array(entries.prefix(10)) // Top 10
        if let data = try? JSONEncoder().encode(entries) {
            let key = leaderboardKey(for: selectedDifficulty)
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func leaderboardKey(for difficulty: Difficulty) -> String {
        "Leaderboard_\(difficulty.rawValue)"
    }

    func loadLeaderboard() -> [ScoreEntry] {
        let key = leaderboardKey(for: selectedDifficulty)
        if let data = UserDefaults.standard.data(forKey: key),
           let entries = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            return entries
        }
        return []
    }

    func averageScore() -> Int {
        let entries = loadLeaderboard()
        guard !entries.isEmpty else { return 0 }
        let total = entries.reduce(0) { $0 + $1.score }
        return total / entries.count
    }
}


#Preview {
    MemoryGameView()
}
