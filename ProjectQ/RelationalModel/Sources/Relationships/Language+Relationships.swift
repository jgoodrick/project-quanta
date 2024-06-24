
import StructuralModel

extension Language: Mergeable {
        
    public mutating func merge(with incoming: Self) {}

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entries: Set<Entry.ID> = []
        var usages: Set<Usage.ID> = []
        var connectedEntities: Set<Entity.ID> {
            var result = Set<Entity.ID>()
            result.formUnion(entries.map(\.entityID))
            result.formUnion(usages.map(\.entityID))
            return result
        }
        mutating func merge(with incoming: Self) {
            entries.merge(with: incoming.entries)
            usages.merge(with: incoming.usages)
        }
    }
    
}
