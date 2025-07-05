//
//  WordDetail+Request.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/3/25.
//

import SharingGRDB

extension WordDetail {
    struct Request: FetchKeyRequest {
        let id: DB.Entry.ID

        struct Value {
            var id: DB.Entry.ID { entry.id }
            var entry: DB.Entry
            var alternativeSpellings: [String] = []
            var additionalLanguages: [String] = []
            var translations: [DB.Entry] = []
            var notes: [DB.Entry.Note] = []
            var roots: [DB.Entry] = []
        }

        func fetch(_ db: Database) throws -> Value {
            guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }

            return Value(
                entry: entry,
                alternativeSpellings: try DB.Entry.Joins.EntryAdditionalSpelling
                    .where { entry.id.eq($0.entry) }
                    .join(DB.Entry.all) { $0.additionalSpelling.eq($1.id) }
                    .select { $1.spelling }
                    .distinct()
                    .fetchAll(db),
                additionalLanguages: try DB.Entry
                    .where { $0.spelling.eq(entry.spelling) && $0.language.neq(entry.language) }
                    .select { $0.language }
                    .distinct()
                    .fetchAll(db),
                translations: try DB.Semantic.Synonym
                    .where { $0.base.eq(entry.id) }
                    .join(DB.Entry.all) { $0.synonym.eq($1.id) }
                    .select { $1 }
                    .fetchAll(db),
                notes: try DB.Entry.Note
                    .where { entry.id.eq($0.entry) }
                    .fetchAll(db),
                roots: try DB.Etymology.Root
                    .where { entry.id.eq($0.base) }
                    .join(DB.Entry.all) { $0.base.eq($1.id) }
                    .select { _synonym, synonymEntry in synonymEntry }
                    .fetchAll(db)
            )
        }
    }
}
