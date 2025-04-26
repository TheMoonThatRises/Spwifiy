//
//  SponsorBlockSqlite.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/26/25.
//

import GRDB

struct SponsorBlockSqlite: Codable, FetchableRecord, PersistableRecord {
    static var databaseTableName: String {
        "sponsorblock"
    }

    let id: Int64?
    let songId: String
    let content: [SponsorBlockItem]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case songId = "song_id"
        case content
    }
}
