
@testable import QDBCore
import Foundation
import InlineSnapshotTesting
import StructuredQueries
import StructuredQueriesTestSupport
import Testing

import Dependencies
import StructuredQueries
import StructuredQueriesTestSupport

//func assertQuery<S: SelectStatement, each J: Table>(
//    _ query: S,
//    sql: (() -> String)? = nil,
//    results: (() -> String)? = nil,
//    fileID: StaticString = #fileID,
//    filePath: StaticString = #filePath,
//    function: StaticString = #function,
//    line: UInt = #line,
//    column: UInt = #column
//) where S.QueryValue == (), S.Joins == (repeat each J) {
//    @Dependency(\.defaultDatabase) var db
//    StructuredQueriesTestSupport.assertQuery(
//        query,
//        execute: db.execute,
//        sql: sql,
//        results: results,
//        snapshotTrailingClosureOffset: 0,
//        fileID: fileID,
//        filePath: filePath,
//        function: function,
//        line: line,
//        column: column
//    )
//}
//
//func assertQuery<each V: QueryRepresentable>(
//    _ query: some Statement<(repeat each V)>,
//    sql: (() -> String)? = nil,
//    results: (() -> String)? = nil,
//    fileID: StaticString = #fileID,
//    filePath: StaticString = #filePath,
//    function: StaticString = #function,
//    line: UInt = #line,
//    column: UInt = #column
//) {
//    @Dependency(\.defaultDatabase) var db
//    StructuredQueriesTestSupport.assertQuery(
//        query,
//        execute: db.execute,
//        sql: sql,
//        results: results,
//        snapshotTrailingClosureOffset: 0,
//        fileID: fileID,
//        filePath: filePath,
//        function: function,
//        line: line,
//        column: column
//    )
//}

@MainActor @Suite(.serialized, .snapshots(record: .failed)) struct MySchemaTests {}

extension MySchemaTests {
    @Test func basics() {
        assertQuery(
            DB.Entry
                .join(DB.Semantic.Synonym.all) { $0.id.eq($1.base) }
                .order { entry, synonym in (entry.recorded.desc(), synonym.base, synonym.synonym) }
                .select { ($0.id, $1.base) }
        )
    }

    @Test func createJoinTableStatement() {
        assertInlineSnapshot(
            of: CreateJoinTable(
                DB.Noun.Number.Singular.self,
                DB.Entry.self,
                DB.Entry.self,
                of: \.base,
                on: \.id,
                to: \.singular,
                id: \.id
            ).statement,
            as: .lines
        ) {
            """
            CREATE TABLE "singularNouns" (
              "base" INTEGER NOT NULL
                REFERENCES "entries"("id")
                ON DELETE CASCADE,
              "singular" INTEGER NOT NULL
                REFERENCES "entries"("id")
                ON DELETE CASCADE
            )
            """
        }
    }

    @Test func selectAllSynonyms() {
        assertQuery(DB.Semantic.Synonym.all)
    }

    @Test func entriesWithTranslations() {
        assertQuery(
            DB.Entry
                .join(DB.Semantic.Synonym.all) { $0.id.eq($1.base) }
                .select {
                    ($0.id, $1.synonym)
                }
                .group(by: { entry, matches in (entry.id, matches.synonym) })
            //                .order { entry, synonym in (entry.recorded.desc(), synonym.base, synonym.synonym) }
        ) {
            """
            SELECT "entries"."id", "synonyms"."synonym"
            FROM "entries"
            JOIN "synonyms" ON ("entries"."id" = "synonyms"."base")
            GROUP BY "entries"."id", "synonyms"."synonym"
            """
        } results: {
            """
            ┌──────┬──────┐
            │ 1    │ 100  │
            │ 1    │ 1000 │
            │ 2    │ 200  │
            │ 2    │ 2000 │
            │ 3    │ 300  │
            │ 3    │ 3000 │
            │ 100  │ 1    │
            │ 100  │ 1000 │
            │ 200  │ 2    │
            │ 200  │ 2000 │
            │ 300  │ 3    │
            │ 300  │ 3000 │
            │ 1000 │ 1    │
            │ 1000 │ 100  │
            │ 2000 │ 2    │
            │ 2000 │ 200  │
            │ 3000 │ 3    │
            │ 3000 │ 300  │
            └──────┴──────┘
            """
        }
    }

    //SELECT
    //    entries.id,
    //    entrySpellings.text,
    //    synonyms.synonym,
    //    synonymSpellings.text
    //FROM entries
    //LEFT JOIN entrySpellings ON entries.id = entrySpellings.id
    //LEFT JOIN synonyms ON entries.id = synonyms.id
    //LEFT JOIN entrySpellings synonymSpellings ON synonyms.synonym = synonymSpellings.id
    //ORDER BY entries.id, synonyms.synonym;
    @Test func entriesWithTranslationsRaw() {
        assertQuery(
            DB.Entry.all
                .leftJoin(DB.Entry.Spelling.all) { entries, entrySpellings in
                    entries.id.eq(entrySpellings.id)
                }
                .leftJoin(DB.Semantic.Synonym.all) { entries, _, synonyms in
                    entries.id.eq(synonyms.base)
                }
                .leftJoin(DB.Entry.Spelling.as(SynonymSpelling.self).all) { _, _, synonyms, synonymSpellings in
                    synonyms.synonym.eq(synonymSpellings.id)
                }
            //                .select { entries, entrySpellings, synonyms, synonymSpellings in
            //                    (entries.id, entrySpellings.text, synonyms.synonym, synonymSpellings.text)
            //                }
                .order(by: { entries, _, synonyms, _ in (entries.id, synonyms.synonym) })
        ) {
            """
            SELECT "entries"."id", "entries"."recorded", "spellings"."id", "spellings"."text", "synonyms"."base", "synonyms"."synonym", "synonymSpellings"."id", "synonymSpellings"."text"
            FROM "entries"
            LEFT JOIN "spellings" ON ("entries"."id" = "spellings"."id")
            LEFT JOIN "synonyms" ON ("entries"."id" = "synonyms"."base")
            LEFT JOIN "spellings" AS "synonymSpellings" ON ("synonyms"."synonym" = "synonymSpellings"."id")
            ORDER BY "entries"."id", "synonyms"."synonym"
            """
        }results: {
            """
            ┌────────────────────────────────────────────┬────────────────────┬──────────────────────┬────────────────────┐
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 1,                                   │   id: 1,           │   base: 1,           │   id: 100,         │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "hello"    │   synonym: 100       │   text: "hola"     │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 1,                                   │   id: 1,           │   base: 1,           │   id: 1000,        │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "hello"    │   synonym: 1000      │   text: "привіт"   │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 2,                                   │   id: 2,           │   base: 2,           │   id: 200,         │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "world"    │   synonym: 200       │   text: "mundo"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 2,                                   │   id: 2,           │   base: 2,           │   id: 2000,        │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "world"    │   synonym: 2000      │   text: "світ"     │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 3,                                   │   id: 3,           │   base: 3,           │   id: 300,         │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "goodbye"  │   synonym: 300       │   text: "adiós"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 3,                                   │   id: 3,           │   base: 3,           │   id: 3000,        │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "goodbye"  │   synonym: 3000      │   text: "пока"     │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 100,                                 │   id: 100,         │   base: 100,         │   id: 1,           │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "hola"     │   synonym: 1         │   text: "hello"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 100,                                 │   id: 100,         │   base: 100,         │   id: 1000,        │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "hola"     │   synonym: 1000      │   text: "привіт"   │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 200,                                 │   id: 200,         │   base: 200,         │   id: 2,           │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "mundo"    │   synonym: 2         │   text: "world"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 200,                                 │   id: 200,         │   base: 200,         │   id: 2000,        │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "mundo"    │   synonym: 2000      │   text: "світ"     │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 300,                                 │   id: 300,         │   base: 300,         │   id: 3,           │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "adiós"    │   synonym: 3         │   text: "goodbye"  │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 300,                                 │   id: 300,         │   base: 300,         │   id: 3000,        │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "adiós"    │   synonym: 3000      │   text: "пока"     │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 1000,                                │   id: 1000,        │   base: 1000,        │   id: 1,           │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "привіт"   │   synonym: 1         │   text: "hello"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 1000,                                │   id: 1000,        │   base: 1000,        │   id: 100,         │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "привіт"   │   synonym: 100       │   text: "hola"     │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 2000,                                │   id: 2000,        │   base: 2000,        │   id: 2,           │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "світ"     │   synonym: 2         │   text: "world"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 2000,                                │   id: 2000,        │   base: 2000,        │   id: 200,         │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "світ"     │   synonym: 200       │   text: "mundo"    │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 3000,                                │   id: 3000,        │   base: 3000,        │   id: 3,           │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "пока"     │   synonym: 3         │   text: "goodbye"  │
            │ )                                          │ )                  │ )                    │ )                  │
            ├────────────────────────────────────────────┼────────────────────┼──────────────────────┼────────────────────┤
            │ DB.Entry(                                  │ DB.Entry.Spelling( │ DB.Semantic.Synonym( │ DB.Entry.Spelling( │
            │   id: 3000,                                │   id: 3000,        │   base: 3000,        │   id: 300,         │
            │   recorded: Date(0001-01-01T00:00:00.000Z) │   text: "пока"     │   synonym: 300       │   text: "adiós"    │
            │ )                                          │ )                  │ )                    │ )                  │
            └────────────────────────────────────────────┴────────────────────┴──────────────────────┴────────────────────┘
            """
        }
    }
}

enum SynonymSpelling: AliasName {}
