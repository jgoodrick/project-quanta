
import ModelCore

public struct Database: Equatable, Codable, Sendable {
    
    public init() {}
    
    internal var stored: Stored = .init()
    internal struct Stored: Equatable, Codable, Sendable {
        var entries: [Entry.ID: Tracked<Entry>] = [:]
        var keywords: [Keyword.ID: Tracked<Keyword>] = [:]
        var languages: [Language.ID: Tracked<Language>] = [:]
        var notes: [Note.ID: Tracked<Note>] = [:]
        var usages: [Usage.ID: Tracked<Usage>] = [:]
        var entryCollections: [EntryCollection.ID: Tracked<EntryCollection>] = [:]
    }
    
    internal var relationships: Relationships = .init()
    internal struct Relationships: Equatable, Codable, Sendable {
        var entries: [Entry.ID: Entry.Relationships] = [:]
        var keywords: [Keyword.ID: Keyword.Relationships] = [:]
        var languages: [Language.ID: Language.Relationships] = [:]
        var notes: [Note.ID: Note.Relationships] = [:]
        var usages: [Usage.ID: Usage.Relationships] = [:]
        var entryCollections: [EntryCollection.ID: EntryCollection.Relationships] = [:]
    }
    
}
