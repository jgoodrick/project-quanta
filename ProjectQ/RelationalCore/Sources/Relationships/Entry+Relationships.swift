
import ModelCore

extension Entry: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        spelling.merge(with: incoming.spelling)
        alternateSpellings.merge(with: incoming.alternateSpellings)
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
}
