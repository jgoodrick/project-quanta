
protocol RelationshipSet: Equatable, Mergeable {
    init()
}

extension RelationshipSet {
    var isOrphan: Bool { self == .init() }
}

extension Dictionary where Value: RelationshipSet {
    subscript(id id: Key) -> Value {
        get { self[id, default: .init()] }
        set { self[id] = newValue }
    }
}
