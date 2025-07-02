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
                    Text("Toggle the sort order")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .navigationTitle(pageTitle.capitalized)
        .searchable(text: $searchText, prompt: "Search \(description)")
        .task(id: [languageId, order, searchText] as [AnyHashable]) {
            try? await updateQuery()
        }
    }

    private static func localizedLanguageName(id: String, capitalized: Bool) -> String? {
        @Dependency(\.locale) var locale
        return locale.localizedString(forIdentifier: id)
    }

    private static func nativeLanguageName(id: String, capitalized: Bool) -> String? {
        let nativeLocale = Locale(identifier: id)
        let name = nativeLocale.localizedString(forIdentifier: id)
        if capitalized {
            return name?.capitalized(with: nativeLocale)
        } else {
            return name
        }
    }

    private var pageTitle: String {
        Self.nativeLanguageName(id: languageId, capitalized: true) ?? "All Words"
    }

    private var description: String {
        "all\(Self.localizedLanguageName(id: languageId, capitalized: false).map({ " \($0) " }) ?? " ")words"
    }

    func name(of language: DB.Language.Name, capitalized: Bool) -> String {
        let fallback = language.text
        let localized = Self.localizedLanguageName(id: language.id, capitalized: capitalized)
        let native = Self.nativeLanguageName(id: language.id, capitalized: capitalized)
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

extension SortOrder {
    mutating func toggle() {
        switch self {
        case .forward:
            self = .reverse
        case .reverse:
            self = .forward
        }
    }
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
