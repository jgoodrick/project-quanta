
import ComposableArchitecture
import Foundation
import RelationalCore

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Database>> {
    public static var db: Self {
        PersistenceKeyDefault(
            FileStorageKey.fileStorage(URL.documentsDirectory.appending(component: "db.json")),
            {
                // seed the database with values from the system languages
                var db = Database.init()
                @Dependency(\.systemLanguages) var systemLanguages
                systemLanguages.allConfiguredTextInputModeLanguages().forEach {
                    db.ensureExistenceOf(language: $0)
                }
                return db
            }()
        )
    }
}

