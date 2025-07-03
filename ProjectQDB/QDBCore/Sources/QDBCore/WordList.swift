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

    @State private var languageId: DB.Language.Name.ID = DB.Language.Name.BuiltIn.en.rawValue
    @State private var searchText: String = ""
    @State private var order: SortOrder = .forward
    @State private var newWordText: String = ""
    @State private var newWordFieldFocused = false

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
        .modifier(
            ToolbarTextFieldInstaller(
                placeholder: "Add a new word",
                languageIdentifier: "uk_UA",
                fieldStyle: .defaultValue,
                text: $newWordText,
                focused: $newWordFieldFocused,
                installed: true,
                actions: .noop
            )
        )
        .toolbar {
            OptionsToolbarPicker(
                languageId: $languageId,
                order: $order
            )
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
        "all\(locale.languageName(of: languageId, native: false, capitalized: false).map({ " \($0) " }) ?? " ")words"
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

    struct OptionsToolbarPicker: View {
        @Binding var languageId: DB.Language.Name.ID
        @Binding var order: SortOrder

        @FetchAll var availableLanguageNames: [DB.Language.Name]

        @Dependency(\.locale) private var locale

        var body: some View {
            Menu {
                Picker(selection: $languageId) {
                    ForEach(availableLanguageNames) { languageName in
                        Text(name(of: languageName, capitalized: true))
                            .tag(languageName.id)
                    }
                } label: {
                    Label("Language", systemImage: "flag")
                    Text("Select the entry language")
                }

                Picker(selection: $order) {
                    ForEach([SortOrder.forward, .reverse], id: \.self) { sortOrder in
                        Text(sortOrder.displayTitle)
                            .tag(sortOrder)
                    }
                } label: {
                    Label(order.displayTitle, systemImage: "arrow.up.arrow.down")
                    Text("Select the sort order")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }

        func name(of language: DB.Language.Name, capitalized: Bool) -> String {
            let fallback = language.text
            let localized = locale.languageName(of: language.id, native: false, capitalized: capitalized)
            let native = locale.languageName(of: language.id, native: true, capitalized: capitalized)
            return (native ?? localized ?? fallback)
        }
    }
}

extension SortOrder {
    var displayTitle: LocalizedStringKey {
        switch self {
        case .forward:
            return "Ascending"
        case .reverse:
            return "Descending"
        }
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        WordList { _ in }
    }
}
