//
//  SpotifyScraper.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation
import SwiftyJSON

class SpotifyScraper {

    public static let shared = SpotifyScraper()

    private static var baseScrapeURL: String {
        "https://open.spotify.com"
    }

    private var artistString: (String) -> String {
        { artistId in
            "\(SpotifyScraper.baseScrapeURL)/artist/\(artistId)"
        }
    }

    private var artistJSONCache: [String: JSON] = [:]

    private var cacheBuildVer: String {
        get {
            UserDefaults.standard.string(forKey: "spwifiy.cache.buildVer") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "spwifiy.cache.buildVer")
        }
    }

    private var cacheBuildDate: String {
        get {
            UserDefaults.standard.string(forKey: "spwifiy.cache.buildDate") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "spwifiy.cache.buildDate")
        }
    }

    public func hasArtistJSON(artistId: String) -> Bool {
        artistJSONCache.keys.contains(artistId)
    }

    public func fetchArtistJSON(artistId: String, success: (() -> Void)?) async {
        guard let url = URL(string: artistString(artistId)) else {
            return
        }

        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let spotifyHTML = String(data: data, encoding: .utf8) else {
            return
        }

        let base64Pattern = #"<script id="initialState" type="text/plain">(.+?)</script>"#

        guard let base64Range = spotifyHTML.range(of: base64Pattern, options: .regularExpression) else {
            return
        }

        let splitRange = spotifyHTML[base64Range].split(separator: ">").flatMap { $0.split(separator: "<") }

        guard splitRange.count == 3,
              let dataJSON = String(splitRange[1]).fromBase64() else {
            return
        }

        artistJSONCache[artistId] = JSON(parseJSON: dataJSON)[
            "entities",
            "items",
            "spotify:artist:\(artistId)"
        ]

        success?()
    }

    public func getArtistMonthlyListeners(artistId: String) -> Int? {
        artistJSONCache[artistId]?[
            "stats",
            "monthlyListeners"
        ].intValue
    }

    public func getArtistFollowers(artistId: String) -> Int? {
        artistJSONCache[artistId]?[
            "stats",
            "followers"
        ].intValue
    }

    public func getArtistBiography(artistId: String) -> String? {
        artistJSONCache[artistId]?[
            "profile",
            "biography",
            "text"
        ].stringValue
    }

    public func getArtistExternalLinks(artistId: String) -> [(String, String)] {
        artistJSONCache[artistId]?[
            "profile",
            "externalLinks",
            "items"
        ].array?
        .map { ($0["name"].stringValue, $0["url"].stringValue) } ?? []
    }

    public func getArtistBackgroundBanner(artistId: String) -> String? {
        artistJSONCache[artistId]?[
            "headerImage",
            "data",
            "sources"
        ].array?.sorted { one, two in
            (one["maxHeight"].int ?? 0) > (two["maxHeight"].int ?? 0)
        }
        .first?["url"]
        .stringValue
    }

    public func getBuildInfo(useCache: Bool) async -> (String, String)? {
        if useCache, let date = Date.convertor(cacheBuildDate), date.isToday() {
            return (cacheBuildVer, cacheBuildDate)
        }

        guard let spotifyHTML: String = await APIRequest.shared.request(
            urlString: SpotifyScraper.baseScrapeURL
        ) else {
            return nil
        }

        let scriptPattern = #"<script src="https://open.spotifycdn.com/cdn/build/web-player/web-player(.+?)js">"#

        guard let scriptRange = spotifyHTML.range(of: scriptPattern, options: .regularExpression) else {
            return nil
        }

        let scriptComponents = spotifyHTML[scriptRange].split(separator: "\"")

        guard scriptComponents.count == 3 else {
            return nil
        }

        guard let scriptHTML: String = await APIRequest.shared.request(
            urlString: String(scriptComponents[1])
        ) else {
            return nil
        }

        let buildPattern = #"buildVer:"(.+?)",buildDate:"(.+?)""#

        guard let buildRange = scriptHTML.range(of: buildPattern, options: .regularExpression) else {
            return nil
        }

        let buildComponents = scriptHTML[buildRange].split(separator: "\"")

        guard buildComponents.count == 4 else {
            return nil
        }

        cacheBuildVer = String(buildComponents[1])
        cacheBuildDate = String(buildComponents[3])

        return (cacheBuildVer, cacheBuildDate)
    }

}
