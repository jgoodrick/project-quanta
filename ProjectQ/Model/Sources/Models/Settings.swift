
import ComposableArchitecture
import Foundation

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Settings>> {
    public static var settings: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "settings.json")), .init()
        )
    }
}


@ObservableState
public struct Settings: Equatable, Codable, Sendable {
    public var languageSelectionList: IdentifiedArrayOf<Language> = {
        @Dependency(\.systemLanguages) var systemLanguages
        return systemLanguages.inDefaultSortOrder
    }()
    public var focusedLanguage: Language = {
        @Dependency(\.locale) var locale
        return .init(bcp47: locale.identifier(.bcp47))
    }()
}
