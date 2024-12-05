//
//  SpotifyAuthResponse.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

struct SpotifyAuthResponse: Decodable {
    let clientId: String
    let accessToken: String
    let accessTokenExpirationTimestampMs: Double
    let isAnonymous: Bool
}
