
import ModelCore

extension Keyword: Mergeable {
    
    public mutating func merge(with incoming: Self) {
        title.merge(with: incoming.title)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var matches: [Entry.ID] = []
        mutating func merge(with incoming: Self) {
            matches.merge(with: incoming.matches)
        }
    }
}
