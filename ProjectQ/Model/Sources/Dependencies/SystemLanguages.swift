
import ComposableArchitecture
import SwiftUI // Locale

// These are all bcp47 identifiers:
@DependencyClient
struct SystemLanguages: DependencyKey {
    static let testValue: SystemLanguages = .init()
    static let liveValue: SystemLanguages = .init()
    
    var current: @Sendable () -> Language.ID = {
        @Dependency(\.locale) var systemLocale
        return .bcp47(systemLocale.identifier(.bcp47))
    }
    
    var configured: () -> IdentifiedArrayOf<Language.ID> = {
        UITextInputMode.activeInputModes.compactMap(\.primaryLanguage).map(Language.ID.bcp47).reduce(into: [], { $0.append($1) })
    }
    
    func displayName(for id: Language.ID, debug: Bool = false) -> String {
        switch id {
        case .bcp47(let identifier):
            @Dependency(\.locale) var systemLocale
            guard !debug else { return identifier }
            return systemLocale.localizedString(forIdentifier: identifier) ?? identifier
        }
    }
    
    var inDefaultSortOrder: IdentifiedArrayOf<Language.ID> {
        var result = configured()
        if let first = result.first {
            @Dependency(\.locale) var locale
            switch first {
            case .bcp47(let identifier):
                if identifier == locale.identifier(.bcp47) {
                    result[id: first.id] = nil
                    result.append(first)
                }
            }
        }
        return result
    }
}

extension DependencyValues {
    var systemLanguages: SystemLanguages {
        get { self[SystemLanguages.self] }
        set { self[SystemLanguages.self] = newValue }
    }
}

