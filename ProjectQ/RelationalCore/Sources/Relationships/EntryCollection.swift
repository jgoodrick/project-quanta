
import ModelCore

extension EntryCollection: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        title.merge(with: incoming.title)
        description.merge(with: incoming.description)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entries: [Entry.ID] = []
        mutating func merge(with incoming: Self) {
            entries.merge(with: incoming.entries)
        }
    }
    
}

