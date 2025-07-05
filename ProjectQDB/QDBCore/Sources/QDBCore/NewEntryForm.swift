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

    @FetchAll var availableLanguageNames: [String]

    @State private var selectedTranslationLanguageIds: [String] = {
        @Shared(.lastSelectedTranslationLanguageId) var lastSelected
        return [lastSelected]
    }()

    @Dependency(\.defaultDatabase) private var db

    init(word: String = "") {
        self._word = .init(initialValue: word)
    }

    var selectedTranslations: [String] {
        availableLanguageNames.filter { selectedTranslationLanguageIds.contains($0) }
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
                .where { entry in
                    entry.spelling.collate(.nocase).like(word)
                }
                .order { entry in
                    (entry.language.eq(languageId), entry.recorded)
                }
                .select { entry in
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
    let language: String
    @Binding var text: String

    var body: some View {
        Section(language) {
            TextField(language, text: $text)
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
