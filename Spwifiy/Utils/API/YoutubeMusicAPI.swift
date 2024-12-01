//
//  YoutubeMusicAPI.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation
import SwiftyJSON

class YoutubeMusicAPI {

    public static let shared = YoutubeMusicAPI()

    private static var dataRegex: String {
        "initialData\\.push\\(\\{path: '\\\\/search', params: JSON\\.parse\\(.+?\\), data: '\\{.+?\\}'\\}\\);"
    }

    private static var jsonRegex: String {
        "data: '\\{.+?\\}\\);"
    }

    // youtube music search url : background image url
    private var backgroundImageCache: [String: String] = [:]

    private var requestURLString: (String, String?) -> String? {
        { artist, topSong in
            guard let safeArtist = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
            }

            var baseURL = "https://music.youtube.com/search?q=\(safeArtist)"

            if let topSong = topSong,
               let topSong = topSong.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                baseURL += "+\(topSong)"
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

        return try? JSON(data: jsonData)
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
            .first
    }

    private func getSearchShelfItem(json: [JSON], shelfName: String) -> JSON? {
        json
            .filter {
                $0["musicShelfRenderer"]["title"]["runs"]
                    .array?
                    .first?["text"].string == shelfName
            }
            .first
    }

    private func verifyIsMusicArtist(json: JSON) -> Bool {
        json["navigationEndpoint",
             "browseEndpoint",
             "browseEndpointContextSupportedConfigs",
             "browseEndpointContextMusicConfig",
             "pageType"
        ].string == "MUSIC_PAGE_TYPE_ARTIST"
    }

    private func getBackgroundArtURL(json: JSON) -> String? {
        guard let url = json["thumbnail"]["musicThumbnailRenderer"]["thumbnail"]["thumbnails"]
            .array?
            .first?["url"].string else {
            return nil
        }

        return url.replacing(/w[0-9]+?-h[0-9]+?.+?rj/, with: "w2880-h1200-p-l90-rj")
    }

    public func getBackgroundArt(artistName: String, topSong: String?) async -> String? {
        guard let requestString = requestURLString(artistName, topSong) else {
            return nil
        }

        if let backgroundURL = backgroundImageCache[requestString] {
            return backgroundURL
        }

        let response = await APIRequest.shared.request(urlString: requestString)
        let json = parseSearchResult(html: response)

        guard let json = json,
              let apiContent = getSearchShelf(json: json) else {
            return nil
        }

        var backgroundImageURL: String?

        if topSong == nil {
            let topResult = getTopSearchItem(json: apiContent)

            if let topResult = topResult?["musicCardShelfRenderer"] {
                let topText = topResult["title"]["runs"]
                    .array?
                    .filter {
                        $0["text"].string?.lowercased() == artistName.lowercased() &&
                        verifyIsMusicArtist(json: $0)
                    }

                if (topText?.count ?? 0) > 0 {
                    backgroundImageURL = getBackgroundArtURL(json: topResult)
                }
            }
        } else {
            let artistResults = getSearchShelfItem(json: apiContent, shelfName: "Artists")

            if let artists = artistResults?["musicShelfRenderer"]["contents"].array {
                let matchingArtists = artists
                    .filter { verifyIsMusicArtist(json: $0["musicResponsiveListItemRenderer"]) }
                    .first

                if let bestMatchArtist = matchingArtists?["musicResponsiveListItemRenderer"] {
                    backgroundImageURL = getBackgroundArtURL(json: bestMatchArtist)
                }
            }
        }

        if let backgroundImageURL = backgroundImageURL {
            backgroundImageCache[requestString] = backgroundImageURL
        }

        return backgroundImageURL
    }

}
