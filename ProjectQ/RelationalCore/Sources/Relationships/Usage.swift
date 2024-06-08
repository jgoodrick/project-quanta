
import ModelCore

extension Usage: Mergeable {
    
    mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var languages: [Language.ID] = []
        var notes: [Note.ID] = []
        var uses: Set<Entry.ID> = []
        mutating func merge(with incoming: Self) {
            languages.merge(with: incoming.languages)
            notes.merge(with: incoming.notes)
            uses.merge(with: incoming.uses)
        }
    }
    
}

