
import ComposableArchitecture

extension Database {
    
    public mutating func seedWithLanguagesFromSettings() {
        guard stored.languages.isEmpty else { return }
        @Shared(.settings) var settings
        settings.languageSelectionList.forEach {
            stored.languages[$0.id] = $0
        }
    }
    
}

