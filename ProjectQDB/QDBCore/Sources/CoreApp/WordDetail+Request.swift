//
//  WordDetail+Request.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/3/25.
//

import CoreDB
import CoreUI
import SQLiteData
import UIComponents

extension WordDetail {
    struct Request: FetchKeyRequest {
        let id: CoreDB.Entry.ID

        struct Value {
            var id: CoreDB.Entry.ID { entry.id }
            var entry: CoreDB.Entry
            var alternativeSpellings: [String] = []
            var additionalLanguages: [String] = []
            var translations: [CoreDB.Entry] = []
            var notes: [CoreDB.Entry.Note] = []
            var roots: [CoreDB.Entry] = []
        }
        
        enum NoMatchFound: Error { case entry }

        func fetch(_ db: Database) throws -> Value {
            guard let entry = try CoreDB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }

            return Value(
                entry: entry,
                alternativeSpellings: try CoreDB.Entry.Joins.EntryAdditionalSpelling
                    .where { entry.id.eq($0.entry) }
                    .join(CoreDB.Entry.all) { $0.additionalSpelling.eq($1.id) }
                    .select { $1.spelling }
                    .distinct()
                    .fetchAll(db),
                additionalLanguages: try CoreDB.Entry
                    .where { $0.spelling.eq(entry.spelling) && $0.language.neq(entry.language) }
                    .select { $0.language }
                    .distinct()
                    .fetchAll(db),
                translations: try CoreDB.Semantic.Synonym
                    .where { $0.base.eq(entry.id) }
                    .join(CoreDB.Entry.all) { $0.synonym.eq($1.id) }
                    .select { $1 }
                    .fetchAll(db),
                notes: try CoreDB.Entry.Note
                    .where { entry.id.eq($0.entry) }
                    .fetchAll(db),
                roots: try CoreDB.Etymology.Root
                    .where { entry.id.eq($0.base) }
                    .join(CoreDB.Entry.all) { $0.base.eq($1.id) }
                    .select { _synonym, synonymEntry in synonymEntry }
                    .fetchAll(db)
            )
        }
    }
}
