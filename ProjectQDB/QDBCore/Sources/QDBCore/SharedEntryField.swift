//
//  SharedEntryField.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/3/25.
//

import Dependencies
import Foundation
import Sharing
import SwiftUI

/// WIP Concept:
/// This component will operate almost as it's own little application, requiring whatever
/// view is currently visible to set a preference key if it wants to hide it. That way, this view
/// will be available at any point in the app

extension View {
    func installSharedEntryField(actions: ToolbarTextFieldInstaller.Actions) -> some View {
        self.modifier(SharedEntryField(actions: actions))
    }
}

struct SharedEntryField: ViewModifier {
    let actions: ToolbarTextFieldInstaller.Actions
    @Shared(.languageId) var languageId
    @Shared(.sharedEntryText) var text
    @Shared(.sharedEntryFocus) var focused

    @Dependency(\.locale) private var locale

    @State private var installed = true

    func body(content: Content) -> some View {
        content.modifier(
            ToolbarTextFieldInstaller(
                placeholder: "Add a new\(locale.interpolatableLanguageName(of: languageId))word",
                languageIdentifier: languageId,
                fieldStyle: .defaultValue,
                text: Binding($text),
                focused: Binding($focused),
                installed: installed,
                actions: actions
            )
        )
    }
}

#Preview {
    Color.green.installSharedEntryField(
        actions: .init(
            onSubmit: { _ in }
        )
    )
}
