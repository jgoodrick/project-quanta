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

    @FetchAll var spellingMatches: [SpellingMatch]

    @State private var languageId: String = .currentLanguageId()

    @FetchAll var availableLanguageNames: [DB.Language.Name]

    @State private var selectedTranslationLanguageIds: [DB.Language.Name.ID] = {
        @Shared(.lastSelectedTranslationLanguageId) var lastSelected
        return [lastSelected]
    }()

    @Dependency(\.defaultDatabase) private var db

    init(word: String = "") {
        self._word = .init(initialValue: word)
    }

    var selectedTranslations: [DB.Language.Name] {
        availableLanguageNames.filter { selectedTranslationLanguageIds.contains($0.code) }
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

            if !spellingMatches.isEmpty {
//                ForEach(selectedTranslations.indices, id: \.self) { index in
//                    let language = selectedTranslations[index]
//                    if language.id != languageId {
//                        ProposedTranslation(
//                            language: language,
//                            text: 
//                        )
//                    }
//                }
            }
        }
        .toolbar {
            if spellingMatches.isEmpty {
                Button("Save") {
                    withErrorReporting {
                        try db.write { db in
                        }
                    }
                }
            }
        }
        .task(id: word) {
            try? await updateQuery()
        }
        .navigationTitle(spellingMatches.isEmpty ? "Add" : "Update")
    }


    @Selection
    struct SpellingMatch: Hashable, Identifiable {
        var id: DB.Entry.ID { entry.id }
        var entry: DB.Entry
        var exact: Bool
    }

    private func updateQuery() async throws {
        try await $spellingMatches.load(
            DB.Entry
                .group(by: \.id)
                .join(DB.Language.Name.all) { $0.language.eq($1.code) }
                .where { $1.primaryKey.eq(languageId) }
                .join(DB.Entry.Spelling.all) { $0.spelling.eq($2.id) }
                .where { _, _, spelling in
                    spelling.text.collate(.nocase).like(word)
                }
                .order { entry, languageName, spelling in
                    (languageName.code.eq(languageId), entry.recorded)
                }
                .select { entry, _, _ in
                    SpellingMatch.Columns.init(
                        entry: entry,
                        exact: false
                    )
                }
                .distinct(true)
        )
    }

}

extension String {
    static func currentLanguageId() -> Self {
        @Dependency(\.locale) var locale
        return locale.language.minimalIdentifier
    }
}

struct ProposedTranslation: View {
    let language: DB.Language.Name
    @Binding var text: String

    var body: some View {
        Section(language.text) {
            TextField(language.text, text: $text)
                .font(.largeTitle)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        NewEntryForm(word: "hello")
    }
}
