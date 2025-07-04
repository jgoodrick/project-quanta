//
//  WordList+Query.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/3/25.
//

import SharingGRDB
import SwiftUI

extension WordList {
    struct Toolbar: View {
        @Binding var languageId: DB.Language.Name.ID
        @Binding var order: SortOrder

        var body: some View {
            Menu {
                LanguagePicker(languageId: $languageId)

                OrderPicker(order: $order)
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    @Previewable @State var languageId: DB.Language.Name.ID = "en_US"
    @Previewable @State var order: SortOrder = .forward
    Color.red.toolbar {
        WordList.Toolbar(
            languageId: $languageId,
            order: $order
        )
    }
}
