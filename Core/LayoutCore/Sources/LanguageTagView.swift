
import SwiftUI
import StructuralModel

struct LanguageTagView: View {
    
    let language: Language
    
    @Environment(\.languageNameFormatter) var formatter
    @Environment(\.languageTag) var style
    
    var body: some View {
        Menu {
            Text("This is ^[a \(formatter.displayName(for: language, style: .full))](inflect: true) translation")
        } label: {
            Text(formatter.displayName(for: language))
                .foregroundStyle(.background)
                .padding(4)
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .foregroundStyle(style.primaryColor)
        }
    }
}

public struct LanguageTagStyle: EnvironmentKey {
    public static var defaultValue: LanguageTagStyle = .init()
    public var primaryColor: Color = .indigo.opacity(0.6)
}

extension EnvironmentValues {
    var languageTag: LanguageTagStyle {
        get { self[LanguageTagStyle.self] }
        set { self[LanguageTagStyle.self] = newValue }
    }
}

public struct LanguageNameFormatter: EnvironmentKey {
    public static var defaultValue: Self = .init()
    public enum Style {
        case full, short
    }
    var formatter: (Language, Style) -> String = { (language, style) in
        let fallback = language.id.rawValue
        let languageCode = language.primaryLanguage ?? fallback
        switch style {
        case .full:
            return Locale.current.localizedString(forLanguageCode: languageCode) ?? fallback
        case .short:
            return language.primaryLanguage ?? fallback
        }
    }
    public func displayName(for language: Language, style: Style = .short) -> String {
        formatter(language, style)
    }
    public mutating func update(formatter: @escaping (Language, Style) -> String) {
        self.formatter = formatter
    }
}

extension EnvironmentValues {
    public var languageNameFormatter: LanguageNameFormatter {
        get { self[LanguageNameFormatter.self] }
        set { self[LanguageNameFormatter.self] = newValue }
    }
}

