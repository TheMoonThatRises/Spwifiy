//
//  AVAudioPlayer+sponsorBlock.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

import MediaPlayer

extension AVAudioPlayer {

    func normalizeTotalRunTime(runTime: Double) -> Double {
        guard let track = currentPlayingTrack,
              let playingItem = playerItems[track.id ?? ""] else {
            return runTime
        }

        var time = runTime

        for segment in playingItem.sponsorBlockSegments {
            time -= segment.1 - segment.0
        }

        return time
    }

    func normalizeCurrentTime(currentTime: Double) -> Double {
        guard let track = currentPlayingTrack,
              let playingItem = playerItems[track.id ?? ""] else {
            return currentTime
        }

        var time = currentTime

        for segment in playingItem.sponsorBlockSegments where currentTime >= segment.0 {
            time -= segment.1 - segment.0
        }

        return time
    }

    func normalizeSeekTime(time: CMTime) -> CMTime {
        guard let track = currentPlayingTrack,
              let playingItem = playerItems[track.id ?? ""] else {
            return time
        }

        var seekTime = time.seconds

        for segment in playingItem.sponsorBlockSegments where seekTime >= segment.0 {
            seekTime += segment.1 - segment.0
        }

        return CMTime(seconds: seekTime, preferredTimescale: 1000)
    }

    func skipSponsorBlockSegment() {
        guard let track = currentPlayingTrack,
              let playingItem = playerItems[track.id ?? ""] else {
            return
        }

        let currentPlayTime = player.currentTime().seconds

        for segment in playingItem.sponsorBlockSegments {
            if currentPlayTime > segment.0 && currentPlayTime < segment.1 {
                if segment.1 >= (player.currentItem?.duration.seconds ?? 0) {
                    nextSong()
                } else {
                    seek(time: CMTime(seconds: segment.1, preferredTimescale: 1000))
                }

                return
            }
        }
    }
}
