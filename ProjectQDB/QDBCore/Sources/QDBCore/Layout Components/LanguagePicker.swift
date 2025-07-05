//
//  LanguagePicker.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/4/25.
//

import SharingGRDB
import SwiftUI

struct LanguagePicker: View {
    var iconSystemName: String = "flag"
    var title: String = "Language"
    @Binding var languageId: String

    @FetchAll(DB.Entry.all.select(\.language).distinct()) var availableLanguageNames: [String]

    @Dependency(\.locale) private var locale

    var body: some View {
        Picker(selection: $languageId) {
            ForEach(availableLanguageNames, id: \.self) { language in
                Text(name(of: language, capitalized: true))
                    .tag(language)
            }
        } label: {
            Label(title, systemImage: iconSystemName)
        }
    }

    func name(of language: String, capitalized: Bool) -> String {
        let fallback = language
        let localized = locale.languageName(of: language, native: false, capitalized: capitalized)
        let native = locale.languageName(of: language, native: true, capitalized: capitalized)
        return (native ?? localized ?? fallback)
    }
}

