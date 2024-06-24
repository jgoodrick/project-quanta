
import SwiftUI

struct AdaptiveHighlightableTwoToneModifier: ViewModifier {
    
    var highlighted: Bool = false
    struct Style: EnvironmentKey {
        static var defaultValue: Self = .init()
        var shape: any Shape = ButtonBorderShape.buttonBorder
        var lightMode: Adaptive = .init(
            highlighted: .init(
                foreground: .background,
                background: .primary
            ),
            standard: .init(
                foreground: .primary.blendMode(.plusDarker),
                background: .tertiary
            )
        )
        var darkMode: Adaptive = .init(
            highlighted: .init(
                foreground: .white,
                background: .primary
            ),
            standard: .init(
                foreground: .white,
                background: .primary
            )
        )
        struct Adaptive {
            var highlighted: Colors
            var standard: Colors
        }
        struct Colors {
            var foreground: any ShapeStyle
            var background: any ShapeStyle
            var borderStroke: Stroke = .init()
            struct Stroke {
                var color: any ShapeStyle = HierarchicalShapeStyle.primary
                var style: StrokeStyle = .init(lineWidth: 0)
            }
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.adaptiveHighlightableTwoTone) var style
    
    var foregroundStyle: some ShapeStyle {
        switch colorScheme {
        case .light:
            if highlighted {
                AnyShapeStyle(style.lightMode.highlighted.foreground)
            } else {
                AnyShapeStyle(style.lightMode.standard.foreground)
            }
        default:
            if highlighted {
                AnyShapeStyle(style.darkMode.highlighted.foreground)
            } else {
                AnyShapeStyle(style.darkMode.standard.foreground)
            }
        }
    }
        
    var backgroundStyle: some ShapeStyle {
        switch colorScheme {
        case .light:
            if highlighted {
                AnyShapeStyle(style.lightMode.highlighted.background)
            } else {
                AnyShapeStyle(style.lightMode.standard.background)
            }
        default:
            if highlighted {
                AnyShapeStyle(style.darkMode.highlighted.background)
            } else {
                AnyShapeStyle(style.darkMode.standard.background)
            }
        }
    }
    
    var borderStrokeColor: some ShapeStyle {
        switch colorScheme {
        case .light:
            if highlighted {
                AnyShapeStyle(style.lightMode.highlighted.borderStroke.color)
            } else {
                AnyShapeStyle(style.lightMode.standard.borderStroke.color)
            }
        default:
            if highlighted {
                AnyShapeStyle(style.darkMode.highlighted.borderStroke.color)
            } else {
                AnyShapeStyle(style.darkMode.standard.borderStroke.color)
            }
        }
    }
    
    var borderStrokeStyle: StrokeStyle {
        switch colorScheme {
        case .light:
            if highlighted {
                style.lightMode.highlighted.borderStroke.style
            } else {
                style.lightMode.standard.borderStroke.style
            }
        default:
            if highlighted {
                style.darkMode.highlighted.borderStroke.style
            } else {
                style.darkMode.standard.borderStroke.style
            }
        }
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(foregroundStyle)
            .background {
                AnyShape(style.shape)
                    .fill(backgroundStyle)
                    .stroke(borderStrokeColor, style: borderStrokeStyle)
            }
    }
}

extension EnvironmentValues {
    var adaptiveHighlightableTwoTone: AdaptiveHighlightableTwoToneModifier.Style {
        get { self[AdaptiveHighlightableTwoToneModifier.Style.self] }
        set { self[AdaptiveHighlightableTwoToneModifier.Style.self] = newValue }
    }
}


