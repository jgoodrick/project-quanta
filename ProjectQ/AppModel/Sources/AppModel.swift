
import ComposableArchitecture
import Foundation
import RelationalModel
import StructuralModel
import OSLog

/**
 AppModel
 
 * Compose the observational, intentional, and underlying storage and relational components
    - so they are unified across the entire operation of the model layer
 * Inject dependencies on external systems, like generation of Dates or UUIDs
 * Provide a single (Shared), stable interface for applications to interact with
 * Establish the source of truth for cross-platform business logic and implementation details
 
 */
public struct AppModel: Equatable {
        
    // Storage
    @Shared(.db) var db
    @Shared(.settings) public var settings
    @Shared(.config) var config
    
    public var date: DateGenerator {
        @Dependency(\.date) var date; return date
    }
    public var uuid: UUIDGenerator {
        @Dependency(\.uuid) var uuid; return uuid
    }
    public var locale: Locale {
        @Dependency(\.locale) var locale; return locale
    }
    public var log: Logger {
        @Dependency(\.logger["\(Self.self)"]) var log; return log
    }
    
    public init(db injectedDB: Shared<Database>? = nil, settings injectedSettings: Shared<Settings>? = nil, config injectedConfig: Shared<Config>? = nil) {
        if let injectedDB { self._db = injectedDB }
        if let injectedSettings { self._settings = injectedSettings }
        if let injectedConfig { self._config = injectedConfig }
        seedWithSystemLanguages()
    }
    
    private mutating func seedWithSystemLanguages() {
        ensureExistenceOf(language: settings.defaultNewEntryLanguage)
        ensureExistenceOf(language: settings.defaultTranslationLanguage)
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

