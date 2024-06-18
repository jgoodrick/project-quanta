
import ComposableArchitecture
import StructuralModel
import SwiftUI // Locale

// These are all bcp47 identifiers:
@DependencyClient
public struct SystemLanguages: DependencyKey {
    public static let testValue: SystemLanguages = .init()
    public static let liveValue: SystemLanguages = .init()
    
    public var current: @Sendable () -> Language = {
        // force-unwrap explanation: this comes from the system, and so should theoretically _always_ be a valid id
        @Dependency(\.locale) var systemLocale
        return try! .init(bcp47: systemLocale.identifier(.bcp47))
    }
    
    public var allConfiguredTextInputModeLanguages: () -> IdentifiedArrayOf<Language> = {
        defaultConfiguredTextInputModeLanguages
    }
    
}

fileprivate var defaultConfiguredTextInputModeLanguages: IdentifiedArrayOf<Language> {
    #if os(iOS)
    UITextInputMode
        .activeInputModes
        .compactMap(\.primaryLanguage)
        .compactMap({ try? Language(bcp47: $0) })
        .reduce(into: [], { $0.append($1) })
    #else
    IdentifiedArrayOf<Language>()
    #endif
}


extension DependencyValues {
    public var systemLanguages: SystemLanguages {
        get { self[SystemLanguages.self] }
        set { self[SystemLanguages.self] = newValue }
    }
}

