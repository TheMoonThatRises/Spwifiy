//
//  PlayingViewModel.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import SwiftUI
import SpotifyWebAPI

class PlayingViewModel: ObservableObject {

    @Binding var playingTrack: Track? {
        didSet {
            totalTime = playingTrack?.durationMS
        }
    }

    @Published var isPlaying: Bool

    @AppStorage("setting.playing.shuffled") var isShuffled: Bool = false
    @AppStorage("setting.playing.looping") var isLooping: Bool = false

    @Published var progress: Double?

    @Published var currentTime: Int? {
        didSet {
            if let currentTime = currentTime, let totalTime = totalTime {
                progress = Double(currentTime) / Double(totalTime)
            }
        }
    }
    @Published var totalTime: Int? {
        didSet {
            currentTime = 0
            progress = 0
        }
    }

    @AppStorage("setting.playing.volume") var volume: Double = 0.0

    init(playingTrack: Binding<Track?>) {
        self._playingTrack = playingTrack
        self.isPlaying = false
    }

}
