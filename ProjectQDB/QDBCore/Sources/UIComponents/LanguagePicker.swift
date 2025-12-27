//
//  LanguagePicker.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/4/25.
//

import SwiftUI

package struct LanguagePicker: View {
    var iconSystemName: String = "flag"
    var title: String = "Language"
    @Binding var languageId: String
    let availableLanguageNames: [String: String]
    let locale: Locale

    package init(
        iconSystemName: String = "flag",
        title: String = "Language",
        languageId: Binding<String>,
        availableLanguageNames: [String : String],
        locale: Locale
    ) {
        self.iconSystemName = iconSystemName
        self.title = title
        self._languageId = languageId
        self.availableLanguageNames = availableLanguageNames
        self.locale = locale
    }
    
    package var body: some View {
        Picker(selection: $languageId) {
            ForEach(availableLanguageNames.sorted(by: { $0.value < $1.value }), id: \.key) { (key, language) in
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

