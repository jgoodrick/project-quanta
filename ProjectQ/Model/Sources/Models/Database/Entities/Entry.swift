
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Entry: Identifiable, Equatable, Codable, Sendable, Mergeable {
    public let id: UUID
    public var spelling: String = ""
    var alternateSpellings: [String] = []
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        spelling.merge(with: incoming.spelling)
        alternateSpellings.merge(with: incoming.alternateSpellings)
        metadata.merge(with: incoming.metadata)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var languages: [Language.ID] = []
        var roots: [Entry.ID] = []
        var derived: Set<Entry.ID> = []
        var translations: [Entry.ID] = []
        var backTranslations: Set<Entry.ID> = []
        var seeAlso: [Entry.ID] = []
        var usages: [Usage.ID] = []
        var keywords: Set<Keyword.ID> = []
        var notes: [Note.ID] = []
        var entryCollections: Set<EntryCollection.ID> = []
        mutating func merge(with incoming: Self) {
            languages.merge(with: incoming.languages)
            roots.merge(with: incoming.roots)
            derived.merge(with: incoming.derived)
            translations.merge(with: incoming.translations)
            backTranslations.merge(with: incoming.backTranslations)
            seeAlso.merge(with: incoming.seeAlso)
            usages.merge(with: incoming.usages)
            keywords.merge(with: incoming.keywords)
            notes.merge(with: incoming.notes)
            entryCollections.merge(with: incoming.entryCollections)
        }
    }
    
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<Entry>
        public let languages: [Language]
        public let roots: [Entry]
        public let derived: [Entry]
        public let translations: [Entry]
        public let backTranslations: [Entry]
        public let seeAlso: [Entry]
        public let usages: [Usage]
        public let keywords: [Keyword]
        public let notes: [Note]
        public let entryCollections: [EntryCollection]
        
        public var id: Entry.ID { shared.wrappedValue.id }
        public var spelling: String {
            get { shared.wrappedValue.spelling }
            set { shared.wrappedValue.spelling = newValue }
        }
        public var added: Date {
            get { shared.wrappedValue.metadata.added }
        }
        public var modified: Date {
            get { shared.wrappedValue.metadata.modified }
        }
    }
}
