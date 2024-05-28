
protocol LookupStorage<Value> {
    associatedtype Value: Identifiable
    subscript(id id: Value.ID) -> Value? { get set }
}

protocol QueryableStorage<Value> {
    associatedtype Value: Identifiable
    func values(predicate: (Value) -> Bool, sort: (Value, Value) -> Bool) -> [Value]
}

extension Storage: LookupStorage {
    subscript(id id: Value.ID) -> Value? {
        _read { yield self._storage[id] }
        _modify {
            yield &self._storage[id]
        }
        set {
            if let newValue {
                self._storage.updateValue(newValue, forKey: id)
            } else {
                self._storage.removeValue(forKey: id)
            }
        }
    }
}
