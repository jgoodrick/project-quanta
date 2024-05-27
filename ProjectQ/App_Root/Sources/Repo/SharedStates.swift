
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<IdentifiedArrayOf<LanguageSelection>>> {
    public static var languageSelectionList: Self {
        PersistenceKeyDefault(
//            .fileStorage(URL.documentsDirectory.appending(component: "languageSelectionList.json")), // causes a bad access crash??
            .inMemory("languageSelectionList.json"),
            [LanguageSelection.systemCurrent]
        )
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<LanguageSelection?>> {
    public static var focusedLanguage: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "focusedLanguage.json")),
            Optional<LanguageSelection>.some(.systemCurrent)
        )
    }
}
