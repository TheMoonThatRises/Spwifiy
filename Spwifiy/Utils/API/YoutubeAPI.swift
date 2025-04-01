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

        if expiration.hasExpired() {
            musicIdCache.removeValue(forKey: musicId)

            return nil
        } else {
            return (expiration, hls)
        }
    }

    private func setHLSCache(musicId: String, hls: URL, expiration: Date?) {
        musicIdCache[musicId] = (
            expiration ?? Date().addingTimeInterval(5.5 * 60 * 60), // 5.5 hours in the future,
            hls
        )
    }

    public func retrieveVisitorData() async {
        let result = await SearchResponse.sendNonThrowingRequest(
            youtubeModel: youtubeModel,
            data: [.query: "never gonna give you up"]
        )

        switch result {
        case .success(let response):
            youtubeModel.visitorData = response.visitorData ?? ""
        case .failure(let error):
            print("failed to retrieve visitor data: \(error)")
        }
    }

    public func getSongFromISRC(isrc: String) async -> String? {
        let result = await SearchResponse.sendNonThrowingRequest(
            youtubeModel: youtubeModel,
            data: [.query: isrc]
        )

        print("isrc: \(isrc)")

        switch result {
        case .success(let response):
            if let response = response.results.first,
               let ytvideo = response as? YTVideo {
                return ytvideo.videoId
            }
        case .failure(let error):
            print("failed to retrieve videoId from isrc: \(error)")
        }

        return nil
    }

    public func getSongHLS(musicId: String) async -> (Date, URL)? {
        if let hlsLink = getHLSFromCache(musicId: musicId) {
            return hlsLink
        }

        let video = YTVideo(videoId: musicId)

        await retrieveVisitorData()

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
