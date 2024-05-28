
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<IdentifiedArrayOf<Language.ID>>> {
    public static var languageSelectionList: Self {
        PersistenceKeyDefault(
//            .fileStorage(URL.documentsDirectory.appending(component: "languageSelectionList.json")), // causes a bad access crash??
            .inMemory("languageSelectionList.json"),
            {
                @Dependency(\.systemLanguages) var systemLanguages
                return systemLanguages.inDefaultSortOrder
            }()
        )
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Language.ID?>> {
    public static var focusedLanguage: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "focusedLanguage.json")),
            {
                @Dependency(\.systemLanguages) var systemLanguages
                return systemLanguages.inDefaultSortOrder.first
            }()
        )
    }
}

extension SystemLanguages {
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

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Repository>> {
    static var repo: Self {
        PersistenceKeyDefault(
            FileStorageKey.fileStorage(URL.documentsDirectory.appending(component: "repository.json")),
            .init()
        )
    }
}
