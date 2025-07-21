//
//  SoundManager.swift
//  MatchImage
//
//  Created by Tapan Raut on 22/07/25.
//

import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?

    func playBackgroundMusic(filename: String = "background", fileExtension: String = "mp3") {
        guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            print("Background music file not found.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // infinite loop
            audioPlayer?.volume = 0.4
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing background music: \(error.localizedDescription)")
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

