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
            var language: DB.Language.Name
            var spelling: DB.Entry.Spelling
            var alternativeSpellings: [DB.Entry.Spelling] = []
            var additionalLanguages: [DB.Language.Name] = []
            var translations: [DB.Entry] = []
            var notes: [DB.Entry.Note] = []
            var roots: [DB.Entry] = []
        }

        func fetch(_ db: Database) throws -> Value {
            guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
            guard let language = try DB.Language.Name.find(entry.language).fetchOne(db) else { throw NoMatchFound.language }
            guard let spelling = try DB.Entry.Spelling.find(entry.spelling).fetchOne(db) else { throw NoMatchFound.spelling }

            return Value(
                entry: entry,
                language: language,
                spelling: spelling,
                alternativeSpellings: try DB.Entry.Joins.EntrySpelling
                    .where { entry.id.eq($0.entry) }
                    .join(DB.Entry.Spelling.all) { $0.spelling.eq($1.id) }
                    .select { $1 }
                    .fetchAll(db),
                additionalLanguages: try DB.Entry.Joins.EntryLanguage
                    .where { $0.entry.eq(entry.id) }
                    .join(DB.Language.Name.all) { $0.language.eq($1.code) }
                    .select { _, name in name }
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
