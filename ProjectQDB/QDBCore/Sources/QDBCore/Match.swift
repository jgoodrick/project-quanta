//
//  DB_Entry_Match.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/16/25.
//

import SQLiteData

extension DB.Entry {
    @Selection
    struct Match: Hashable, Identifiable {
        var id: DB.Entry.ID { match.id }
        var match: DB.Entry
        @Column(as: [DB.Entry.ID].JSONRepresentation.self)
        var translations: [DB.Entry.ID]

        static func all(against word: String, languageId: String) -> some StructuredQueriesCore.Statement<DB.Entry.Match> {
            DB.Entry.all
                .group(by: \.id)
                .where { entry in
                    entry.spelling.collate(.nocase).like(word).and(entry.language.eq(languageId))
                }
                .join(DB.Semantic.Synonym.all) { entry, join in join.base.eq(entry.id) }
                .join(DB.Entry.as(TranslationEntry.self).all) { entry, join, joined in join.synonym.eq(joined.id) }
                .order(by: \.recorded)
                .select { entry, _, translation in
                    DB.Entry.Match.Columns(
                        match: entry,
                        translations: translation.id.jsonGroupArray(distinct: true)
                    )
                }
        }

        static func firstMatch(for submitted: String) -> DB.Entry.ID? {
            @Shared(.languageId) var languageId
            @Dependency(\.defaultDatabase) var database
            return try? database.read { db in
                try DB.Entry.Match.all(against: submitted, languageId: languageId).fetchAll(db)
            }.first?.id
        }
    }
}
