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

    @State private var newTranslations: [TranslationDraft.Model]

    @Dependency(\.defaultDatabase) private var db
    @Dependency(\.locale) private var locale
    @Environment(\.dismiss) private var dismiss

    init(
        word: String = "",
        languageId: String = {
            @Shared(.languageId) var languageId
            return languageId
        }(),
        firstNewTranslationLangaugeId: String = {
            @Dependency(\.defaultDatabase) var db
            let available = (try? db.read { db in try DB.Entry.all.select(\.language).distinct().fetchAll(db) }) ?? []
            @Shared(.languageId) var languageId
            return available.first(where: { $0 != languageId }) ?? languageId
        }()
    ) {
        self._word = .init(initialValue: word)
        self._matches = FetchAll(Match.all(against: word, languageId: languageId))
        self._newTranslations = .init(initialValue: [.init(languageId: firstNewTranslationLangaugeId)])
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

            // existing translations

            if let existingTranslations = matches.first?.translations, !existingTranslations.isEmpty {
                ForEach(existingTranslations, id: \.self) { translationEntryId in
                    try? ExistingTranslation(id: translationEntryId)
                }
            }

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
            let matches: Int = try db.read { db in
                try DB.Entry
                    .where { $0.spelling.eq(word) }
                    .select { $0.count() }
                    .fetchOne(db) ?? 0
            }
            guard matches == 0 else { return }
            try db.write { db in
                try DB.Entry.upsert {
                    DB.Entry.Draft(
                        spelling: word,
                        language: languageId,
                        recorded: .now
                    )
                }.execute(db)
            }
            dismiss()
        }
    }

    @Selection
    struct Match: Hashable, Identifiable {
        var id: DB.Entry.ID { match.id }
        var match: DB.Entry
        @Column(as: [DB.Entry.ID].JSONRepresentation.self)
        var translations: [DB.Entry.ID]

        static func all(against word: String, languageId: String) -> some StructuredQueriesCore.Statement<NewEntryForm.Match> {
            DB.Entry.all
                .where { entry in
                    entry.spelling.collate(.nocase).like(word).and(entry.language.eq(languageId))
                }
                .join(DB.Semantic.Synonym.all) { entry, x in x.base.eq(entry.id) }
                .join(DB.Entry.as(TranslationEntry.self).all) { entry, join, joined in join.synonym.eq(joined.id) }
                .order(by: \.recorded)
                .select { entry, _, translation in
                    NewEntryForm.Match.Columns(
                        match: entry,
                        translations: translation.id.jsonGroupArray(isDistinct: true)
                    )
                }
        }
    }

    private func updateMatchesQuery() async throws {
        try await $matches.load(Match.all(against: word, languageId: languageId))
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

struct TranslationDraft: View {
    @Bindable var model: Model

    @Observable
    class Model: Identifiable {
        let id: UUID
        var draft: DB.Entry.Draft

        @ObservationIgnored
        @Dependency(\.locale) private var locale

        init(id: UUID? = nil, languageId: String) {
            @Dependency(\.uuid) var uuid
            self.id = id ?? uuid()
            self.draft = DB.Entry.Draft(
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
        TextField(
            "\(model.languageName) translation",
            text: $model.draft.spelling
        )
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        NewEntryForm(word: "quite")
    }
}
