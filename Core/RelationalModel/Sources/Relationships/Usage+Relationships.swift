
import StructuralModel

extension Usage: Mergeable {
    
    mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var languages: [Language.ID] = []
        var notes: [Note.ID] = []
        var uses: Set<Entry.ID> = []
        var connectedEntities: Set<Entity.ID> {
            var result = Set<Entity.ID>()
            result.formUnion(languages.map(\.entityID))
            result.formUnion(notes.map(\.entityID))
            result.formUnion(uses.map(\.entityID))
            return result
        }
        mutating func merge(with incoming: Self) {
            languages.merge(with: incoming.languages)
            notes.merge(with: incoming.notes)
            uses.merge(with: incoming.uses)
        }
    }
    
}

