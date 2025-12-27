//
//  WordListController.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SwiftUI
import UIComponents

struct WordList: View {
    let searchResults: [Row.Model]
    let locale: Locale
    @Binding var languageId: String
    let onRowTapped: (Row.Model) -> Void
    
    @State private var searchText: String = ""
    @State private var order: SortOrder = .forward

    var body: some View {
        List {
            ForEach(searchResults) { model in
                Button {
                    onRowTapped(model)
                } label: {
                    Row(model: model)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.plain)
        .toolbar {
//            Toolbar(languageId: $languageId, order: $order)
        }
        .navigationTitle(pageTitle.capitalized)
        .searchable(text: $searchText, prompt: "Search \(description)")
    }

    private var pageTitle: String {
        locale.languageName(of: languageId, native: true, capitalized: true) ?? "All Words"
    }

    private var description: String {
        "all\(locale.interpolatableLanguageName(of: languageId))words"
    }
}

#Preview {
    NavigationStack {
        WordList(
            searchResults: [
                .init(
                    id: .init(),
                    spelling: "Some spelling",
                    translations: [
                        "translation 1",
                        "translation 2"
                    ]
                )
            ],
            locale: .current,
            languageId: .constant("us_en"),
            onRowTapped: { _ in },
        )
    }
}
