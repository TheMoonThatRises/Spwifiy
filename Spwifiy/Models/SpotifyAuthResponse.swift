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
    let totpValidity: Int
    let notes: String

    enum CodingKeys: String, CodingKey {
        case clientId
        case accessToken
        case accessTokenExpirationTimestampMs
        case isAnonymous
        case totpValidity
        case notes = "_notes"
    }
}
