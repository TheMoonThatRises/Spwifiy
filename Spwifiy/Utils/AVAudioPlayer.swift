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
                seek(time: CMTime(seconds: currentPlayTime, preferredTimescale: 1))
                player.play()
            }
        }
    }

    @AppStorage("setting.playing.shuffled") var isShuffled: Bool = false
    @AppStorage("setting.playing.looping") var isLooping: Bool = false
    @AppStorage("setting.playing.volume") var volume: Double = 1.0

    var statusObserveToken: NSKeyValueObservation?
    var timeControlObserveToken: NSKeyValueObservation?
    var playerItemObserveToken: NSKeyValueObservation?
    var periodicTimeObserverToken: Any?

    private var isQueueingItem: Bool = false

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

    private func updateQueueItem(itemIndex: Int) async -> Bool {
        if itemIndex < 0 || itemIndex >= trackQueue.count {
            return false
        }

        let track = trackQueue[itemIndex]

        if playerItems[track.id ?? ""] != nil {
            return true
        }

        if let trackId = track.id,
           let artists = track.artists?.description,
           let musicId = await YoutubeMusicAPI.shared.getYoutubeSongId(artistName: artists,
                                                                       songName: track.name,
                                                                       albumName: track.album?.name),
           let (expiration, m3u8) = await YoutubeAPI.shared.getSongHLS(musicId: musicId) {
            let sponsorBlock = await SponsorBlockAPI.shared.getSkipSegments(videoId: musicId)
            let sponsorBlockSegments = sponsorBlock.items.map { ($0.segment[0], $0.segment[1]) }

            print(sponsorBlock)

            playerItems[trackId] = QueuePlayerItem(avPlayerItem: createPlayerItem(m3u8: m3u8),
                                                   track: track,
                                                   expiration: expiration,
                                                   sponsorBlockSegments: sponsorBlockSegments)

            return true
        } else {
            print("unable to add track: \(track.name) - \(track.artists?.description ?? "Unknown")")

            return false
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
            player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        } else {
            updateSong(incBy: -1)
        }
    }

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

        for segment in playingItem.sponsorBlockSegments {
            if currentTime >= segment.0 {
                time -= segment.1 - segment.0
            }
        }

        return time
    }

    private func normalizeSeekTime(time: CMTime) -> CMTime {
        guard let track = currentPlayingTrack,
              let playingItem = playerItems[track.id ?? ""] else {
            return time
        }

        var seekTime = time.seconds

        for segment in playingItem.sponsorBlockSegments {
            if seekTime >= segment.0 {
                seekTime += segment.1 - segment.0
            }
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

    func seek(time: CMTime) {
        player.seek(to: normalizeSeekTime(time: time), toleranceBefore: .zero, toleranceAfter: .zero)

        setPresence(seekTime: time.seconds)
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
            player.pause()
        } else if player.status == .readyToPlay {
            player.play()
        } else {
            print("player is not ready to play")
        }

        updateNowPlaying()
    }

}
