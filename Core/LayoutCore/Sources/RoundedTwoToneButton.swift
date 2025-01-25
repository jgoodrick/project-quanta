
import SwiftUI

struct RoundedTwoToneButton: ButtonStyle {
    
    var highlighted: Bool = false
    struct Style: EnvironmentKey, Sendable {
        static let defaultValue: Self = .init()
        var dimension: CGFloat? = 44
        var square: Bool = false
        var maxWidth: CGFloat? = .infinity
        var height: CGFloat?
        var maxHeight: CGFloat? = .infinity
        var horizontalPadding: CGFloat = 8
        var verticalPadding: CGFloat = 0
        var alignment: Alignment = .center
        var fontWeight: Font.Weight? = .regular
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.roundedTwoToneButton) var style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: style.maxWidth, maxHeight: style.maxHeight, alignment: style.alignment)
            .padding(.horizontal, style.horizontalPadding)
            .padding(.vertical, style.verticalPadding)
            .modifier(AdaptiveHighlightableTwoToneModifier(highlighted: highlighted))
            .clipShape(.buttonBorder)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .labelStyle(iconOnly: style.square != nil)
            .frame(width: style.square ? nil : style.dimension, height: style.square ? nil : style.dimension)
            .fontWeight(style.fontWeight)
    }
}

extension EnvironmentValues {
    var roundedTwoToneButton: RoundedTwoToneButton.Style {
        get { self[RoundedTwoToneButton.Style.self] }
        set { self[RoundedTwoToneButton.Style.self] = newValue }
    }
}

extension View {
    @ViewBuilder
    func labelStyle(iconOnly: Bool) -> some View {
        if iconOnly {
            self.labelStyle(.iconOnly)
        } else {
            self.labelStyle(.titleAndIcon)
        }
    }
}

extension ButtonStyle where Self == RoundedTwoToneButton {
    static func roundedTwoTone(highlighted: Bool = false) -> Self {
        Self(highlighted: highlighted)
    }
}

