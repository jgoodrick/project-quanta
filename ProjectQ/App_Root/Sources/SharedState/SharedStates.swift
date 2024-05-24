
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<IdentifiedArrayOf<LanguageSelection>>> {
    public static var languageSelectionList: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "languageSelectionList.json")),
            IdentifiedArray.init(arrayLiteral: LanguageSelection.systemCurrent)
        )
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<LanguageSelection>> {
    public static var focusedLanguage: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "focusedLanguage.json")),
            LanguageSelection.systemCurrent
        )
    }
}
