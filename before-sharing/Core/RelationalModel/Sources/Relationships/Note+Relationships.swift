
import StructuralModel

extension Note: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entryTargets: Set<Entry.ID> = []
        var usageTargets: Set<Usage.ID> = []
        var connectedEntities: Set<Entity.ID> {
            var result = Set<Entity.ID>()
            result.formUnion(entryTargets.map(\.entityID))
            result.formUnion(usageTargets.map(\.entityID))
            return result
        }
        mutating func merge(with incoming: Self) {
            entryTargets.merge(with: incoming.entryTargets)
            usageTargets.merge(with: incoming.usageTargets)
        }
    }
    
}
