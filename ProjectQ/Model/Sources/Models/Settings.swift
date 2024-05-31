
import ComposableArchitecture
import Foundation

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Settings>> {
    public static var settings: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "settings.json")), .defaultValue
        )
    }
}


@ObservableState
public struct Settings: Equatable, Codable, Sendable {
    public var languageSelectionList: IdentifiedArrayOf<Language>
    public var focusedLanguage: Language
    public var defaultTranslationLanguage: Language
    public var additionalLanguagesAvailable: IdentifiedArrayOf<Language> {
        @Dependency(\.systemLanguages) var systemLanguages
        var result = systemLanguages.allConfiguredTextInputModeLanguages()
        languageSelectionList.forEach {
            result[id: $0.id] = nil
        }
        return result
    }
}

extension Settings {
    static var defaultValue: Self {
        @Dependency(\.systemLanguages) var systemLanguages
        let defaults = Self.defaultLanguages
        return .init(
            languageSelectionList: defaults,
            focusedLanguage: defaults.first ?? systemLanguages.current(),
            defaultTranslationLanguage: systemLanguages.current()
        )
    }
    static var defaultLanguages: IdentifiedArrayOf<Language> {
        @Dependency(\.systemLanguages) var systemLanguages
        
        var result: IdentifiedArrayOf<Language> = []
        
        // unique the languages by their primary language code (users can always add these later)
        var languageCodes = Set<String>()
        systemLanguages.allConfiguredTextInputModeLanguages().forEach {
            if let languageCode = $0.primaryLanguage, !languageCodes.contains(languageCode) {
                languageCodes.insert(languageCode)
                result[id: $0.id] = $0
            }
        }
        
        // move the current language out of the top spot (likely not the language the user is hoping to learn)
        if result.count > 1 {
            let current = systemLanguages.current()
            result[id: current.id] = nil
            result.insert(current, at: 1)
        }
        
        return result
    }
}

