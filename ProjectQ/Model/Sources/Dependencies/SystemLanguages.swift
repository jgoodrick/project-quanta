
import ComposableArchitecture
import SwiftUI // Locale

// These are all bcp47 identifiers:
@DependencyClient
public struct SystemLanguages: DependencyKey {
    public static let testValue: SystemLanguages = .init()
    public static let liveValue: SystemLanguages = .init()
    
    public var current: @Sendable () -> Language = {
        @Dependency(\.locale) var systemLocale
        return systemLocale.modelLanguage
    }
    
    public var allConfiguredTextInputModeLanguages: () -> IdentifiedArrayOf<Language> = {
        UITextInputMode.activeInputModes.compactMap(\.primaryLanguage).map({ Language(bcp47: $0) }).reduce(into: [], { $0.append($1) })
    }
    
}

extension Locale {
    var modelLanguage: Model.Language {
        .init(bcp47: identifier(.bcp47))
    }
}

extension DependencyValues {
    public var systemLanguages: SystemLanguages {
        get { self[SystemLanguages.self] }
        set { self[SystemLanguages.self] = newValue }
    }
}

