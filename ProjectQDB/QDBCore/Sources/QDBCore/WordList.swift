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

    @Dependency(\.locale) private var locale

    @Shared(.languageId) private var languageId
    @State private var searchText: String = ""
    @State private var order: SortOrder = .forward

    var body: some View {
        List {
            ForEach(searchResults) { result in
                Button {
                    onRowTapped(result.id)
                } label: {
                    Row(id: result.id)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .toolbar {
            Toolbar(languageId: Binding($languageId), order: $order)
        }
        .navigationTitle(pageTitle.capitalized)
        .searchable(text: $searchText, prompt: "Search \(description)")
        .task(id: [languageId, order, searchText] as [AnyHashable]) {
            try? await updateQuery()
        }
    }

    private var pageTitle: String {
        locale.languageName(of: languageId, native: true, capitalized: true) ?? "All Words"
    }

    private var description: String {
        "all\(locale.interpolatableLanguageName(of: languageId))words"
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

#Preview { let _ = DB.prepare()
    NavigationStack {
        WordList { _ in }
    }
}
