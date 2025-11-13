//
//  WordListController.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SQLiteData
import SwiftUI
import SwiftUINavigation

struct WordList: View {
    let onRowTapped: (DB.Entry.ID) -> Void

    @FetchAll var searchResults: [DB.Entry]

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

    private func updateQuery() async throws {
        try await $searchResults.load(
            DB.Entry.all
                .where {
                    $0.language.eq(languageId)
                }
                .where {
                    $0.spelling.fuzzy(match: searchText)
                }
                .order { entry in
                    if !searchText.isEmpty {
                        (entry.spelling.instr(searchText), entry.spelling.length())
                    } else {
                        if order == .forward {
                            entry.spelling.lower()
                        } else {
                            entry.spelling.lower().desc()
                        }
                    }
                }
                .select { $0 }
                .distinct(true)
        )
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        WordList { _ in }
    }
}
