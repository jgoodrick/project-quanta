
import ModelCore

extension Note: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
    }

    public enum Target: Hashable, Codable, Sendable {
        case entry(Entry.ID)
        case usage(Usage.ID)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var targets: Set<Target> = []
        mutating func merge(with incoming: Self) {
            targets.merge(with: incoming.targets)
        }
    }
    
}
