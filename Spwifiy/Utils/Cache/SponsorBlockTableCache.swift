//
//  SponsorBlockTableCache.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/26/25.
//

import Foundation
import GRDB

class SponsorBlockTableCache: GenericTable {

    private let idKey: String = "_id"
    private let songIdKey: String = "song_id"
    private let contentKey: String = "content"

    init() {
        super.init(tableName: SponsorBlockSqlite.databaseTableName)
    }

    override func createTable(builder: TableDefinition) {
        builder.autoIncrementedPrimaryKey(idKey)
        builder.column(songIdKey, .text).notNull().unique()
        builder.column(contentKey, .blob).notNull()
    }

    public func addSponsorBlockItem(songId sId: String, content: [SponsorBlockItem]) {
        let sqliteStruct = SponsorBlockSqlite(id: nil, songId: sId, content: content)

        insertItem(item: sqliteStruct)
    }

    public func getSponsorBlockItem(songId sId: String) -> [SponsorBlockItem]? {
        let item: SponsorBlockSqlite? = getItem { fetch in
            fetch
                .filter(Column(self.songIdKey) == sId)
        }

        return item?.content
    }

}
