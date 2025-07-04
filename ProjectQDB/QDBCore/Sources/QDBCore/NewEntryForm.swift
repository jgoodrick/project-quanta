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

    @State private var languageId: String = .currentLanguageId()

    @FetchAll var availableLanguageNames: [DB.Language.Name]

    @State private var matchDBValue = false

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

            ForEach(availableLanguageNames) { languageName in
                if languageName.id != languageId {
                    Section(languageName.text) {
                        SubEntryForm(title: languageName.text)
                    }
                }
            }
        }
        .toolbar {
            if !matchDBValue {
                Button("Save") {

                }
            }
        }
        .navigationTitle("New Word")
    }
}

extension String {
    static func currentLanguageId() -> Self {
        @Dependency(\.locale) var locale
        return locale.language.minimalIdentifier
    }
}

struct SubEntryForm: View {
    let title: String
    @State private var text = ""
    @State private var languageId = ""

    var body: some View {
//        VStack {
            TextField(title, text: $text)
                .font(.largeTitle)
                .textFieldStyle(.roundedBorder)
//
//            LanguagePicker(languageId: $languageId)
//                .pickerStyle(.navigationLink)
//        }
    }
}

#Preview { let _ = DB.prepare()
    NavigationStack {
        NewEntryForm()
    }
}
