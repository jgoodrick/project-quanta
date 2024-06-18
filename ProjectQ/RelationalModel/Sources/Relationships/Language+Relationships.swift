
import StructuralModel

extension Language: Mergeable {
        
    public mutating func merge(with incoming: Self) {}

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entries: Set<Entry.ID> = []
        var usages: Set<Usage.ID> = []
        mutating func merge(with incoming: Self) {
            entries.merge(with: incoming.entries)
            usages.merge(with: incoming.usages)
        }
    }
    
}
