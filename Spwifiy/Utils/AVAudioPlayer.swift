//
//  AVAudioPlayer.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/2/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer
import SpotifyWebAPI
import CachedAsyncImage
import SwordRPC

@MainActor
class AVAudioPlayer: ObservableObject {

    let player: AVPlayer = AVPlayer()

    var mpNowPlayingSetCooldown: Date = Date()
    let mpNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    var nowPlayingInfo: [String: Any] = [:] {
        didSet {
            updateNowPlaying()
        }
    }

    let discordRPC: SwordRPC = SwordRPC(appId: "1313374141960949831")

    @Published var playingId: String?

    @Published var trackQueue: [Track] = []
    @Published var previousQueue: [Track] = []
    @Published var playerItems: [String: QueuePlayerItem] = [:]

    @Published var playingIndex: Int = 0

    @Published var currentPlayingTrack: Track? {
        didSet {
            totalRunTime = 0
        }
    }

    @Published var isPlaying: Bool = false {
        didSet {
            if !isPlaying {
                discordRPC.clearPresence()
            }
        }
    }
    @Published var isBuffering: Bool = false

    @Published var totalRunTime: Double = 0 {
        didSet {
            currentPlayTime = 0
            playProgress = 0

            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalRunTime

            setPresence()
        }
    }
    @Published var currentPlayTime: Double = 0 {
        didSet {
            playProgress = currentPlayTime / max(totalRunTime, 1)
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayTime
        }
    }
    @Published var playProgress: Double = 0

    @AppStorage("setting.playing.shuffled") var isShuffled: Bool = false
    @AppStorage("setting.playing.looping") var isLooping: Bool = false
    @AppStorage("setting.playing.volume") var volume: Double = 1.0

    var statusObserveToken: NSKeyValueObservation?
    var timeControlObserveToken: NSKeyValueObservation?
    var playerItemObserveToken: NSKeyValueObservation?
    var periodicTimeObserverToken: Any?

    init() {
        self.initNotifiers()
        self.setupRemoteCommandCenter()

        self.discordRPCInit()
    }

    deinit {
        discordRPC.disconnect()

        statusObserveToken?.invalidate()
        timeControlObserveToken?.invalidate()
        playerItemObserveToken?.invalidate()

        if let periodicTimeObserverToken = periodicTimeObserverToken {
            player.removeTimeObserver(periodicTimeObserverToken)
        }

        NotificationCenter.default.removeObserver(self)
    }

    private func getPlayerItem(trackId: String?) -> QueuePlayerItem? {
        guard let trackId = trackId,
              let item = playerItems[trackId] else {
            return nil
        }

        if item.expiration.timeIntervalSince1970 < Date().timeIntervalSince1970 {
            return nil
        } else {
            return item
        }
    }

    private func createPlayerItem(m3u8: URL) -> AVPlayerItem {
        let asset = AVURLAsset(url: m3u8)
        let item = AVPlayerItem(asset: asset)

        return item
    }

    private func updatePlayerItem(index: Int, success: @escaping (Bool) -> Void) async {
        for queueIndex in [index, index + 1, index - 1] {
            if queueIndex < 0 || queueIndex > trackQueue.count {
                continue
            }

            let track = trackQueue[queueIndex]

            if let trackId = track.id,
               let artists = track.artists?.description,
               let (expiration, m3u8) = await YoutubeAPI.shared.getSongHLS(artistName: artists,
                                                                           songName: track.name,
                                                                           albumName: track.album?.name) {
                playerItems[trackId] = QueuePlayerItem(avPlayerItem: createPlayerItem(m3u8: m3u8),
                                                       track: track,
                                                       expiration: expiration)

                if queueIndex == index {
                    success(true)
                }
            } else {
                print("unable to add track: \(track.name) - \(track.artists?.description ?? "Unknown")")

                if queueIndex == index {
                    success(false)

                    return
                }
            }
        }
    }

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

    public func removeAllSongs() {
        trackQueue.removeAll()
    }

    private func updateSong(incBy: Int) {
        togglePlay()

        playingIndex += incBy

        if playingIndex < trackQueue.count && playingIndex >= 0 {
            previousQueue.append(trackQueue[playingIndex])
        }

        updatePlayer()
    }

    public func nextSong() {
        updateSong(incBy: 1)
    }

//    public func nextSong(track: Track) {
//        guard let trackIndex = trackQueue.firstIndex(of: track) else {
//            print("unable to jump to track: \(track.name) - \(track.artists?.description ?? "Unknown")")
//
//            return
//        }
//
//        let incIndex = trackIndex - playingIndex
//
//        if incIndex >= 0 {
//            updateSong(incBy: incIndex)
//        } else {
//
//        }
//    }

    public func prevSong() {
        if currentPlayTime < 0.1 {
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 2))
        } else {
            updateSong(incBy: -1)
        }
    }

    func seek(time: CMTime) {
        player.seek(to: time)

        setPresence(seekTime: time.seconds)
    }

    public func updatePlayer() {
        if playingIndex >= trackQueue.count || playingIndex < 0 {
            if isLooping {
                if isShuffled {
                    trackQueue = trackQueue.shuffled()
                }

                playingIndex = 0
            } else {
                return
            }
        }

        currentPlayingTrack = trackQueue[playingIndex]

        if let playerItem = getPlayerItem(trackId: currentPlayingTrack?.id) {
            player.replaceCurrentItem(with: playerItem.avPlayerItem)

            seek(time: CMTime(seconds: 0, preferredTimescale: 2))

            setupNowPlaying()

            player.play()
        } else {
            Task { @MainActor in
                await updatePlayerItem(index: playingIndex) { success in
                    if !success {
                        self.playingIndex += 1
                    }

                    self.updatePlayer()
                }
            }
        }
    }

    public func togglePlay() {
        if isPlaying {
            player.pause()
        } else if player.status == .readyToPlay {
            player.play()
        } else {
            print("player is not ready to play")
        }
    }

}
