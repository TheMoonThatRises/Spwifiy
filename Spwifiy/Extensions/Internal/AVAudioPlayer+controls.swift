//
//  AVAudioPlayer+controls.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/2/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer

// player observers
@MainActor
extension AVAudioPlayer {
    func initNotifiers() {
        self.statusObserveToken = self.player
            .observe(\.status, options: [.new]) { player, _ in
                Task { @MainActor in
                    self.observePlayerStatus(avPlayer: player)
                }
            }

        self.timeControlObserveToken = self.player
            .observe(\.timeControlStatus, options: [.new]) { player, _ in
                Task { @MainActor in
                    self.observeTimeControlStatus(avPlayer: player)
                }
            }

        self.playerItemObserveToken = self.player
            .observe(\.currentItem, options: [.new]) { _, _ in
                Task { @MainActor in
                    self.registerPlayerItemNotification()
                }
            }

        self.periodicTimeObserverToken = self.player
            .addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2),
                                     queue: nil) { time in
                Task { @MainActor in
                    self.periodicTimeObserver(cmTime: time)
                }
            }
    }

    private func observePlayerStatus(avPlayer: AVPlayer) {
        switch avPlayer.status {
        case .readyToPlay:
            player.play()
        case .failed:
            print("failed to play song")
            nextSong()
        default:
            print("unknown status: \(avPlayer.status.rawValue)")
        }
    }

    private func observeTimeControlStatus(avPlayer: AVPlayer) {
        Task { @MainActor in
            isBuffering = false
            isPlaying = false

            switch avPlayer.timeControlStatus {
            case .playing:
                isPlaying = true
            case .paused:
                isPlaying = false
            case .waitingToPlayAtSpecifiedRate:
                isBuffering = false
            default:
                print("unknown status: \(avPlayer.timeControlStatus.rawValue)")
            }

            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1 : 0
        }
    }

    private func periodicTimeObserver(cmTime: CMTime) {
        if player.timeControlStatus == .playing {
            currentPlayTime = normalizeCurrentTime(currentTime: player.currentTime().seconds)

            skipSponsorBlockSegment()

            if totalRunTime == 0 {
                let duration = player.currentItem?.duration.seconds

                totalRunTime = normalizeTotalRunTime(runTime: (duration?.isFinite ?? false) ? duration! : 0)
            }
        }
    }

    private func registerPlayerItemNotification() {
        NotificationCenter.default.removeObserver(self,
                                                  name: AVPlayerItem.didPlayToEndTimeNotification,
                                                  object: nil)

        NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification,
                                               object: player.currentItem,
                                               queue: .main) { notif in
            Task { @MainActor in
                self.playerDidFinishPlaying(notif: notif)
            }
        }
    }

    private func playerDidFinishPlaying(notif: Notification) {
        nextSong()
    }
}

// now playing
extension AVAudioPlayer {
    func setupNowPlaying() {
        guard let track = currentPlayingTrack else {
            return
        }

        nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artists?.description ?? "Unknown"

        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueIndex] = playingIndex
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackQueueCount] = trackQueue.count

        if let album = track.album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album.name

            if let imageURL = album.images?.first?.url {
                APIRequest.shared.request(url: imageURL) { result in
                    guard let result = result,
                          let nsImage = NSImage(data: result) else {
                        return
                    }

                    let artworkItem = MPMediaItemArtwork(boundsSize: CGSize(width: nsImage.size.width,
                                                                            height: nsImage.size.height)) { _ in
                        return nsImage
                    }

                    self.nowPlayingInfo[MPMediaItemPropertyArtwork] = artworkItem
                }
            }
        }
    }

    func updateNowPlaying() {
        let currentTime = Date().timeIntervalSince1970

        if mpNowPlayingSetCooldown.timeIntervalSince1970 < currentTime {
            mpNowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
            mpNowPlayingSetCooldown = Date().addingTimeInterval(0.5)
        }
    }

    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { _ in
            self.playAudio()
            return .success
        }

        commandCenter.pauseCommand.addTarget { _ in
            self.pauseAudio()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { _ in
            self.nextSong()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { _ in
            self.prevSong()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { event in
            let seconds = (event as? MPChangePlaybackPositionCommandEvent)?.positionTime ?? 0
            let time = CMTime(seconds: seconds, preferredTimescale: 100)
            self.seek(time: time)

            return .success
        }
    }
}
