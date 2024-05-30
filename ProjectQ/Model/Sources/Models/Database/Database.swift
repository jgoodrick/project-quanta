
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Database>> {
    public static var db: Self {
        PersistenceKeyDefault(
            FileStorageKey.fileStorage(URL.documentsDirectory.appending(component: "db.json")),
            .init()
        )
    }
}

public struct Database: Equatable, Codable, Sendable {
    public init() {}
    
    internal var stored: Stored = .init()
    struct Stored: Equatable, Codable, Sendable {
        var users: [User.ID: User] = [:]
        var entries: [Entry.ID: Entry] = [:]
        var keywords: [Keyword.ID: Keyword] = [:]
        var languages: [Language.ID: Language] = [:]
        var notes: [Note.ID: Note] = [:]
        var usages: [Usage.ID: Usage] = [:]
        var entryCollections: [EntryCollection.ID: EntryCollection] = [:]
    }
    
    internal var relationships: Relationships = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var users: [User.ID: User.Relationships] = [:]
        var entries: [Entry.ID: Entry.Relationships] = [:]
        var keywords: [Keyword.ID: Keyword.Relationships] = [:]
        var languages: [Language.ID: Language.Relationships] = [:]
        var notes: [Note.ID: Note.Relationships] = [:]
        var usages: [Usage.ID: Usage.Relationships] = [:]
        var entryCollections: [EntryCollection.ID: EntryCollection.Relationships] = [:]
    }
    
}
