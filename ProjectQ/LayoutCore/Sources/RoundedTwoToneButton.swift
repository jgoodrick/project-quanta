
import SwiftUI

struct RoundedTwoToneButton: ButtonStyle {
    
    var highlighted: Bool = false
    struct Style: EnvironmentKey {
        static var defaultValue: Self = .init()
        var dimension: CGFloat? = 44
        var square: Bool = false
        var fontWeight: Font.Weight? = .light
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.roundedTwoToneButton) var style
    
    var foregroundMaxDimension: CGFloat? {
        style.dimension != nil ? .infinity : .none
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: foregroundMaxDimension, maxHeight: foregroundMaxDimension)
            .modifier(AdaptiveHighlightableTwoToneModifier(highlighted: highlighted))
            .clipShape(.buttonBorder)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
            .labelStyle(iconOnly: style.square)
            .frame(width: style.square ? style.dimension : nil, height: style.dimension)
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

