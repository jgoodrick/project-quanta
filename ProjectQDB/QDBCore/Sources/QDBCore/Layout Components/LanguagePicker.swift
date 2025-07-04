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
    @Binding var languageId: DB.Language.Name.ID

    @FetchAll var availableLanguageNames: [DB.Language.Name]

    @Dependency(\.locale) private var locale

    var body: some View {
        Picker(selection: $languageId) {
            ForEach(availableLanguageNames) { languageName in
                Text(name(of: languageName, capitalized: true))
                    .tag(languageName.id)
            }
        } label: {
            Label(title, systemImage: iconSystemName)
        }
    }

    func name(of language: DB.Language.Name, capitalized: Bool) -> String {
        let fallback = language.text
        let localized = locale.languageName(of: language.id, native: false, capitalized: capitalized)
        let native = locale.languageName(of: language.id, native: true, capitalized: capitalized)
        return (native ?? localized ?? fallback)
    }
}

