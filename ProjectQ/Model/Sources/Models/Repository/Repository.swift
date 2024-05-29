
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Repository>> {
    static var repository: Self {
        PersistenceKeyDefault(
            FileStorageKey.fileStorage(URL.documentsDirectory.appending(component: "repository.json")),
            .init()
        )
    }
}

public struct Repository: Equatable, Codable, Sendable {
    public init() {}
    
    internal var stored: Stored = .init()
    struct Stored: Equatable, Codable, Sendable {
        var entries: [Entry.ID: Entry] = [:]
        var keywords: [Keyword.ID: Keyword] = [:]
        var languages: [Language.ID: Language] = [:]
        var notes: [Note.ID: Note] = [:]
        var usages: [Usage.ID: Usage] = [:]
        var userCollections: [UserCollection.ID: UserCollection] = [:]
    }
    
    internal var relationships: Relationships = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var entries: [Entry.ID: Entry.Relationships] = [:]
        var keywords: [Keyword.ID: Keyword.Relationships] = [:]
        var languages: [Language.ID: Language.Relationships] = [:]
        var notes: [Note.ID: Note.Relationships] = [:]
        var usages: [Usage.ID: Usage.Relationships] = [:]
        var userCollections: [UserCollection.ID: UserCollection.Relationships] = [:]
    }
    
}

extension Dictionary {
    mutating func mutateAll(with closure: (inout Value) -> Void) {
        keys.forEach { closure(&self[$0]!) }
    }
}

extension Repository {
    public mutating func add(entry: Entry) {
        stored.entries[entry.id] = entry
    }
    public mutating func remove(entry entryID: Entry.ID) {
        stored.entries[entryID] = nil
        relationships.removeAllReferences(toEntry: entryID)
    }
}

