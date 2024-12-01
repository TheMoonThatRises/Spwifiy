//
//  SpotifyScraper.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 11/30/24.
//

import Foundation

class SpotifyScraper {

    public static let shared = SpotifyScraper()

    private var monthlyListenersCache: [String: Int] = [:]

    private var artistString: (String) -> String {
        { artistId in
            "https://open.spotify.com/artist/\(artistId)"
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
        guard let html = await getArtistHTML(artistId: artistId) else {
            return nil
        }

        if let cacheListeners = monthlyListenersCache[artistId] {
            return cacheListeners
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

}
