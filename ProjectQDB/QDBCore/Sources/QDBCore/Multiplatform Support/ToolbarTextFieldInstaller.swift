//
//  ToolbarTextField.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SwiftUI

struct ToolbarTextFieldInstaller: ViewModifier {

    let placeholder: String
    let languageIdentifier: String
    let fieldStyle: Field.Style
    @Binding var text: String
    @Binding var focused: Bool
    let installed: Bool
    let actions: Actions

    struct Actions {
        let onLanguageUnavailable: (String) -> Void
        let onSubmit: (String) async -> Void
        let tappedViewBehindActiveToolbarTextField: () async -> Void
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

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {

            content

            if installed {

                if focused {
                    Button {
                        Task { await actions.tappedViewBehindActiveToolbarTextField() }
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
            onLanguageUnavailable: actions.onLanguageUnavailable,
            onSubmit: { [submitted = text] in
                Task { @MainActor in
                    await actions.onSubmit(submitted)
                    effects.onFieldCommitted()
                }
            }
        )
    }

    struct Field: View {
        let placeholder: String
        let languageIdentifier: String
        var style: Style = .defaultValue
        @Binding var text: String
        @Binding var focused: Bool
        let onLanguageUnavailable: (String) -> Void
        let onSubmit: () -> Void

        struct Style: Sendable {
            static let defaultValue: Self = .init()
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

        var body: some View {
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
                onLanguageUnavailable: onLanguageUnavailable,
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
            onLanguageUnavailable: { print("\($0) is unavailable")},
            onSubmit: { submitted in print("submitted the text field: \(submitted)") },
            tappedViewBehindActiveToolbarTextField: { print("tapped background") }
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
