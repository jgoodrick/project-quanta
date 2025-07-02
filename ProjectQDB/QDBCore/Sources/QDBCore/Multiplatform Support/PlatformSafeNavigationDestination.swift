//
//  PlatformSafeNavigationDestination.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SwiftUI

public extension View {
    /// MacOS does not handle the pop-to-root of a navigation stack well, showing a blank root view instead of the
    /// actual root view. This wrapper applies a workaround that removes the root view from the hierarchy when the
    /// path is populated an only on macOS
    func navigationDestination<Item: Hashable, Destination: View>(
        path: [Item],
        @ViewBuilder destination: @escaping (Item) -> Destination
    ) -> some View {
        #if os(macOS)
        Group {
            if path.isEmpty {
                self
            } else {
                Color.clear
            }
        }
        .navigationDestination(for: Item.self, destination: destination)
        #else
        navigationDestination(for: Item.self, destination: destination)
        #endif
    }
}
