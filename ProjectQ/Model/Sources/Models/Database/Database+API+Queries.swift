
import ComposableArchitecture

extension Shared<Database> {
    
    public var entriesByDescendingModifiedDate: [Entry.Expansion] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: {
            $0[keyPath: \.modified] > $1[keyPath: \.modified]
        })
        .execute(on: wrappedValue.stored.entries.keys)
    }
    
    public func firstEntry<T: Equatable>(where keyPath: KeyPath<Entry, T>, is value: T) -> Entry.Expansion? {
        for entry in wrappedValue.stored.entries.values {
            if entry[keyPath: keyPath] == value {
                return self[entry: entry.id]
            }
        }
        return nil
    }
    
    public func entries<T: Equatable>(where keyPath: KeyPath<Entry, T>, is value: T) -> [Entry.Expansion] {
        wrappedValue.stored.entries.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[entry: $0.id]
        })
    }
    
    public func translations(for entry: Entry.ID) -> [Entry.Expansion] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: wrappedValue.relationships.entries[id: entry].translations)
    }
    
}

struct Query<Value: Identifiable> {
    fileprivate init(expandWith expand: @escaping (Value.ID) -> Value?, predicate: ((Value) -> Bool)?, sortComparator: ((Value, Value) -> Bool)?) {
        self.expand = expand
        self.predicate = predicate
        self.sortComparator = sortComparator
    }
    
    var expand: (Value.ID) -> Value?
    var predicate: ((Value) -> Bool)?
    var sortComparator: ((Value, Value) -> Bool)?
    func execute(on ids: any Collection<Value.ID>) -> [Value] {
        var result = [Value]()
        if let predicate {
            for element in ids.compactMap({ expand($0) }) {
                if predicate(element) {
                    result.append(element)
                }
            }
        } else {
            result = ids.compactMap({ expand($0) })
        }
        if let sortComparator {
            result.sort(by: sortComparator)
        }
        return result
    }
}
