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

            if let track = currentPlayingTrack,
               !playExplicit && track.isExplicit {
                nextSong()
            }
        }
    }

    @Published var isPlaying: Bool = false {
        didSet {
            mpNowPlayingInfoCenter.playbackState = isPlaying ? .playing : .paused

            if isPlaying {
                setPresence()
            } else {
                discordRPC.clearPresence()
            }
        }
    }
    @Published var isBuffering: Bool = false

    @Published var totalRunTime: Double = 0 {
        didSet {
            currentPlayTime = 0

            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = totalRunTime

            setPresence()
        }
    }
    @Published var currentPlayTime: Double = 0 {
        didSet {
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayTime
        }
    }

    @Published var isScrubbing: Bool = false {
        didSet {
            if isScrubbing {
                player.pause()
            } else {
                seek(time: CMTime(seconds: currentPlayTime, preferredTimescale: 100))
                player.play()
            }
        }
    }

    @AppStorage("setting.playing.shuffled") var isShuffled: Bool = false
    @AppStorage("setting.playing.looping") var isLooping: Bool = false
    @AppStorage("setting.playing.volume") var volume: Double = 1.0 {
        didSet {
            player.volume = Float(pow(volume, 2.5))
        }
    }

    var statusObserveToken: NSKeyValueObservation?
    var timeControlObserveToken: NSKeyValueObservation?
    var playerItemObserveToken: NSKeyValueObservation?
    var periodicTimeObserverToken: Any?

    private var isQueueingItem: Bool = false
    private var queuingItems: [String] = []

    var playerReady: Bool {
        player.status == .readyToPlay
    }

    var playExplicit: Bool {
        UserDefaults.standard.bool(forKey: "settings.playback.explicit")
    }

    var displayDiscordRPC: Bool {
        UserDefaults.standard.bool(forKey: "settings.misc.discordrpc")
    }

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

        return item.expiration.hasExpired() ? nil : item
    }

    private func createPlayerItem(m3u8: URL) -> AVPlayerItem {
        let asset = AVURLAsset(url: m3u8)
        let item = AVPlayerItem(asset: asset)

        return item
    }

    private func updateQueueItem(itemIndex: Int) async -> Bool {
        if itemIndex < 0 || itemIndex >= trackQueue.count {
            return false
        }

        let track = trackQueue[itemIndex]
        let playerItem = playerItems[track.id ?? ""]

        if let playerItem = playerItem,
           !playerItem.expiration.hasExpired(buffer: 30.0) {
            return true
        }

        guard let trackId = track.id else {
            print("track id is nil")

            return false
        }

        if queuingItems.contains(trackId) {
            return true
        } else {
            queuingItems.append(trackId)
        }

        if let artists = track.artists?.description,
           let musicId = await YoutubeMusicAPI.shared.getYoutubeSongId(artistName: artists,
                                                                       songName: track.name,
                                                                       albumName: track.album?.name) {
            async let hlsResponse = YoutubeAPI.shared.getSongHLS(musicId: musicId)
            async let sponsorBlock = SponsorBlockAPI.shared.getSkipSegments(videoId: musicId)

            let sponsorBlockSegments = await sponsorBlock.items.map { ($0.segment[0], $0.segment[1]) }

            guard let (expiration, m3u8) = await hlsResponse else {
                print("youtube api response nil")

                return false
            }

            playerItems[trackId] = QueuePlayerItem(avPlayerItem: createPlayerItem(m3u8: m3u8),
                                                   track: track,
                                                   expiration: expiration,
                                                   sponsorBlockSegments: sponsorBlockSegments)

            queuingItems.removeAll { $0 == trackId }

            return true
        } else {
            print("unable to add track: \(track.name) - \(track.artists?.description ?? "Unknown")")

            return false
        }
    }

    public func updatePlayer() {
        player.pause()

        if playingIndex >= trackQueue.count || playingIndex < 0 {
            if isLooping {
                if isShuffled {
                    trackQueue = trackQueue.shuffled()
                }

                playingIndex = 0
            } else {
                cleanPlayer()

                return
            }
        }

        currentPlayingTrack = trackQueue[playingIndex]

        if let playerItem = getPlayerItem(trackId: currentPlayingTrack?.id) {
            player.replaceCurrentItem(with: playerItem.avPlayerItem)

            seek(time: CMTime(seconds: 0, preferredTimescale: 1))

            setupNowPlaying()

            player.play()

            Task { @MainActor in
                if isQueueingItem {
                    return
                } else {
                    isQueueingItem = true
                }

                defer {
                    isQueueingItem = false
                }

                while totalRunTime == 0 {
                    try? await Task.sleep(for: .seconds(3))
                }

                var updateIndex = playingIndex

                repeat {
                    updateIndex += 1
                } while !(await updateQueueItem(itemIndex: updateIndex)) && updateIndex < trackQueue.count
            }
        } else {
            Task { @MainActor in
                let success = await updateQueueItem(itemIndex: playingIndex)

                if !success {
                    self.playingIndex += 1
                }

                self.updatePlayer()
            }
        }
    }

    public func togglePlay() {
        if isPlaying {
            pauseAudio()
        } else if playerReady {
            playAudio()
        } else {
            print("player is not ready to play")
        }
    }

    public func playAudio() {
        player.play()

        updateNowPlaying()
    }

    public func pauseAudio() {
        player.pause()

        updateNowPlaying()
    }

    func seek(time: CMTime) {
        player.seek(to: normalizeSeekTime(time: time), toleranceBefore: .zero, toleranceAfter: .zero)

        setPresence(seekTime: time.seconds)
    }

}
