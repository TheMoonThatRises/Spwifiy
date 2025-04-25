//
//  LyricsTableCache.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/23/25.
//

import Foundation
import GRDB

class LyricsTableCache: GenericTable {

    private let idKey: String = "_id"
    private let songIdKey: String = "song_id"
    private let sourceKey: String = "source"
    private let contentKey: String = "content"

    init() {
        super.init(tableName: "lyrics")
    }

    override func createTable(builder: TableDefinition) {
        builder.autoIncrementedPrimaryKey(idKey)
        builder.column(songIdKey, .text).notNull().unique()
        builder.column(sourceKey, .text).notNull()
        builder.column(contentKey, .blob).notNull()
    }

    public func addLyrics<T: Codable>(songId sId: String, source src: LyricSource, lyrics: T) {
        let sqliteStruct = SpotifyLyricsSqlite(id: nil,
                                               songId: sId,
                                               source: src,
                                               content: lyrics)

        queryDatabase { dbc in
            try dbc.write { dbv in
                try sqliteStruct.insert(dbv)
            }
        }
    }

    public func getSpotifyLyrics(songId sId: String) -> SpotifyLyrics? {
        let result = queryDatabase { dbc in
            try dbc.read { dbv in
                try SpotifyLyricsSqlite<SpotifyLyrics>
                    .filter(Column(self.songIdKey) == sId)
                    .filter(Column(self.sourceKey) == LyricSource.spotify.rawValue)
                    .fetchOne(dbv)
            }
        }

        return result??.content
    }

}
