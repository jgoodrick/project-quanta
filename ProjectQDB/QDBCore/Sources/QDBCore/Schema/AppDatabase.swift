//
//  AppDatabase.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 4/6/25.
//

import Foundation
import IssueReporting
import OSLog
import SharingGRDB
import SwiftUI

private let logger = Logger(subsystem: "MyApp", category: "Database")

public func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    #if DEBUG
    configuration.prepareDatabase { db in
        db.trace(options: .profile) {
            if context == .preview {
                print("\($0.expandedDescription)")
            } else {
                logger.debug("\($0.expandedDescription)")
            }
        }
    }
    #endif
    let database: any DatabaseWriter
    if context == .live {
        let path = URL.documentsDirectory.appending(component: "db.sqlite").path()
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    } else if context == .test {
        let path = URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
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
