//
//  YoutubeAPI.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import Foundation
import YouTubeKit

class YoutubeAPI {

    public static let shared = YoutubeAPI()

    // music id : youtube hls url
    private var musicIdCache: [String: (Double, URL)] = [:]

    let youtubeModel: YouTubeModel

    init() {
        self.youtubeModel = YouTubeModel()
    }

    private func getHLSFromCache(musicId: String) -> URL? {
        guard let (expiration, hls) = musicIdCache[musicId] else {
            return nil
        }

        if expiration - Date().timeIntervalSince1970 > 0 {
            return hls
        } else {
            musicIdCache.removeValue(forKey: musicId)

            return nil
        }
    }

    private func setHLSCache(musicId: String, hls: URL) {
        musicIdCache[musicId] = (
            Date().addingTimeInterval(5.5 * 60 * 60).timeIntervalSince1970, // 5.5 hours in the future
            hls
        )
    }

    public func getSongHLS(artistName: String, songName: String, albumName: String?) async -> URL? {
        guard let musicId = await YoutubeMusicAPI.shared.getArtistSongId(artistName: artistName,
                                                                         songName: songName,
                                                                         albumName: albumName) else {
            return nil
        }

        if let hlsLink = getHLSFromCache(musicId: musicId) {
            return hlsLink
        }

        let video = YTVideo(videoId: musicId)

        do {
            let streamingInfo = try await video.fetchStreamingInfosThrowing(youtubeModel: youtubeModel)

            guard let streamingURL = streamingInfo.streamingURL else {
                return nil
            }

            setHLSCache(musicId: musicId, hls: streamingURL)

            return streamingURL
        } catch {
            print("unable to retrieve song: \(error)")

            return nil
        }
    }

}
