//
//  SpotifyAuthResponse.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 12/4/24.
//

struct SpotifyAuthResponse: Codable {
    let clientId: String
    let accessToken: String
    let accessTokenExpirationTimestampMs: Int
    let isAnonymous: Bool
    let notes: String

    enum CodingKeys: String, CodingKey {
        case clientId
        case accessToken
        case accessTokenExpirationTimestampMs
        case isAnonymous
        case notes = "_notes"
    }
}
