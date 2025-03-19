//
//  AVAudioPlayer+discordRPC.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/2/24.
//

import Foundation
import SwordRPC

extension AVAudioPlayer {

    func discordRPCInit() {
        if displayDiscordRPC {
            self.discordRPC.connect()
        }
    }

    private func constructPresence(seekTime: Double? = nil) -> RichPresence {
        let currentTime = seekTime ?? currentPlayTime

        var presence = RichPresence()

        presence.type = .listening
        presence.assets.largeImage = "appicon"

        if let track = currentPlayingTrack {
            presence.details = track.name
            presence.state = (track.artists?.description ?? "Unknown artists").truncate(128)

            presence.timestamps.start = Date() - currentTime
            presence.timestamps.end = Date() + totalRunTime - currentTime

            presence.assets.largeImage = track.album?.images?.first?.url.absoluteString
            presence.assets.largeText = (track.album?.name ?? "Unknown album").truncate(128)
        }

        return presence
    }

    func setPresence(seekTime: Double? = nil) {
        if displayDiscordRPC {
            discordRPC.setPresence(constructPresence(seekTime: seekTime))
        }
    }

}
