//
//  GRDB.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 4/6/25.
//

import Dependencies
import Foundation
import GRDB
import StructuredQueriesGRDB

public func appDatabase() throws -> any DatabaseWriter {
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        #if DEBUG
        db.trace(options: .profile) {
            print($0.expandedDescription)
        }
        #endif
    }

    @Dependency(\.context) var context
    if context == .live {
        let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
        print("open", path)
        database = try DatabasePool(path: path, configuration: configuration)
    } else {
        database = try DatabaseQueue(configuration: configuration)
    }

    var migrator = DatabaseMigrator()

    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("Migrate tables") { db in
        try DB.migrate(db: db)
    }

    #if DEBUG
    migrator.registerMigration("Insert sample data") { db in
        try DB.createMockData(in: db)
    }
    #endif

    try migrator.migrate(database)

    return database
}
