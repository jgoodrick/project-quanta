
import SwiftUI
import StructuralModel

struct LanguageTagMenu: View {
    
    let language: Language
    var unavailableLanguages: Set<Language.ID> = []
    var onLanguageSelected: ((Language) -> Void)?
    
    @Environment(\.languageNameFormatter) private var formatter
    
    var body: some View {
        Menu {
            if let onLanguageSelected {
                LanguagesMenuItems(unavailableLanguages: unavailableLanguages.subtracting([language])) {
                    if $0 != language {
                        onLanguageSelected($0)
                    }
                }
            } else {
                Text(formatter.displayName(for: language))
//                Text("This is ^[a \(formatter.displayName(for: language))](inflect: true) translation")
            }
        } label: {
            Text(formatter.displayName(for: language, style: .short))
        }
        .buttonStyle(LanguageTagButtonStyle())
    }
}

struct LanguagesMenuItems: View {

    let unavailableLanguages: Set<Language.ID>
    var exhaustedMessage: String?
    let action: (Language) -> Void

    var moreLanguagesAreAvailableForSelection: Bool {
        !allLanguages.filter({ !unavailableLanguages.contains($0) }).isEmpty
    }

    @Environment(\.languageNameFormatter) private var formatter
    @Environment(\.languageTagMenuAvailableLanguages) private var allLanguages

    var body: some View {
        if !moreLanguagesAreAvailableForSelection, let exhaustedMessage {
            Text(exhaustedMessage)
        } else {
            ForEach(allLanguages) { language in
                if !unavailableLanguages.contains(language.id) {
                    Button(action: { action(language) }) {
                        Text(formatter.displayName(for: language))
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(formatter.displayName(for: language))
                }
            }
        }
    }
}

struct AddForLanguageMenu: View {
    
    let unavailableLanguages: Set<Language.ID>
    let action: (Language?) -> Void
    
    @Environment(\.languageNameFormatter) private var formatter
    @Environment(\.languageTagMenuAvailableLanguages) private var allLanguages

    var body: some View {
        Menu {
            LanguagesMenuItems(
                unavailableLanguages: unavailableLanguages,
                exhaustedMessage: "No Languages Remaining",
                action: action
            )
        } label: {
            Text("+")
        } primaryAction: {
            action(allLanguages.first(where: { !unavailableLanguages.contains($0.id) }))
        }
        .buttonStyle(LanguageTagButtonStyle())
    }
}

struct LanguageTagButtonStyle: ButtonStyle {
    
    @Environment(\.languageTag) var style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .aspectRatio(1.0, contentMode: .fit)
            .foregroundStyle(.background)
            .frame(minWidth: 28, minHeight: 28)
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .foregroundStyle(style.primaryColor)
    }
}

public struct LanguageTagMenuAvailableLanguages: EnvironmentKey {
    public static let defaultValue: [Language] = {
        Locale.preferredLanguages.compactMap({ try? Language.init(bcp47: $0) })
    }()
}

extension EnvironmentValues {
    var languageTagMenuAvailableLanguages: [Language] {
        get { self[LanguageTagMenuAvailableLanguages.self] }
        set { self[LanguageTagMenuAvailableLanguages.self] = newValue }
    }
}

public struct LanguageTagStyle: EnvironmentKey, Sendable {
    public static let defaultValue: LanguageTagStyle = .init()
    public var primaryColor: Color = AppAccentColor.defaultValue.opacity(0.6)
}

extension EnvironmentValues {
    var languageTag: LanguageTagStyle {
        get { self[LanguageTagStyle.self] }
        set { self[LanguageTagStyle.self] = newValue }
    }
}

public struct LanguageNameFormatter: EnvironmentKey, @unchecked Sendable {
    public static let defaultValue: Self = .init()
    public enum Style {
        case full, short
    }
    var formatter: (Language, Style) -> String = { (language, style) in
        let fallback = language.bcp47.rawValue
        let languageCode = language.primaryLanguage ?? fallback
        switch style {
        case .full:
            return Locale.current.localizedString(forLanguageCode: languageCode) ?? fallback
        case .short:
            return language.primaryLanguage ?? fallback
        }
    }
    public func displayName(for language: Language, style: Style = .full) -> String {
        formatter(language, style)
    }
    public func displayNames(for languages: [Language], separator: String, style: Style = .full) -> String {
        languages.map({ formatter($0, style) }).joined(separator: separator)
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

