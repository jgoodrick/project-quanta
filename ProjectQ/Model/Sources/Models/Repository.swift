
import ComposableArchitecture
import SwiftUI

public struct Repository: Equatable, Codable, Sendable {
    public init() {}
    
    internal var stored: Stored = .init()
    struct Stored: Equatable, Codable, Sendable {
        var entries: Storage<Entry> = .init()
        var usages: Storage<Usage> = .init()
        var languages: Storage<Language> = .init()
        var keywords: Storage<Keyword> = .init()
        var notes: Storage<Note> = .init()
        var userCollections: Storage<UserCollection> = .init()
    }
    
    internal var relationships: Relationships = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var entries: [Entry.ID: Entry.Relationships] = [:]
        var usages: [Usage.ID: Usage.Relationships] = [:]
        var languages: [Language.ID: Language.Relationships] = [:]
        var keywords: [Keyword.ID: Keyword.Relationships] = [:]
        var notes: [Note.ID: Note.Relationships] = [:]
        var userCollections: [UserCollection.ID: UserCollection.Relationships] = [:]
    }
    
}

