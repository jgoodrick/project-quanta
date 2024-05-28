
struct Storage<Value: Identifiable & Equatable & Codable & Sendable>: Equatable, Codable, Sendable where Value.ID: Hashable & Codable & Sendable {
    init() {}
    var _storage: [Value.ID: Value] = [:]
    init(_storage: [Value.ID: Value] = [:]) {
        self._storage = _storage
    }
}

