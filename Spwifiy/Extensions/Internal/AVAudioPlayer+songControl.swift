//
//  AVAudioPlayer+songControl.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 3/16/25.
//

import SpotifyWebAPI
import AVFoundation

extension AVAudioPlayer {

    public func addSong(track: Track) {
        trackQueue.append(track)

        if trackQueue.count == 1 {
            updatePlayer()
        }
    }

    public func addBulkSongs(tracks: [Track]) {
        for track in tracks {
            addSong(track: track)
        }
    }

    public func removeSong(index: Int) {
        trackQueue.remove(at: index)

        if index == playingIndex {
            updatePlayer()
        }
    }

    public func removeSong(track: Track) {
        if let index = trackQueue.firstIndex(of: track) {
            removeSong(index: index)
        }
    }

    public func removeAllSongs() {
        player.pause()

        trackQueue.removeAll()

        playingIndex = 0
    }

    public func clearQueue() {
        trackQueue.removeSubrange((playingIndex + 1)...)
    }

    public func clearPrevQueue() {
        previousQueue.removeAll()
    }

    private func updateSong(incBy: Int) {
        pauseAudio()

        if playingIndex < trackQueue.count && playingIndex >= 0 {
            previousQueue.append(trackQueue[playingIndex])
        }

        playingIndex += incBy

        updatePlayer()
    }

    public func nextSong() {
        updateSong(incBy: 1)
    }

    public func prevSong() {
        if currentPlayTime < 0.1 {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        } else {
            updateSong(incBy: -1)
        }
    }

    public func updatePlayingList(newPlayingId: String?, tracks: [Track], starting: Track? = nil) {
        if isPlaying {
            previousQueue.append(trackQueue[playingIndex])
        }

        removeAllSongs()

        let addTracks = starting == nil ? tracks : tracks.filter { $0 != starting }

        if let starting = starting {
            addSong(track: starting)
        }

        addBulkSongs(
            tracks: isShuffled ? addTracks.shuffled() : addTracks
        )

        playingId = newPlayingId
    }

    public func goToQueueTrack(track: Track, newQueue: [Track]) {
        if isPlaying {
            previousQueue.append(trackQueue[playingIndex])
        }

        let removeIndex = trackQueue.firstIndex(of: track)

        if let removeIndex = removeIndex {
            trackQueue.removeSubrange(0...(removeIndex - 1))

            updatePlayer()
        } else {
            updatePlayingList(newPlayingId: playingId, tracks: newQueue, starting: track)
        }
    }

}
