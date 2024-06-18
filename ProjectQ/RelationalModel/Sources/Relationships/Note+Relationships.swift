
import StructuralModel

extension Note: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entryTargets: Set<Entry.ID> = []
        var usageTargets: Set<Usage.ID> = []
        mutating func merge(with incoming: Self) {
            entryTargets.merge(with: incoming.entryTargets)
            usageTargets.merge(with: incoming.usageTargets)
        }
    }
    
}
