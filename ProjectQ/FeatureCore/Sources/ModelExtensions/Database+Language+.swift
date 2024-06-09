
import ComposableArchitecture
import ModelCore
import RelationalCore

extension Database {
    
    public mutating func ensureExistenceOf(language: Language) {
        guard self[language: language.id] != nil else {
            @Dependency(\.date) var date
            create(.language(language), now: date.now)
            return
        }
    }
    
}

extension Language {
    
    public var displayName: String {
        @Dependency(\.locale) var locale
        // we only want to show the additional (region) information if the primary language is not unique
        @Shared(.settings) var settings
        var copy = settings.languageSelectionList
        copy[id: id] = nil
        if copy.contains(where: { $0.primaryLanguage == primaryLanguage }) {
            return locale.localizedString(forIdentifier: bcp47.rawValue) ?? id.rawValue
        } else {
            return primaryLanguage.flatMap({ locale.localizedString(forLanguageCode: $0) }) ?? id.rawValue
        }
    }
    
}
