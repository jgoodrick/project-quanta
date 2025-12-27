//
//  NewEntryForm.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 6/29/25.
//

import CoreDB
import Dependencies
import SQLiteData
import Sharing
import SwiftUI
import UIComponents

struct NewEntryForm: View {
    @State private var word = ""

    @FetchAll var matches: [CoreDB.Entry.Match]

    @State private var languageId: String = {
        @Shared(.languageId) var current
        return current
    }()

    @State private var newTranslations: [TranslationDraft.Model]

    @Dependency(\.defaultDatabase) private var database
    @Dependency(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    init(
        word: String = {
            @Shared(.sharedEntryText) var sharedEntryText
            return sharedEntryText
        }(),
        languageId: String = {
            @Shared(.languageId) var languageId
            return languageId
        }(),
        firstNewTranslationLangaugeId: String = {
            @Dependency(\.defaultDatabase) var db
            let available = (try? db.read { db in try CoreDB.Entry.all.select(\.language).distinct().fetchAll(db) }) ?? []
            @Shared(.languageId) var languageId
            return available.first(where: { $0 != languageId }) ?? languageId
        }()
    ) {
        self._word = .init(initialValue: word)
        self._matches = FetchAll(CoreDB.Entry.Match.all(against: word, languageId: languageId))
        self._newTranslations = .init(initialValue: [.init(languageId: firstNewTranslationLangaugeId)])
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Spelling", text: $word)
                        .font(.largeTitle)
                        .textFieldStyle(.roundedBorder)
                        .layoutPriority(1)

                    LanguagePicker(
                        languageId: $languageId,
                        availableLanguageNames: [:],
                        locale: locale
                    )
                    .frame(minWidth: 100)
                }
                .labelsHidden()
            } header: {
                Text("New word")
            }

            // existing translations

//            if let existingMatch = matches.first, let existingTranslations = existingMatch.translations, !existingTranslations.isEmpty {
//                ForEach(existingTranslations, id: \.self) { translationEntryId in
//                    try? ExistingTranslation(id: translationEntryId)
//                }
//            }

            // New translations

            ForEach(newTranslations) { model in
                TranslationDraft(model: model)
            }
        }
        .toolbar {
            if matches.isEmpty {
                Button("Save", action: save)
            }
        }
        .task(id: word) {
            try? await updateMatchesQuery()
        }
        .navigationTitle(matches.isEmpty ? "Add" : "Duplicate")
    }

    func save() {
        withErrorReporting {
            let matches: Int = try database.read { db in
                try CoreDB.Entry
                    .where { $0.spelling.eq(word) }
                    .select { $0.count() }
                    .fetchOne(db) ?? 0
            }
            guard matches == 0 else { return }
            try database.write { db in
                try CoreDB.Entry.upsert {
                    CoreDB.Entry.Draft(
                        spelling: word,
                        language: languageId,
                        recorded: .now
                    )
                }.execute(db)
            }
            dismiss()
        }
    }

    private func updateMatchesQuery() async throws {
        try await $matches.load(CoreDB.Entry.Match.all(against: word, languageId: languageId))
    }

    struct ExistingTranslation: View {
        let entry: CoreDB.Entry
        @State var text: String

        @Dependency(\.locale) private var locale

        init(id: CoreDB.Entry.ID) throws {
            @Dependency(\.defaultDatabase) var db
            guard let entry = try db.read({ db in try CoreDB.Entry.find(id).fetchOne(db) }) else { throw NoMatchFound.entry }
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

struct TranslationDraft: View {
    @Bindable var model: Model

    @Observable
    class Model: Identifiable {
        let id: UUID
        var draft: CoreDB.Entry.Draft

        @ObservationIgnored
        @Dependency(\.locale) private var locale

        init(id: UUID? = nil, languageId: String) {
            @Dependency(\.uuid) var uuid
            self.id = id ?? uuid()
            self.draft = CoreDB.Entry.Draft(
                spelling: "",
                language: languageId,
                recorded: .now
            )
        }

        var languageName: String {
            locale.languageName(
                of: draft.language,
                native: false,
                capitalized: true
            ) ?? "New"
        }
    }

    var body: some View {
        HStack {
            TextField("\(model.languageName) translation", text: $model.draft.spelling)
                .font(.subheadline)
                .textFieldStyle(.roundedBorder)
                .layoutPriority(1)

            LanguagePicker(
                languageId: $model.draft.language,
                availableLanguageNames: [:],
                locale: .current
            )
            .frame(minWidth: 100)
        }
        .labelsHidden()
    }
}

#Preview { let _ = CoreDB.prepareDatabase()
    NavigationStack {
        NewEntryForm(word: "quite")
            .navigationTitle("New Word")
    }
}
