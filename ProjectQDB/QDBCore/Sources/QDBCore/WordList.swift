//
//  WordListController.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import SwiftUI
import SwiftUINavigation

struct WordList: View {
    let onRowTapped: (DB.Entry.ID) -> Void

    @FetchAll var searchResults: [Search]
    @FetchAll var availableLanguageNames: [DB.Language.Name]

    @State private var languageId: DB.Language.Name.ID = DB.Language.Name.BuiltIn.en.rawValue
    @State private var searchText: String = ""
    @State private var order: SortOrder = .reverse

    @Dependency(\.locale) private var locale

    var body: some View {
        List {
            ForEach(searchResults) { result in
                Button {
                    onRowTapped(result.id)
                } label: {
                    Row(id: result.id)
                }
            }
        }
        .toolbar {
            Button {
                print("tapped add word button")
            } label: {
                Image(systemName: "plus")
            }

            Button {
                if order == .forward {
                    order = .reverse
                } else {
                    order = .forward
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
            }

            Menu {
                ForEach(availableLanguageNames) { languageName in
                    Button {
                        languageId = languageName.id
                    } label: {
                        Text(name(of: languageName))
                    }
                }
            } label: {
                Image(systemName: "flag")
            }
        }
        .navigationTitle("Words")
        .searchable(text: $searchText)
        .task(id: [languageId, order, searchText] as [AnyHashable]) {
            try? await updateQuery()
        }
    }

    func name(of language: DB.Language.Name) -> String {
        let fallback = language.text
        let localized = locale.localizedString(forIdentifier: language.id)?.capitalized(with: locale)
        let nativeLocale = Locale(identifier: language.id)
        let native = nativeLocale.localizedString(forIdentifier: language.id)?.capitalized(with: nativeLocale)
        return (native ?? localized ?? fallback)
    }

    @Selection
    struct Search: Hashable, Identifiable {
        var id: DB.Entry.ID { entryID }
        var entryID: DB.Entry.ID
        var languageName: String
        var spelling: String
    }

    private func updateQuery() async throws {
        try await $searchResults.load(
            DB.Entry
                .group(by: \.id)
                .join(DB.Language.Name.all) { $0.language.eq($1.code) }
                .where { $1.primaryKey.eq(languageId) }
                .join(DB.Entry.Spelling.all) { $0.spelling.eq($2.id) }
                .where { _, _, spelling in
                    spelling.text.fuzzy(match: searchText)
                }
                .order { _, _, spelling in
                    if !searchText.isEmpty {
                        (spelling.text.instr(searchText), spelling.text.length())
                    } else {
                        if order == .forward {
                            spelling.text.lower()
                        } else {
                            spelling.text.lower().desc()
                        }
                    }
                }
                .select { entry, spelling, language in
                    Search.Columns.init(
                        entryID: entry.id,
                        languageName: language.text,
                        spelling: spelling.text
                    )
                }
                .distinct(true)
        )
    }
}

extension WordList {
    struct Row: View {
        let id: DB.Entry.ID

        var body: some View {
            Load(request) { value in
                Content(
                    spelling: value.spelling.text,
                    translations: value.synonyms.map(\.spelling.text)
                )
            }
        }

        struct Content: View {
            let spelling: String
            let translations: [String]

            var body: some View {
                VStack(alignment: .leading) {
                    Text(spelling)
                        .font(.headline)

                    Spacer()

                    HStack {
                        ForEach(translations.enumerated().map(\.self), id: \.0) { (index, translation) in
                            Text(translation)
                        }
                    }
                    .font(.caption)
                }
                .padding()
            }
        }

        var request: Request { .init(id: id) }

        struct Request: FetchKeyRequest {
            let id: DB.Entry.ID
            struct Value {
                var entry: DB.Entry
                var spelling: DB.Entry.Spelling
                var language: DB.Language.Name
                var synonyms: [Synonym]

                struct Synonym {
                    let entry: DB.Entry.ID
                    let spelling: DB.Entry.Spelling
                }
            }
            enum NoMatchFound: Error {
                case entry
                case spelling
                case language
            }
            func fetch(_ db: Database) throws -> Value {
                guard let entry = try DB.Entry.find(id).fetchOne(db) else { throw NoMatchFound.entry }
                guard let spelling = try DB.Entry.Spelling.find(entry.spelling).fetchOne(db) else { throw NoMatchFound.spelling }
                guard let language = try DB.Language.Name.find(entry.language).fetchOne(db) else { throw NoMatchFound.language }
                let synonyms = try DB.Semantic.Synonym.where({ $0.synonym.eq(id) }).fetchAll(db).compactMap { (syn) -> Value.Synonym? in
                    guard let spelling = try DB.Entry.Spelling.find(syn.base).fetchOne(db) else { return nil }
                    return Value.Synonym(
                        entry: syn.base,
                        spelling: spelling
                    )
                }
                return Value(
                    entry: entry,
                    spelling: spelling,
                    language: language,
                    synonyms: synonyms
                )
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        WordList { _ in }
    }
}
