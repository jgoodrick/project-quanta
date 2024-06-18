
import StructuralModel

extension Entity {
    public struct Relationship: Identifiable, Hashable, Codable, Sendable {
        public let id: Set<Entity.ID>
    }
}
