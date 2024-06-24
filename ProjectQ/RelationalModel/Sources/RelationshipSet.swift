
import StructuralModel

protocol RelationshipSet: Equatable, Mergeable {
    init()
    var connectedEntities: Set<Entity.ID> { get }
}

extension Dictionary where Value: RelationshipSet {
    subscript(id id: Key) -> Value {
        get { self[id, default: .init()] }
        set { self[id] = newValue }
    }
}
