//
//  NewEntryForm.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 6/29/25.
//

import Dependencies
import SharingGRDB
import SwiftUI

struct NewEntryForm: View {
    @State private var word = ""

    @FetchAll var matches: [Match]

    @State private var languageId: String = {
        @Shared(.languageId) var current
        return current
    }()

    @Dependency(\.defaultDatabase) private var db

    init(word: String = "") {
        self._word = .init(initialValue: word)
    }

    var body: some View {
        Form {
            Section {
                TextField("Word", text: $word)
                    .font(.largeTitle)
                    .textFieldStyle(.roundedBorder)

                LanguagePicker(languageId: $languageId)
                    .pickerStyle(.navigationLink)
            }

            if let existingTranslations = matches.first?.translations, !existingTranslations.isEmpty {
                ForEach(existingTranslations, id: \.self) { translationEntryId in
                    try? ExistingTranslation(id: translationEntryId)
                }
            }
        }
        .toolbar {
            if matches.isEmpty {
                Button("Save") {
                    withErrorReporting {
                        try db.write { db in
                            try DB.Entry.upsert {
                                DB.Entry.Draft(
                                    spelling: word,
                                    language: languageId,
                                    recorded: .now
                                )
                            }.execute(db)
                        }
                    }
                }
            }
        }
        .task(id: word) {
            try? await updateMatchesQuery()
        }
        .navigationTitle(matches.isEmpty ? "Add" : "Duplicate")
    }


    @Selection
    struct Match: Hashable, Identifiable {
        var id: DB.Entry.ID { match.id }
        var match: DB.Entry
        @Column(as: [DB.Entry.ID].JSONRepresentation.self)
        var translations: [DB.Entry.ID]
    }

    private func updateMatchesQuery() async throws {
        try await $matches.load(
            DB.Entry.all
                .where { entry in
                    entry.spelling.collate(.nocase).like(word).and(entry.language.eq(languageId))
                }
                .join(DB.Semantic.Synonym.all) { entry, x in x.base.eq(entry.id) }
                .join(DB.Entry.as(TranslationEntry.self).all) { entry, join, joined in join.synonym.eq(joined.id) }
                .order(by: \.recorded)
                .select { entry, _, translation in
                    Match.Columns(
                        match: entry,
                        translations: translation.id.jsonGroupArray(isDistinct: true)
                    )
                }
        )
    }

    struct ExistingTranslation: View {
        let entry: DB.Entry
        @State var text: String

        @Dependency(\.locale) private var locale

        init(id: DB.Entry.ID) throws {
            @Dependency(\.defaultDatabase) var db
            guard let entry = try db.read({ db in try DB.Entry.find(id).fetchOne(db) }) else { throw NoMatchFound.entry }
            self.entry = entry
            self._text = .init(initialValue: entry.spelling)
        }

        var body: some View {
            Section(locale.interpolatableLanguageName(of: entry.language, native: true, capitalized: true)) {
                TextField("Add a\(locale.interpolatableLanguageName(of: entry.language))translation", text: $text)
                    .font(.title)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        NewEntryForm(word: "hello")
    }
}
