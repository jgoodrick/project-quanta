//
//  OrderPicker.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/4/25.
//

import SwiftUI

package struct OrderPicker: View {
    @Binding var order: SortOrder

    package init(order: Binding<SortOrder>) {
        self._order = order
    }

    package var body: some View {
        Picker(selection: $order) {
            ForEach([SortOrder.forward, .reverse], id: \.self) { sortOrder in
                Text(sortOrder.displayTitle)
                    .tag(sortOrder)
            }
        } label: {
            Label(order.displayTitle, systemImage: "arrow.up.arrow.down")
            Text("Select the sort order")
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

#Preview {
    @Previewable @State var order: SortOrder = .forward
    OrderPicker(order: $order)
}
