//
//  DB_Entry_Tests.swift
//  CoreDB
//
//  Created by Goodrick,Joseph on 6/25/25.
//

@testable import CoreDB
import Dependencies
import DependenciesTestSupport
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import StructuredQueriesTestSupport
import Testing

@Suite(
    .serialized,
    .snapshots(record: .failed),
    .dependencies {
        $0.defaultDatabase = try! CoreDB.appDatabase()
        $0.uuid = .incrementing
    }
)
struct EntryTests {
    @Dependency(\.defaultDatabase) var db

//    @Test func basics() throws {
//        assertQuery(CoreDB.Entry.Row.all) { statement in
//            try db.read {
//                try statement.fetchAll($0)
//            }
//        } sql: {
//            """
//            SELECT "entries"."id" AS "entryID", "languageNames"."text" AS "languageName", "spellings"."text" AS "spelling", json_group_array(CASE WHEN ("keywords"."id" IS NOT NULL) THEN json_object('id', json_quote("keywords"."id"), 'text', json_quote("keywords"."text"), 'description', json_quote("keywords"."description")) END) AS "keywords"
//            FROM "entries"
//            JOIN "spellings" ON ("entries"."spelling" = "spellings"."id")
//            JOIN "languageNames" ON ("entries"."language" = "languageNames"."code")
//            LEFT JOIN "entryKeywords" ON ("entries"."id" = "entryKeywords"."entry")
//            JOIN "keywords" ON ("entryKeywords"."keyword" = "keywords"."id")
//            GROUP BY "entries"."id"
//            """
//        } results: {
//            """
//            ┌────────────────────────────────────────────────────────────────────────────┐
//            │ DB.Entry.Row(                                                              │
//            │   entryID: 1,                                                              │
//            │   languageName: "English",                                                 │
//            │   spelling: "hello",                                                       │
//            │   keywords: [                                                              │
//            │     [0]: DB.Entry.Keyword(                                                 │
//            │       id: 10000,                                                           │
//            │       text: "greeting",                                                    │
//            │       description: "said when meeting someone"                             │
//            │     ),                                                                     │
//            │     [1]: DB.Entry.Keyword(                                                 │
//            │       id: 30000,                                                           │
//            │       text: "interjection",                                                │
//            │       description: "greeting, emotion, or reaction, often standing alone." │
//            │     )                                                                      │
//            │   ]                                                                        │
//            │ )                                                                          │
//            ├────────────────────────────────────────────────────────────────────────────┤
//            │ DB.Entry.Row(                                                              │
//            │   entryID: 3,                                                              │
//            │   languageName: "English",                                                 │
//            │   spelling: "goodbye",                                                     │
//            │   keywords: [                                                              │
//            │     [0]: DB.Entry.Keyword(                                                 │
//            │       id: 20000,                                                           │
//            │       text: "farewell",                                                    │
//            │       description: "said when departing"                                   │
//            │     ),                                                                     │
//            │     [1]: DB.Entry.Keyword(                                                 │
//            │       id: 30000,                                                           │
//            │       text: "interjection",                                                │
//            │       description: "greeting, emotion, or reaction, often standing alone." │
//            │     )                                                                      │
//            │   ]                                                                        │
//            │ )                                                                          │
//            ├────────────────────────────────────────────────────────────────────────────┤
//            │ DB.Entry.Row(                                                              │
//            │   entryID: 4,                                                              │
//            │   languageName: "English",                                                 │
//            │   spelling: "see you later",                                               │
//            │   keywords: [                                                              │
//            │     [0]: DB.Entry.Keyword(                                                 │
//            │       id: 20000,                                                           │
//            │       text: "farewell",                                                    │
//            │       description: "said when departing"                                   │
//            │     ),                                                                     │
//            │     [1]: DB.Entry.Keyword(                                                 │
//            │       id: 30000,                                                           │
//            │       text: "interjection",                                                │
//            │       description: "greeting, emotion, or reaction, often standing alone." │
//            │     )                                                                      │
//            │   ]                                                                        │
//            │ )                                                                          │
//            └────────────────────────────────────────────────────────────────────────────┘
//            """
//        }
//    }
}
