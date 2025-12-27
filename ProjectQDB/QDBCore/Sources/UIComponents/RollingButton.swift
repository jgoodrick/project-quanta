//
//  RollingButton.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 7/2/25.
//

import SwiftUI

struct RollingButton: View {

    let rotated: Bool
    var style: Style = .defaultValue
    let onTap: @MainActor () async -> Void

    struct Style: EnvironmentKey, Sendable {
        static let defaultValue: Self = .init()
        var clockwise: Bool = true
        var customHeight: Double? = .none
        var background: Color = .gray
    }

    var rotationMagnitudeDegrees: Double {
        135
    }

    var rotatedAngle: Angle {
        .degrees(style.clockwise ? rotationMagnitudeDegrees : -rotationMagnitudeDegrees)
    }

    var body: some View {
        Button {
            Task { await onTap() }
        } label: {
            Image(systemName: "plus")
                .resizable()
                .aspectRatio(1.0, contentMode: .fit)
                .rotationEffect(rotated ? rotatedAngle : .zero)
                .animation(.default, value: rotated)
                .padding(6)
                .contentShape(Circle())
                .transition(
                    .asymmetric(
                        insertion: AnyTransition.move(edge: .trailing),
                        removal:AnyTransition.move(edge: .trailing)
                    )
                )
        }
        .buttonStyle(CustomButtonStyle())
        .aspectRatio(1.0, contentMode: .fit)
    }

    struct CustomButtonStyle: ButtonStyle {
        @Environment(\.isEnabled) var isEnabled

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.6 : 1.0) // mimic native press effect
                .foregroundStyle(isEnabled ? .primary : .secondary)
        }
    }
}

#Preview {
    RollingButton(rotated: false) {
        print("")
    }
}
