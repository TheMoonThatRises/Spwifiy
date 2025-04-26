//
//  GenericTable.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/23/25.
//

import Foundation
import GRDB

class GenericTable {

    private static let database: Database = Database()

    private let tableName: String

    init(tableName: String) {
        self.tableName = tableName

        self.queryDatabase { dbc in
            try dbc.write { builder in
                try builder.create(table: self.tableName, ifNotExists: true, body: self.createTable(builder:))
            }
        }
    }

    func createTable(builder: TableDefinition) {
        fatalError("must be overridden")
    }

    @discardableResult
    func queryDatabase<T>(method: @escaping (DatabasePool) throws -> T?) -> T? {
        if GenericTable.database.getConnection() == nil {
            GenericTable.database.tryConnectDatabase()
        }

        guard let connection = GenericTable.database.getConnection() else {
            return nil
        }

        do {
            return try method(connection)
        } catch {
            print("failed to query \"\(tableName)\": \(error)")
        }

        return nil
    }

    func insertItem<T: PersistableRecord>(item: T) {
        queryDatabase { dbc in
            try dbc.write { dbv in
                try item.insert(dbv)
            }
        }
    }

    func getItem<T: FetchableRecord>(filter: @escaping (T.Type) -> QueryInterfaceRequest<T>) -> T? {
        queryDatabase { dbc in
            try dbc.read { dbv in
                try filter(T.self)
                    .fetchOne(dbv)
            }
        }
    }

}
