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
            let artists = track.artists?.description ?? "Unknown artists"
            let album = track.album?.name ?? "Unknown album"

            presence.details = track.name
            presence.state = artists.count > 128 ? artists.truncate(125) + "..." : artists

            presence.timestamps.start = Date() - currentTime
            presence.timestamps.end = Date() + totalRunTime - currentTime

            presence.assets.largeImage = track.album?.images?.first?.url.absoluteString
            presence.assets.largeText = album.count > 128 ? album.truncate(125) + "..." : album
        }

        return presence
    }

    func setPresence(seekTime: Double? = nil) {
        if displayDiscordRPC {
            discordRPC.setPresence(constructPresence(seekTime: seekTime))
        }
    }

}
