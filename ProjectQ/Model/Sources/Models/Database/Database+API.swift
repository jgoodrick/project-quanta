
import ComposableArchitecture

extension Database {
    
    public mutating func seedWithLanguagesFromSystem() {
        @Dependency(\.systemLanguages) var systemLanguages
        systemLanguages.allConfiguredTextInputModeLanguages().forEach {
            stored.languages[$0.id] = $0
        }
    }
    
}

