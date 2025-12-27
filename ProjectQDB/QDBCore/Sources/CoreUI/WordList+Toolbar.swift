//
//  WordList+Query.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/3/25.
//

import SwiftUI
import UIComponents

extension WordList {
    struct Toolbar: View {
        @Binding var languageId: String
        @Binding var order: SortOrder
        
        var availableLanguageNames: [String: String]
        var locale: Locale

        var body: some View {
            Menu {
                LanguagePicker(
                    languageId: $languageId,
                    availableLanguageNames: availableLanguageNames,
                    locale: locale
                )

                OrderPicker(order: $order)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    @Previewable @State var languageId: String = "en_US"
    @Previewable @State var order: SortOrder = .forward
    
    let previewAvailableLanguageNames: [String: String] = [
        "en_US": "English (US)",
        "en_GB": "English (UK)",
        "es_ES": "Spanish (Spain)"
    ]
    let previewLocale: Locale = .current
    
    Color.red.toolbar {
        WordList.Toolbar(
            languageId: $languageId,
            order: $order,
            availableLanguageNames: previewAvailableLanguageNames,
            locale: previewLocale
        )
    }
}
