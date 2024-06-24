
import StructuralModel

extension Keyword: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        title.merge(with: incoming.title)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var matches: [Entry.ID] = []
        var connectedEntities: Set<Entity.ID> {
            var result = Set<Entity.ID>()
            result.formUnion(matches.map(\.entityID))
            return result
        }
        mutating func merge(with incoming: Self) {
            matches.merge(with: incoming.matches)
        }
    }
}
