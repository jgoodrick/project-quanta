//
//  AppDatabase.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 4/6/25.
//

import Foundation
import IssueReporting
import OSLog
import SQLiteData
import SwiftUI

private let logger = Logger(subsystem: "QDBCore", category: "Database")

public func appDatabase() throws -> any DatabaseWriter {
    @Dependency(\.context) var context
    let database: any DatabaseWriter
    var configuration = Configuration()
    configuration.foreignKeysEnabled = true
    configuration.prepareDatabase { db in
        #if DEBUG
        db.trace(options: .profile) {
            if context == .preview {
                print("\($0.expandedDescription)")
            } else {
                logger.debug("\($0.expandedDescription)")
            }
        }
        #endif
    }
    switch context {
    case .preview:
        database = try DatabaseQueue(configuration: configuration)
    case .live, .test:
        let path = if context == .live {
            URL.documentsDirectory.appending(component: "db.sqlite").path()
        } else {
            URL.temporaryDirectory.appending(component: "\(UUID().uuidString)-db.sqlite").path()
        }
        logger.info("open \(path)")
        database = try DatabasePool(path: path, configuration: configuration)
    }

    var migrator = DatabaseMigrator()

    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif

    migrator.registerMigration("Create initial tables") { db in
        try createInitialTables(db: db)
    }

    try migrator.migrate(database)

    try database.write { db in
        if context == .preview {
            try db.seedSampleData()
        }

//        try Entry.createTemporaryTrigger(after: .insert { new in
//            ReminderText.insert {
//                ReminderText.Columns(
//                    rowid: new.rowid,
//                    title: new.title,
//                    notes: new.notes.replace("\n", " "),
//                    tags: ""
//                )
//            }
//        })
//        .execute(db)
//
//        try Reminder.createTemporaryTrigger(after: .update {
//            ($0.title, $0.notes)
//        } forEachRow: { _, new in
//            ReminderText
//                .where { $0.rowid.eq(new.rowid) }
//                .update {
//                    $0.title = new.title
//                    $0.notes = new.notes.replace("\n", " ")
//                }
//        })
//        .execute(db)
//
//        try Reminder.createTemporaryTrigger(after: .delete { old in
//            ReminderText
//                .where { $0.rowid.eq(old.rowid) }
//                .delete()
//        })
//        .execute(db)
//
//        func updateReminderTextTags(
//            for reminderID: some QueryExpression<Reminder.ID>
//        ) -> UpdateOf<ReminderText> {
//            ReminderText
//                .where { $0.rowid.eq(Reminder.find(reminderID).select(\.rowid)) }
//                .update {
//                    $0.tags = ReminderTag
//                        .order(by: \.tagID)
//                        .where { $0.reminderID.eq(reminderID) }
//                        .join(Tag.all) { $0.tagID.eq($1.primaryKey) }
//                        .select { ("#" + $1.title).groupConcat(" ") ?? "" }
//                }
//        }
//
//        try ReminderTag.createTemporaryTrigger(after: .insert { new in
//            updateReminderTextTags(for: new.reminderID)
//        })
//        .execute(db)
//
//        try ReminderTag.createTemporaryTrigger(after: .delete { old in
//            updateReminderTextTags(for: old.reminderID)
//        })
//        .execute(db)
    }

    return database
}
