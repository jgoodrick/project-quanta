//
//  DB_Entry_Match.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/16/25.
//

import Sharing
import SQLiteData

package extension Entry {
    @Selection
    struct Match: Hashable, Identifiable {
        package var id: Entry.ID { match.id }
        var match: Entry
        @Column(as: [Entry.ID].JSONRepresentation.self)
        var translations: [Entry.ID]
    }
}

package extension Entry.Match {
    static func all(against word: String, languageId: String) -> some StructuredQueriesCore.Statement<Entry.Match> {
        Entry.all
            .group(by: \.id)
            .where { entry in
                entry.spelling.collate(.nocase).like(word).and(entry.language.eq(languageId))
            }
            .join(Semantic.Synonym.all) { entry, join in join.base.eq(entry.id) }
            .join(Entry.as(TranslationEntry.self).all) { entry, join, joined in join.synonym.eq(joined.id) }
            .order(by: \.recorded)
            .select { entry, _, translation in
                Entry.Match.Columns(
                    match: entry,
                    translations: translation.id.jsonGroupArray(distinct: true)
                )
            }
    }
    
    static func firstMatch(for submitted: String) -> Entry.ID? {
        @Shared(.languageId) var languageId
        @Dependency(\.defaultDatabase) var database
        return try? database.read { db in
            try Entry.Match.all(against: submitted, languageId: languageId).fetchAll(db)
        }.first?.id
    }
}
