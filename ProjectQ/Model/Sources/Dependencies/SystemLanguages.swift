
import ComposableArchitecture
import SwiftUI // Locale

// These are all bcp47 identifiers:
@DependencyClient
public struct SystemLanguages: DependencyKey {
    public static let testValue: SystemLanguages = .init()
    public static let liveValue: SystemLanguages = .init()
    
    public var current: @Sendable () -> Language = {
        @Dependency(\.locale) var systemLocale
        return Language.init(id: .bcp47(systemLocale.identifier(.bcp47)))
    }
    
    var configured: () -> IdentifiedArrayOf<Language> = {
        UITextInputMode.activeInputModes.compactMap(\.primaryLanguage).map(Language.ID.bcp47).map({Language.init(id: $0)}).reduce(into: [], { $0.append($1) })
    }
    
    var inDefaultSortOrder: IdentifiedArrayOf<Language> {
        var result = configured()
        if let first = result.first {
            result[id: first.id] = nil
            result.append(first)
        }
        return result
    }
}

extension DependencyValues {
    public var systemLanguages: SystemLanguages {
        get { self[SystemLanguages.self] }
        set { self[SystemLanguages.self] = newValue }
    }
}

