
import ComposableArchitecture
import Foundation
import StructuralModel

public struct Settings: Equatable, Codable, Sendable {
    public var languageSelectionList: IdentifiedArrayOf<Language>
    public var defaultNewEntryLanguage: Language
    public var defaultTranslationLanguage: Language
    public var additionalSystemLanguagesAvailable: IdentifiedArrayOf<Language> {
        @Dependency(\.systemLanguages) var systemLanguages
        var result = systemLanguages.allConfiguredTextInputModeLanguages()
        languageSelectionList.forEach {
            result[id: $0.id] = nil
        }
        return result
    }

    static var defaultValue: Self {
        @Dependency(\.systemLanguages) var systemLanguages
        let defaults = Self.defaultLanguages
        return .init(
            languageSelectionList: defaults,
            defaultNewEntryLanguage: defaults.first ?? systemLanguages.current(),
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
        
        // filter out emoji. The user can always add it later, if they want
        result[id: .init(rawValue: "emoji")] = nil
        
        return result
    }

}
