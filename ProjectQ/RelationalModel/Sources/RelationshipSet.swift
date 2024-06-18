
protocol RelationshipSet: Equatable, Mergeable {
    init()
}

extension RelationshipSet {
    public var areEmpty: Bool { self == .init() }
}

extension Dictionary where Value: RelationshipSet {
    subscript(id id: Key) -> Value {
        get { self[id, default: .init()] }
        set { self[id] = newValue }
    }
}
