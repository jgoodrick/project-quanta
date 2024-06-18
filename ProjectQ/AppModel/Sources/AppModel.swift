
import ComposableArchitecture
import Foundation
import RelationalModel
import StructuralModel

/**
 AppModel
 
 * Compose the observational, intentional, and underlying storage and relational components
    - so they are unified across the entire operation of the model layer
 * Inject dependencies on external systems, like generation of Dates or UUIDs
 * Provide a single (Shared), stable interface for applications to interact with
 * Establish the source of truth for cross-platform business logic and implementation details
 
 */
public struct AppModel {
        
    // Storage
    @Shared(.db) var db
    @Shared(.settings) var settings
    @Shared(.config) var config
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid
    @Dependency(\.locale) var locale
    @Dependency(\.logger["\(Self.self)"]) var log
    
}

extension AppModel {
    public init(db: Shared<Database>? = nil, settings: Shared<Settings>? = nil, config: Shared<Config>? = nil) {
        if let db { self._db = db }
        if let settings { self._settings = settings }
        if let config { self._config = config }
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<AppModel>> {
    public static var model: Self {
        PersistenceKeyDefault(
            InMemoryKey.inMemory("AppModel"),
            AppModel.init()
        )
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Database>> {
    fileprivate static var db: Self {
        PersistenceKeyDefault(
            FileStorageKey.fileStorage(URL.documentsDirectory.appending(component: "db.json")),
            Database.init()
        )
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Settings>> {
    fileprivate static var settings: Self {
        PersistenceKeyDefault(
            .fileStorage(URL.documentsDirectory.appending(component: "settings.json")), .defaultValue
        )
    }
}

extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<AppModel.Config>> {
    fileprivate static var config: Self {
        PersistenceKeyDefault(
            InMemoryKey.inMemory("AppModel.Config"),
            AppModel.Config.init()
        )
    }
}

