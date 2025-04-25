//
//  SpotifyLyricsSqlite.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/24/25.
//

import GRDB

enum LyricSource: String, Codable {
    case spotify, genius
}

struct SpotifyLyricsSqlite<T: Codable>: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName: String {
        "lyrics"
    }

    let id: Int64?
    let songId: String
    let source: LyricSource
    let content: T

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case songId = "song_id"
        case source
        case content
    }
}
