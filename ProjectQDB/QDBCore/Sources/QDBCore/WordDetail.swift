//
//  WordDetail.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import SwiftUI
import SwiftUINavigation

extension Database {
    func fetchAllSlimEntries() throws -> [DB.Entry.Slim.Value] {
        try DB.Entry.all.fetchAll(self).map(\.id).map(fetchSlimEntry(for:))
    }
    func fetchSlimEntry(for id: DB.Entry.ID) throws -> DB.Entry.Slim.Value {
        try DB.Entry.Slim(entry: id).fetch(self)
    }
    func fetchEntry(for id: DB.Entry.ID) throws -> DB.Entry {
        let result = try DB.Entry.where({ id.eq($0.id) }).fetchOne(self)
        guard let result else { throw NotFound() }
        return result
    }
    func fetchSpelling(for id: DB.Entry.Spelling.ID) throws -> DB.Entry.Spelling {
        let result = try DB.Entry.Spelling.where({ id.eq($0.id) }).fetchOne(self)
        guard let result else { throw NotFound() }
        return result
    }
    func fetchLanguage(for code: DB.Language.Name.ID) throws -> DB.Language.Name {
        let result = try DB.Language.Name.where({ code.eq($0.code) }).fetchOne(self)
        guard let result else { throw NotFound() }
        return result
    }
}


extension DB.Entry {
    struct Slim: FetchKeyRequest {
        struct Value: Identifiable {
            var id: DB.Entry.ID { entry.id }
            var entry: DB.Entry
            var language: DB.Language.Name
            var spelling: DB.Entry.Spelling
        }

        let entry: DB.Entry.ID

        func fetch(_ db: Database) throws -> Value {
            let entry = try db.fetchEntry(for: entry)
            let language = try db.fetchLanguage(for: entry.language)
            let spelling = try db.fetchSpelling(for: entry.spelling)

            return Value(
                entry: entry,
                language: language,
                spelling: spelling
            )
        }

        static let all: All = .init()
        
        struct All: FetchKeyRequest {
            func fetch(_ db: Database) throws -> [DB.Entry.Slim.Value] {
                try db.fetchAllSlimEntries()
            }
        }
    }

    struct Full: FetchKeyRequest {
        struct Value {
            let slim: Slim.Value
            var alternativeSpellings: [DB.Entry.Spelling] = []
            var additionalLanguages: [DB.Language.Name] = []
            var translations: [Slim.Value] = []
            var notes: [DB.Entry.Note] = []
            var roots: [DB.Entry] = []

            var entry: DB.Entry { slim.entry }
            var language: DB.Language.Name { slim.language }
            var spelling: DB.Entry.Spelling { slim.spelling }
        }

        struct Draft {
            let entry: DB.Entry.Draft
            var spelling: DB.Entry.Spelling.Draft
            var language: DB.Language.Name
        }

        let entry: DB.Entry.ID

        func fetch(_ db: Database) throws -> Value {
            Value(
                slim: try Slim(entry: entry).fetch(db),
                alternativeSpellings: try DB.Entry.Joins.EntrySpelling
                    .where { entry.eq($0.entry) }
                    .join(DB.Entry.Spelling.all) { $0.spelling.eq($1.id) }
                    .select { _entrySpelling, spelling in spelling }
                    .fetchAll(db),
                additionalLanguages: try DB.Entry.Joins.EntryLanguage
                    .where { $0.entry.eq(entry) }
                    .join(DB.Language.Name.all) { $0.language.eq($1.code) }
                    .select { _, name in name }
                    .fetchAll(db),
                translations: try DB.Semantic.Synonym
                    .where { $0.base.eq(entry) }
                    .select { $0.synonym }
                    .fetchAll(db)
                    .map { try Slim(entry: $0).fetch(db) },
                notes: try DB.Entry.Note
                    .where { entry.eq($0.entry) }
                    .fetchAll(db),
                roots: try DB.Etymology.Root
                    .where { entry.eq($0.base) }
                    .join(DB.Entry.all) { $0.base.eq($1.id) }
                    .select { _synonym, synonymEntry in synonymEntry }
                    .fetchAll(db)
            )
        }
    }
}

@Observable
final class WordDetailController: HashableObject {
    init(slim: DB.Entry.Slim.Value) {
        self.slim = slim
        _full = SharedReader(
            wrappedValue: DB.Entry.Full.Value(slim: slim),
            .fetch(DB.Entry.Full(entry: slim.entry.id), animation: .default)
        )
    }

    let slim: DB.Entry.Slim.Value

    @ObservationIgnored @SharedReader
    var full: DB.Entry.Full.Value
}


struct WordDetail: View {
    @Bindable var controller: WordDetailController

    var entry: DB.Entry.Full.Value {
        controller.full
    }

    var body: some View {
        VStack {
            Text("Entry Detail")
            Text(entry.spelling.text)
                .padding()
            Translations(entries: entry.translations)
        }
    }

    struct Translations: View {
        let entries: [DB.Entry.Slim.Value]
        var body: some View {
            List(entries, id: \.id) { entry in
                HStack {
                    Text("\(entry.language.text) - ")
                    Text(entry.spelling.text)
                }
            }
        }
    }
}

#Preview {
    WordDetail(
        controller: .init(
            slim: .init(
                entry: Mock.entry,
                language: Mock.language,
                spelling: Mock.spelling
            )
        )
    )
}

private extension Mock {
    static let entry: DB.Entry = .init(
        id: 0,
        spelling: 0,
        language: "en",
        recorded: .now
    )
    static let language: DB.Language.Name = .init(
        code: "en",
        text: "English"
    )
    static let spelling: DB.Entry.Spelling = .init(
        id: 0,
        text: "Hello!"
    )
}
