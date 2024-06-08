
import ModelCore

public enum TranslatableEntity: Equatable {
    case entry(Entry.ID)
    case usage(Usage.ID)
}

extension Database {

    public func entries(forLanguage language: Language) -> [Tracked<Entry>] {
        return Query(expandWith: { self[entry: $0] }, predicate: { _ in true }, sortComparator: {
            $0[keyPath: \.metadata.modified] > $1[keyPath: \.metadata.modified]
        })
        .execute(on: relationships.languages[language.id]?.entries ?? [])
    }

    public func keyboardLanguageID(for entity: TranslatableEntity) -> Language.ID? {
        let result: Language.ID? = switch entity {
        case .entry(let entryID):
            relationships.entries[id: entryID].languages.first
        case .usage(let usageID):
            relationships.usages[id: usageID].languages.first
        }
        return result
    }

}

extension Database {
    
    public func firstEntry<T: Equatable>(where keyPath: KeyPath<Tracked<Entry>, T>, is value: T) -> Tracked<Entry>? {
        for entry in stored.entries.values {
            if entry[keyPath: keyPath] == value {
                return self[entry: entry.id]
            }
        }
        return nil
    }
    
    public func entries<T: Equatable>(where keyPath: KeyPath<Tracked<Entry>, T>, is value: T) -> [Tracked<Entry>] {
        stored.entries.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[entry: $0.id]
        })
    }
    
    public func usages<T: Equatable>(where keyPath: KeyPath<Tracked<Usage>, T>, is value: T) -> [Tracked<Usage>] {
        stored.usages.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[usage: $0.id]
        })
    }
    
    public func notes<T: Equatable>(where keyPath: KeyPath<Tracked<Note>, T>, is value: T) -> [Tracked<Note>] {
        stored.notes.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[note: $0.id]
        })
    }
    
    public func languages<T: Equatable>(where keyPath: KeyPath<Tracked<Language>, T>, is value: T) -> [Tracked<Language>] {
        stored.languages.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[language: $0.id]
        })
    }
    
    public func languages(for translatableEntity: TranslatableEntity) -> [Tracked<Language>] {
        switch translatableEntity {
        case .entry(let id):
            relationships.entries[id]?.languages.compactMap({
                self[language: $0]
            }) ?? []
        case .usage(let id):
            relationships.usages[id]?.languages.compactMap({
                self[language: $0]
            }) ?? []
        }
    }
    
    public func translations(for entry: Entry.ID) -> [Tracked<Entry>] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].translations)
    }
    
    public func usages(for entry: Entry.ID) -> [Tracked<Usage>] {
        Query(expandWith: { self[usage: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].usages)
    }
    
    public func notes(for entry: Entry.ID) -> [Tracked<Note>] {
        Query(expandWith: { self[note: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].notes)
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
