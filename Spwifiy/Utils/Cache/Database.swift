//
//  Database.swift
//  Spwifiy
//
//  Created by Peter Duanmu on 4/22/25.
//

import Foundation
import GRDB

class Database {

    private static var supportDirectory: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first!
            .appending(path: SpwifiyApp.bundleIdentifier)
    }

    private static var fileName: String = "cache"

    private let dbFile: URL
    private var dbc: DatabasePool?

    init() {
        do {
            try FileManager.default.createDirectory(at: Database.supportDirectory,
                                                    withIntermediateDirectories: true)
        } catch {
            print("failed to create database directory: \(error)")
        }

        self.dbFile = Database.supportDirectory
            .appending(component: Database.fileName)
            .appendingPathExtension("sqlite")

        self.tryConnectDatabase()
    }

    public func getConnection() -> DatabasePool? {
        dbc
    }

    public func tryConnectDatabase() {
        if dbc == nil {
            do {
                dbc = try DatabasePool(path: dbFile.path)
            } catch {
                print("failed to connect to database: \(error)")
            }
        }
    }

}
