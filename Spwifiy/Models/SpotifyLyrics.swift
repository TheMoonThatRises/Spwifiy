//
//  SpotifyLyrics.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/22/25.
//

import Foundation

struct SpotifyLyrics: Codable {
    let lyrics: SpotifyLyricsData
    let colors: SpotifyLyricsColors
    let hasVocalRemoval: Bool
}

struct SpotifyLyricsColors: Codable {
    let background: Int
    let text: Int
    let highlightText: Int
}

struct SpotifyLyricsData: Codable {
    let syncType: String
    let lines: [SpotifyLyricsLine]
    let provider: String
    let providerLyricsId: String
    let providerDisplayName: String
    let syncLyricsUri: String
    let isDenseTypeface: Bool
    let alternatives: [String?]
    let language: String
    let isRtlLanguage: Bool
    let capStatus: String
    let previewLines: [SpotifyLyricsLine]
}

struct SpotifyLyricsLine: Codable, Equatable {
    let startTimeMs: Int
    let words: String
    let syllables: [String?]
    let endTimeMs: Int

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.words = try container.decode(String.self, forKey: .words)
        self.syllables = try container.decode([String?].self, forKey: .syllables)

        if let intEndTimeMs = try? container.decode(Int.self, forKey: .endTimeMs) {
            self.endTimeMs = intEndTimeMs
            self.startTimeMs = try container.decode(Int.self, forKey: .startTimeMs)
        } else {
            self.endTimeMs = Int(try container.decode(String.self, forKey: .endTimeMs)) ?? 0
            self.startTimeMs = Int(try container.decode(String.self, forKey: .startTimeMs)) ?? 0
        }
    }
}
