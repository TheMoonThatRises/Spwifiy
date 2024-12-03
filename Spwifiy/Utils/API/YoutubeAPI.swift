//
//  YoutubeAPI.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/1/24.
//

import Foundation
import YouTubeKit
import M3U8Decoder

class YoutubeAPI {

    public static let shared = YoutubeAPI()

    // music id : youtube hls url
    private var musicIdCache = ThreadSafeDictionary<String, (Date, URL)>()

    let youtubeModel: YouTubeModel

    init() {
        self.youtubeModel = YouTubeModel()
    }

    private func getHLSFromCache(musicId: String) -> (Date, URL)? {
        guard let (expiration, hls) = musicIdCache[musicId] else {
            return nil
        }

        if expiration.timeIntervalSince1970 > Date().timeIntervalSince1970 {
            return (expiration, hls)
        } else {
            musicIdCache.removeValue(forKey: musicId)

            return nil
        }
    }

    private func setHLSCache(musicId: String, hls: URL, expiration: Date?) {
        musicIdCache[musicId] = (
            expiration ?? Date().addingTimeInterval(5.5 * 60 * 60), // 5.5 hours in the future,
            hls
        )
    }

    public func getSongHLS(artistName: String, songName: String, albumName: String?) async -> (Date, URL)? {
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

            let m3u8Playlist = try await M3U8Decoder.default.decode(YoutubeM3U8.self, from: streamingURL)

            guard let bestAudioURI = m3u8Playlist.extXMedia
                    .sorted(by: { (Int($0.groupId) ?? 0) > (Int($1.groupId) ?? 0) })
                    .first?.uri,
                  let url = URL(string: bestAudioURI) else {
                return nil
            }

            setHLSCache(musicId: musicId, hls: url, expiration: streamingInfo.videoURLsExpireAt)

            return getHLSFromCache(musicId: musicId)
        } catch {
            print("unable to retrieve song: \(error)")

            return nil
        }
    }

}
