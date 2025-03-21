//
//  SpotifyScraper.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation

class SpotifyScraper {

    public static let shared = SpotifyScraper()

    private static var baseScrapeURL: String {
        "https://open.spotify.com"
    }

    private var monthlyListenersCache: [String: Int] = [:]

    private var artistString: (String) -> String {
        { artistId in
            "\(SpotifyScraper.baseScrapeURL)/artist/\(artistId)"
        }
    }

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

    private func getArtistHTML(artistId: String) async -> String? {
        guard let artistURL = URL(string: artistString(artistId)) else {
            return nil
        }

        let wkWebViewer = await WKWebViewer()

        do {
            guard let html = try await wkWebViewer.getHTML(from: artistURL) else {
                return nil
            }

            return html
        } catch {
            print("unable to get artist html: \(error)")

            return nil
        }
    }

    public func getArtistMonthlyListeners(artistId: String) async -> Int? {
        if let cacheListeners = monthlyListenersCache[artistId] {
            return cacheListeners
        }

        guard let html = await getArtistHTML(artistId: artistId) else {
            return nil
        }

        let monthlyListeners = Int(
            html.matches(for: "monthly-listeners-label\">.+?</div>")
                .first?
                .components(separatedBy: .decimalDigits.inverted)
                .joined() ?? "0"
        )

        if let monthlyListeners = monthlyListeners, monthlyListeners != 0 {
            monthlyListenersCache[artistId] = monthlyListeners
        }

        return monthlyListeners
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
