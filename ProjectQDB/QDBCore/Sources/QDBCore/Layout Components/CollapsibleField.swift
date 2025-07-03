//
//  CollapsibleField.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SwiftUI

struct CollapsibleField: ViewModifier {

    var style: Style = .defaultValue
    @Binding var opened: Bool
    let saveButtonIsEnabled: Bool
    let onCloseButton: () async -> Void
    let onSaveButton: () async -> Void
    let onDisabledSaveButton: () async -> Void

    struct Style: Sendable {
        static let defaultValue: Self = .init()
        var horizontalAlignment: HorizontalAlignment = .trailing
        var height: CGFloat = 70
    }

    func body(content: Content) -> some View {
        HStack(spacing: 0) {
            content.opacity(
                !opened ? 0 : 1
            )
            .padding(.leading)
            .frame(maxWidth: !opened ? 0 : .infinity, maxHeight: .infinity)
            /*
             Note: You can't use a conditional for the PreferredLanguageTextField, because
             the delays associated with installing and uninstalling the UIView make the
             interface while simultaneously dismissing and pushing egregious. Thus
             we are using the frame to make it collapse (and the 0 spacing on the HStack)
             */

            RollingButton(
                rotated: opened,
                onTap: {
                    if opened {
                        await onCloseButton()
                    } else {
                        opened = true
                    }
                }
            )

            SaveButton(
                onTap: onSaveButton,
                onDisabledTap: onDisabledSaveButton
            )
            .opacity(!opened ? 0 : 1.0)
            .frame(width: !opened ? 0 : .none)
            .geometryGroup() // allows the geometry of this view's animations to be resolved at each step of the parent's frame changes
            .disabled(!saveButtonIsEnabled)
        }
        .padding()
        .background {
            Capsule()
                .fill(.background)
        }
        .animation(.default, value: !opened)
        .compositingGroup()
        .shadow(radius: 2, x: 1, y: 2)
        .frame(maxWidth: .infinity, alignment: .init(horizontal: style.horizontalAlignment, vertical: .center))
        .frame(height: style.height)
    }

    struct SaveButton: View {
        let onTap: () async -> Void
        let onDisabledTap: () async -> Void

        var body: some View {
            Button {
                Task { await onTap() }
            } label: {
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(minWidth: 1) // this line prevents a bug where the image disappears immediately instead of animating away
                    .padding(.leading, 4)
                    .contentShape(Circle())
            }
            .buttonStyle(AlternateActionOnDisabled(onDisabledTap: onDisabledTap))
            .aspectRatio(1.0, contentMode: .fit)
        }
    }

    struct AlternateActionOnDisabled: ButtonStyle {
        var onDisabledTap: () async -> Void

        @Environment(\.isEnabled) var isEnabled

        func makeBody(configuration: Configuration) -> some View {
            // This invisible overlay catches taps even when the button is disabled
            ZStack {
                configuration.label
                    .opacity(configuration.isPressed ? 0.6 : 1.0) // mimic native press effect
                    .foregroundStyle(isEnabled ? .primary : .secondary)

                if !isEnabled {
                    // A transparent layer that detects taps when disabled
                    Color.clear
                        .contentShape(Rectangle()) // ensure entire area is tappable
                        .onTapGesture {
                            Task { await onDisabledTap() }
                        }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var open = false

    Color.red.modifier(
        CollapsibleField(
            opened: $open,
            saveButtonIsEnabled: true,
            onCloseButton: { open = false },
            onSaveButton: { open = false },
            onDisabledSaveButton: {}
        )
    )
}
