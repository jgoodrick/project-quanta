//
//  ToolbarTextField.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SwiftUI

package struct ToolbarTextFieldInstaller: ViewModifier {
    package init(
        placeholder: String,
        languageIdentifier: String,
        fieldStyle: ToolbarTextFieldInstaller.Field.Style,
        text: Binding<String>,
        focused: Binding<Bool>,
        installed: Bool,
        actions: ToolbarTextFieldInstaller.Actions
    ) {
        self.placeholder = placeholder
        self.languageIdentifier = languageIdentifier
        self.fieldStyle = fieldStyle
        self._text = text
        self._focused = focused
        self.installed = installed
        self.actions = actions
    }
    

    let placeholder: String
    let languageIdentifier: String
    let fieldStyle: Field.Style
    @Binding var text: String
    @Binding var focused: Bool
    let installed: Bool
    let actions: Actions

    package struct Actions {
        package init(
            onLanguageAvailability: @escaping (String, Bool) -> Void = { _, _ in },
            onSubmit: @escaping (String) async -> Void
        ) {
            self.onLanguageAvailability = onLanguageAvailability
            self.onSubmit = onSubmit
        }
        
        package let onLanguageAvailability: (String, Bool) -> Void
        package let onSubmit: (String) async -> Void
    }

    struct Effects {
        let onCloseButton: () -> Void
        let onFieldCommitted: () -> Void
        let onSaveButton: () -> Void
        let onDisabledSaveButton: () -> Void
        let tappedViewBehindActiveToolbarTextField: () -> Void
    }

    var effects: Effects {
        .init(
            onCloseButton: {
                text = ""
                focused = false
            },
            onFieldCommitted: {
                focused = false
            },
            onSaveButton: {
                text = ""
                focused = false
            },
            onDisabledSaveButton: {},
            tappedViewBehindActiveToolbarTextField: {
                text = ""
                focused = false
            }
        )
    }

    package func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {

            content

            if installed {

                if focused {
                    Button {
                        effects.tappedViewBehindActiveToolbarTextField()
                    } label: {
                        Rectangle()
                            .fill(.background)
                            .opacity(0.4)
                    }
                    .buttonStyle(.plain)
                }

                field.modifier(
                    CollapsibleField(
                        opened: $focused,
                        saveButtonIsEnabled: !text.isEmpty,
                        onCloseButton: effects.onCloseButton,
                        onSaveButton: { [submitted = text] in
                            await actions.onSubmit(submitted)
                            effects.onSaveButton()
                        },
                        onDisabledSaveButton: effects.onDisabledSaveButton
                    )
                )
                .padding()
            }
        }
    }

    private var field: some View {
        Field(
            placeholder: placeholder,
            languageIdentifier: languageIdentifier,
            style: fieldStyle,
            text: $text,
            focused: $focused,
            onLanguageAvailability: actions.onLanguageAvailability,
            onSubmit: { [submitted = text] in
                Task { @MainActor in
                    await actions.onSubmit(submitted)
                    effects.onFieldCommitted()
                }
            }
        )
    }

    package struct Field: View {
        let placeholder: String
        let languageIdentifier: String
        var style: Style = .defaultValue
        @Binding var text: String
        @Binding var focused: Bool
        let onLanguageAvailability: (String, Bool) -> Void
        let onSubmit: () -> Void

        package struct Style: Sendable {
            package static let defaultValue: Self = .init()
            var font: Font = .title2
            var adjustsFontSizeToFitWidth: Bool = false
            #if os(iOS)
            var autocapitalization: Autocapitalization = .none
            var autocorrection: Autocorrection = .default
            fileprivate var preferredLanguageTextFieldStyle: PreferredLanguageTextField.Style {
                .init(
                    font: font,
                    autocapitalization: autocapitalization,
                    autocorrection: autocorrection,
                    adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth
                )
            }
            #endif
        }

        @FocusState private var focusState: Bool

        package var body: some View {
            underlying
                .synchronize(focusState: $focusState, with: $focused)
        }

        var underlying: some View {
            #if os(iOS)
            PreferredLanguageTextField(
                placeholder: placeholder,
                style: style.preferredLanguageTextFieldStyle,
                text: $text,
                isFocused: $focused,
                preferredLanguage: languageIdentifier,
                onLanguageAvailability: onLanguageAvailability,
                onSubmit: onSubmit
            )
            #else
            Multiplatform(
                placeholder: placeholder,
                text: $text,
                onSubmit: onSubmit
            )
            .focused($focusState)
            .font(style.font)
            #endif
        }

        struct Multiplatform: View {
            let placeholder: String
            @Binding var text: String
            let onSubmit: () -> Void

            @FocusState private var focused: Bool
            
            var body: some View {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .onSubmit(onSubmit)
            }
        }
    }
}

extension View {
    func synchronize<Value: Equatable>(
        focusState lhs: FocusState<Value>.Binding,
        with rhs: Binding<Value>
    ) -> some View {
        self
            .onChange(of: rhs.wrappedValue) { _, new in lhs.wrappedValue = new }
            .onChange(of: lhs.wrappedValue) { _, new in rhs.wrappedValue = new }
    }
}

extension ToolbarTextFieldInstaller.Actions {
    static var noop: Self {
        .init(
            onLanguageAvailability: { print("\($0) is \($1 ? "" : "un")available") },
            onSubmit: { submitted in print("submitted the text field: \(submitted)") }
        )
    }
}

#Preview {
    @Previewable @State var text: String = ""
    @Previewable @State var focused: Bool = false
    List(0..<100) { i in
        Text("\(i)")
    }
    .modifier(
        ToolbarTextFieldInstaller(
            placeholder: "placeholder text",
            languageIdentifier: "uk_UA",
            fieldStyle: .defaultValue,
            text: $text,
            focused: $focused,
            installed: true,
            actions: .noop
        )
    )
}
