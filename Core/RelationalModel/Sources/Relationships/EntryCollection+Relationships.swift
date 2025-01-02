
import StructuralModel

extension EntryCollection: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        title.merge(with: incoming.title)
        description.merge(with: incoming.description)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entries: [Entry.ID] = []
        var connectedEntities: Set<Entity.ID> {
            var result = Set<Entity.ID>()
            result.formUnion(entries.map(\.entityID))
            return result
        }
        mutating func merge(with incoming: Self) {
            entries.merge(with: incoming.entries)
        }
    }
    
}

