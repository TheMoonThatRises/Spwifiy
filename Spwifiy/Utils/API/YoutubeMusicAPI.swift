//
//  YoutubeMusicAPI.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation
import SwiftyJSON

enum YoutubeResultType: String {
    case artist = "MUSIC_PAGE_TYPE_ARTIST"
    case song = "MUSIC_VIDEO_TYPE_ATV"
    case album = "MUSIC_PAGE_TYPE_ALBUM"
}

class YoutubeMusicAPI {

    public static let shared = YoutubeMusicAPI()

    private static var dataRegex: String {
        "initialData\\.push\\(\\{path: '\\\\/search', params: JSON\\.parse\\(.+?\\), data: '\\{.+?\\}'\\}\\);"
    }

    private static var jsonRegex: String {
        "data: '\\{.+?\\}\\);"
    }

    // artist id or youtube search string : background image url
    private var backgroundImageCache: [String: String] = [:]

    // youtube music search url : youtube id
    private var musicIdCache: [String: String] = [:]

    private var requestURLString: (String, String?, String?) -> String? {
        { artist, songName, albumName in
            guard let safeArtist = artist.addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
                return nil
            }

            var baseURL = "https://music.youtube.com/search?q=\(safeArtist)"

            if let songName = songName,
               let songName = songName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                baseURL += "+\(songName)"
            }

            if let albumName = albumName,
               let albumName = albumName.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                baseURL += "+\(albumName)"
            }

            return baseURL
        }
    }

    private func parseSearchResult(html: String?) -> JSON? {
        guard let escapedHtml = html?.unescapeHexEscapedString() else {
            return nil
        }

        guard let searchSection = escapedHtml.matches(for: YoutubeMusicAPI.dataRegex).first else {
            return nil
        }

        guard let partialJsonString = searchSection.matches(for: YoutubeMusicAPI.jsonRegex).first else {
            return nil
        }

        guard let firstIndex = partialJsonString.firstIndex(of: "{"),
              let lastIndex = partialJsonString.lastIndex(of: "'") else {
            return nil
        }

        let jsonString = String(
            partialJsonString[firstIndex...partialJsonString.index(before: lastIndex)]
        ).replacingOccurrences(of: "\\\\\"", with: "\\\"")

        guard let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }

        do {
            return try JSON(data: jsonData)
        } catch {
            print("unable to get search result: \(error)")

            return nil
        }
    }

    private func getSearchShelf(json: JSON) -> [JSON]? {
        json["contents"]["tabbedSearchResultsRenderer"]["tabs"]
            .array?
            .filter { $0["tabRenderer"]["title"].string == "YT Music" }
            .first?["tabRenderer"]["content"]["sectionListRenderer"]["contents"]
            .array
    }

    private func getTopSearchItem(json: [JSON]) -> JSON? {
        json
            .filter {
                $0["musicCardShelfRenderer"]["header"]["musicCardShelfHeaderBasicRenderer"]["title"]["runs"]
                    .array?
                    .first?["text"].string == "Top result"
            }
            .first?["musicCardShelfRenderer"]
    }

    private func getSearchShelfItem(json: [JSON], shelfName: String) -> JSON? {
        json
            .filter {
                $0["musicShelfRenderer"]["title"]["runs"]
                    .array?
                    .first?["text"].string == shelfName
            }
            .first?["musicShelfRenderer"]
    }

    private func verifyTopIsType(json: JSON, type: YoutubeResultType) -> Bool {
        json["navigationEndpoint",
             "browseEndpoint",
             "browseEndpointContextSupportedConfigs",
             "browseEndpointContextMusicConfig",
             "pageType"
        ].string == type.rawValue ||
        json["navigationEndpoint",
             "watchEndpoint",
             "watchEndpointMusicSupportedConfigs",
             "watchEndpointMusicConfig",
             "musicVideoType"
        ].string == type.rawValue
    }

    private func getBackgroundArtURL(json: JSON) -> String? {
        guard let url = json["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
            .array?
            .first?["url"].string else {
            return nil
        }

        return url.replacing(/w[0-9]+?-h[0-9]+?.+?rj(.+)?/, with: "w2880-h1200-p-l90-rj")
    }

    public func getBackgroundArt(artistId: String?,
                                 artistName: String,
                                 topSong: String?,
                                 topAlbum: String?) async -> String? {
        guard let requestString = requestURLString(artistName, topSong, topAlbum) else {
            return nil
        }

        let keyString = artistId ?? requestString

        if let backgroundURL = backgroundImageCache[keyString] {
            return backgroundURL
        }

        let response = await APIRequest.shared.request(urlString: requestString)
        let json = parseSearchResult(html: response)

        guard let json = json,
              let apiContent = getSearchShelf(json: json) else {
            return nil
        }

        let artistResults = getSearchShelfItem(json: apiContent, shelfName: "Artists")

        var backgroundImageURL: String?

        if topSong == nil || artistResults == nil {
            let topResult = getTopSearchItem(json: apiContent)

            if let topResult = topResult {
                let topText = topResult["title"]["runs"]
                    .array?
                    .filter {
                        $0["text"].string?.lowercased().unescapingUnicodeCharacters == artistName.lowercased() &&
                        verifyTopIsType(json: $0, type: .artist)
                    }

                if (topText?.count ?? 0) > 0 {
                    backgroundImageURL = getBackgroundArtURL(json: topResult)
                }
            }
        } else {
            if let artists = artistResults?["contents"].array {
                let matchingArtists = artists
                    .filter { verifyTopIsType(json: $0["musicResponsiveListItemRenderer"], type: .artist) }
                    .first

                if let bestMatchArtist = matchingArtists?["musicResponsiveListItemRenderer"] {
                    backgroundImageURL = getBackgroundArtURL(json: bestMatchArtist)
                }
            }
        }

        if let backgroundImageURL = backgroundImageURL {
            backgroundImageCache[keyString] = backgroundImageURL
        }

        return backgroundImageURL
    }

    public func getBackgroundArtCache(artistId: String) -> String? {
        backgroundImageCache[artistId]
    }

    public func getArtistSongId(artistName: String, songName: String, albumName: String?) async -> String? {
        guard let requestString = requestURLString(artistName, songName, albumName) else {
            return nil
        }

        if let musicId = musicIdCache[requestString] {
            return musicId
        }

        let response = await APIRequest.shared.request(urlString: requestString)
        let json = parseSearchResult(html: response)

        guard let json = json,
              let apiContent = getSearchShelf(json: json) else {
            return nil
        }

        var musicId = ""

        if let topResult = getTopSearchItem(json: apiContent),
           let run = topResult["title"]["runs"].array?.first,
           verifyTopIsType(json: run, type: .song),
           let songId = run["navigationEndpoint"]["watchEndpoint"]["videoId"].string {
            musicId = songId
        } else {
            let songResults = getSearchShelfItem(json: apiContent, shelfName: "Songs")?["contents"].array

            guard let song = songResults?.first,
                  let songId = song["musicResponsiveListItemRenderer"]["playlistItemData"]["videoId"].string else {
                return await getArtistSongId(artistName: artistName, songName: songName, albumName: nil)
            }

            musicId = songId
        }

        musicIdCache[requestString] = musicId

        return musicId
    }

}
