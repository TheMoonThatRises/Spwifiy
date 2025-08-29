//
//  ExtendedSpotifiyAPI.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/22/25.
//

import Foundation
import KeychainAccess

class ExtendedSpotifiyAPI {

    private static let userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " +
                                   "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3.1 Safari/605.1.15"

    private let jsonDecoder = JSONDecoder()

    private var lyricsAPI: (String) -> String {
        { trackId in
            "https://spclient.wg.spotify.com/color-lyrics/v2/track/" +
            trackId +
            "?format=json&vocalRemoval=false&market=from_token"
        }
    }

    private var spotifyViewModel: SpotifyViewModel?
    private let keychain: Keychain

    private var tokenResponse: SpotifyAuthResponse?

    init() {
        self.keychain = Keychain(service: SpwifiyApp.service)
    }

    public func setSpotifyViewModel(spotifyViewModel: SpotifyViewModel) {
        self.spotifyViewModel = spotifyViewModel
    }

    private func getToken() async -> String? {
        guard let spotifyViewModel else {
            return nil
        }

        if let tokenResponse,
           Date().millisecondsSince1970 < Double(tokenResponse.accessTokenExpirationTimestampMs) - 30 * 1000 {
            return tokenResponse.accessToken
        }

        let success = await spotifyViewModel.extendedSpotifyAuth()

        guard success,
              let authAccessResponse = await self.keychain[data: SpotifyAuthManager.authAccessResponse],
              let decodedAuthResponse = try? jsonDecoder.decode(SpotifyAuthResponse.self,
                                                                from: authAccessResponse) else {
            return nil
        }

        tokenResponse = decodedAuthResponse

        return tokenResponse?.accessToken
    }

    private func setHeaders(request: inout URLRequest) async {
        if let token = await getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("gzip, deflate, br, zstd", forHTTPHeaderField: "Accept-Encoding")
        request.setValue("WebPlayer", forHTTPHeaderField: "App-Platform")
//        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
//        request.setValue("https://open.spotify.com", forHTTPHeaderField: "Origin")
        request.setValue("https://open.spotify.com/", forHTTPHeaderField: "Referer")
//        request.setValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
//        request.setValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
//        request.setValue("same-site", forHTTPHeaderField: "Sec-Fetch-Site")
        request.setValue(ExtendedSpotifiyAPI.userAgent, forHTTPHeaderField: "User-Agent")
    }

    func getLyrics(trackId: String) async -> SpotifyLyrics? {
        guard let lyricsURL = URL(string: lyricsAPI(trackId)) else {
            return nil
        }

        var request = URLRequest(url: lyricsURL)
        await setHeaders(request: &request)

        if !(request.allHTTPHeaderFields?.keys.contains("Authorization") ?? false) {
            return nil
        }

        return await withCheckedContinuation { continuation in
            APIRequest.shared.request(request: request, noCache: true) { data in
                guard let data = data,
                      let lyrics = try? self.jsonDecoder.decode(SpotifyLyrics.self, from: data) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: lyrics)
            }
        }
    }

}
