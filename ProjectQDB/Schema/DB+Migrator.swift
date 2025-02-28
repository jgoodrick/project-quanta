//
//  AppDatabase+Migrator.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/24/25.
//

import Foundation
import GRDB

extension Table {
    fileprivate static var createMigrationName: String {
        "Add \(tableName) table"
    }
}

extension Join {
    fileprivate static var joinMigrationName: String {
        "Join table of \(Left.tableName) and \(Right.tableName)"
    }

    fileprivate static var lhsReference: String {
        if Left.tableName == Right.tableName {
            "lhs\(Left.tableName.capitalized)"
        } else {
            Left.tableName
        }
    }
    
    fileprivate static var rhsReference: String {
        if Left.tableName == Right.tableName {
            "rhs\(Right.tableName.capitalized)"
        } else {
            Right.tableName
        }
    }
}

extension DatabaseMigrator {
    mutating func create<T: Table>(
        table type: T.Type,
        finishDefining: @escaping (TableDefinition) throws -> Void
    ) {
        registerMigration(T.createMigrationName) { db in
            try db.create(table: T.tableName) { t in
                t.autoIncrementedPrimaryKey("id")
                try finishDefining(t)
            }
        }
    }

    mutating func join<T: Join>(
        table type: T.Type,
        migrationName: String? = nil,
        tableName: String? = nil,
        finishDefining: @escaping (TableDefinition) throws -> Void = { _ in }
    ) where T: Join {
        registerMigration(migrationName ?? T.joinMigrationName) { db in
            try db.create(table: tableName ?? T.tableName) { t in
                t.column(T.lhsReference, .integer).notNull()
                    .indexed()
                    .references(
                        T.Left.tableName,
                        onDelete: .cascade
                    )

                t.column(T.rhsReference, .integer).notNull()
                    .indexed()
                    .references(
                        T.Right.tableName,
                        onDelete: .cascade
                    )

                // Ensures unique relationships
                t.primaryKey([T.lhsReference, T.rhsReference])

                try finishDefining(t)
            }
        }
    }

    mutating func relate<T: RelationalJoin>(
        table: T.Type,
        relationship: KeyPath<T, T.Relationship>,
        finishDefining: @escaping (TableDefinition) throws -> Void = { _ in }
    ) {
        join(
            table: table,
            migrationName: String(describing: T.self),
            tableName: String(describing: T.self)
        ) { t in
            t.column(relationship.column, .text)
                .notNull()
                .check(
                    sql: inStatement(
                        value: relationship.column,
                        cases: T.Relationship.allCases.map(\.rawValue)
                    )
                )

            t.uniqueKey([T.lhsReference, T.rhsReference, relationship.column])

            try finishDefining(t)
        }
    }
}

private func inStatement(
    value: String,
    cases: [String]
) -> String {
    let quotedList = cases
        .map({ "'\($0)'" })
        .joined(separator: ", ")
    let parenthetical = "(\(quotedList))"
    return "\(value) in \(parenthetical)"
}

extension KeyPath {
    var column: String {
        "\(self)".components(separatedBy: ".").last ?? "\(self)"
    }
}

extension TableDefinition {
    @discardableResult
    public func column<S, T>(
        at name: KeyPath<S, T>,
        _ type: Database.ColumnType? = nil
    ) -> ColumnDefinition {
        column(name.column, type)
    }
}

extension DB {
    static func makeMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif

        // MARK: 1. Independent Tables (no foreign keys)
        migrator.create(table: Entry.self) { t in
            t.column(at: \Entry.createdAt, .datetime).notNull()
                .defaults(to: Date())
        }

        migrator.create(table: Language.self) { t in
            t.column(at: \Language.name, .text).unique().notNull()
            t.column(at: \Language.keyboardID, .text)
        }

        migrator.create(table: Spelling.self) { t in
            t.column(at: \Spelling.text, .text).notNull()
        }

        migrator.create(table: Definition.self) { t in
            t.column(at: \Definition.text, .text).notNull()
        }

        migrator.create(table: Usage.self) { t in
            t.column(at: \Usage.text, .text).notNull()
        }

        migrator.create(table: Keyword.self) { t in
            t.column(at: \Keyword.text, .text).notNull()
                .collate(.nocase)
                .unique()
            t.column(at: \Keyword.description, .text).notNull()
        }

        migrator.create(table: Pronunciation.self) { t in
            t.column(at: \Pronunciation.text, .text).notNull()
            t.column(at: \Pronunciation.audioURL, .text)
        }

        migrator.create(table: Image.self) { t in
            t.column(at: \Image.remote, .boolean).notNull()
            t.column(at: \Image.imageURL, .text)
        }

        migrator.create(table: Impression.self) { t in
            t.column(at: \Impression.mastery, .double).notNull()
            t.column(at: \Impression.type, .text).notNull()
            t.column(at: \Impression.datetime, .datetime).notNull()
        }

        // MARK: 2. Tables with Foreign Keys

        migrator.create(table: Note.self) { t in
            t.column(at: \Note.text, .text).notNull()
            t.column(at: \Note.entryID, .integer)
                .references(
                    Entry.tableName,
                    onDelete: .cascade
                )
        }

        // MARK: 3. RelationalJoins

        migrator.relate(table: Morphological.self, relationship: \.lhsIsA)
        migrator.relate(table: Etymological.self, relationship: \.lhsIsA)
        migrator.relate(table: Semantic.self, relationship: \.kind)
        migrator.relate(table: Phonetic.self, relationship: \.kind)
        migrator.relate(table: Orthographic.self, relationship: \.kind)

        // MARK: 3. Joins

        migrator.join(table: EntryLanguage.self)
        migrator.join(table: EntrySpelling.self)
        migrator.join(table: EntryDefinition.self)
        migrator.join(table: EntryUsage.self)
        migrator.join(table: EntryKeyword.self)
        migrator.join(table: EntryPronunciation.self)
        migrator.join(table: EntryImage.self)
        migrator.join(table: EntryImpression.self)

        // MARK: - Mocks
        #if DEBUG
        migrator.registerMigration("Add mock data") { db in
            try db.createMockData()
        }
        #endif

        return migrator
    }
}
