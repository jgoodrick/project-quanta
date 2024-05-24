
import ComposableArchitecture
import SwiftUI // Locale

public typealias LanguageSelection = Language.Definition

extension LanguageSelection {
    public static var systemCurrent: Self {
        @Dependency(Languages.self) var languages
        return .bcp47(languages.device().identifier(.bcp47))
    }
    public var bcp47: String? {
        switch self {
        case .bcp47(let value): return value
        default: return .none
        }
    }
    public var displayName: String {
        @Dependency(Languages.self) var languages
        let device = languages.device()
        switch self {
        case .bcp47(let bcp47):
            return device.localizedString(forIdentifier: bcp47) ?? bcp47
        case .custom(let custom):
            return custom.localizedTitles[device.identifier(.bcp47)] ?? custom.identifier
        }
    }
    public var locale: Locale? {
        switch self {
        case .bcp47(let id): Locale(identifier: id)
        case .custom: nil
        }
    }
}

extension LanguageSelection: EnvironmentKey {
    public static var defaultValue: LanguageSelection = .systemCurrent
}

extension EnvironmentValues {
    var language: LanguageSelection {
        get { self[LanguageSelection.self] }
        set { self[LanguageSelection.self] = newValue }
    }
}

@DependencyClient
public struct Languages: DependencyKey {
    public static let testValue: Languages = .init()
    public static let liveValue: Languages = .init()
    public var device: @Sendable () -> Locale = { Locale.current }
    public var focused: @Sendable () -> LanguageSelection = {
        @Shared(.focusedLanguage) var focusedLanguage
        return focusedLanguage
    }
    public var configured: @MainActor () -> [LanguageSelection] = {
        UITextInputMode.activeInputModes.compactMap(\.primaryLanguage).map(LanguageSelection.bcp47)
    }
}

extension DependencyValues {
    public var languages: Languages {
        get { self[Languages.self] }
        set { self[Languages.self] = newValue }
    }
}
