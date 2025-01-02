
import ComposableArchitecture
import StructuralModel
import SwiftUI // Locale

// These are all bcp47 identifiers:
@DependencyClient
public struct SystemLanguages: Sendable, DependencyKey {
    public static let testValue: SystemLanguages = .init()
    public static let liveValue: SystemLanguages = .init()
    
    public var current: @Sendable () -> Language = {
        // force-unwrap explanation: this comes from the system, and so should theoretically _always_ be a valid id
        @Dependency(\.locale) var systemLocale
        return try! .init(bcp47: systemLocale.identifier(.bcp47))
    }
    
    public var allConfiguredTextInputModeLanguages: @Sendable () -> IdentifiedArrayOf<Language> = {
        var cache: IdentifiedArrayOf<Language> = []
        #warning("This does not work as expected. Need to rethink how to store and update the default text input modes")
//        Task { @MainActor in
//            cache = await readTextInputModeLanguages()
//        }
        return cache
    }
    
}

fileprivate func readTextInputModeLanguages() async -> IdentifiedArrayOf<Language> {
    #if os(iOS)
    await textInputModeConvertedToLanguages
    #else
    IdentifiedArrayOf<Language>()
    #endif
}

#if os(iOS)
@MainActor
fileprivate var textInputModeConvertedToLanguages: IdentifiedArrayOf<Language> {
    UITextInputMode
        .activeInputModes
        .compactMap(\.primaryLanguage)
        .compactMap({ try? Language(bcp47: $0) })
        .reduce(into: [], { $0.append($1) })
}
#endif

extension DependencyValues {
    public var systemLanguages: SystemLanguages {
        get { self[SystemLanguages.self] }
        set { self[SystemLanguages.self] = newValue }
    }
}

