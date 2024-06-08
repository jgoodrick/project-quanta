
import ModelCore

public enum TranslatableEntity: Equatable {
    case entry(Entry.ID)
    case usage(Usage.ID)
}

extension Database {

    public func entries(forLanguage language: Language) -> [Entry] {
        return Query(expandWith: { self[entry: $0] }, predicate: { _ in true }, sortComparator: {
            guard let lhs = stored.entries[$0.id], let rhs = stored.entries[$1.id] else {
                return true
            }
            return lhs.metadata.modified > rhs.metadata.modified
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
    
    public func firstEntry<T: Equatable>(where keyPath: KeyPath<Entry, T>, is value: T) -> Entry? {
        for entry in stored.entries.values.map(\.value) {
            if entry[keyPath: keyPath] == value {
                return self[entry: entry.id]
            }
        }
        return nil
    }
    
    public func entries<T: Equatable>(where keyPath: KeyPath<Entry, T>, is value: T) -> [Entry] {
        stored.entries.values.map(\.value).filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[entry: $0.id]
        })
    }
    
    public func usages<T: Equatable>(where keyPath: KeyPath<Usage, T>, is value: T) -> [Usage] {
        stored.usages.values.map(\.value).filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[usage: $0.id]
        })
    }
    
    public func notes<T: Equatable>(where keyPath: KeyPath<Note, T>, is value: T) -> [Note] {
        stored.notes.values.map(\.value).filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[note: $0.id]
        })
    }
    
    public func languages<T: Equatable>(where keyPath: KeyPath<Language, T>, is value: T) -> [Language] {
        stored.languages.values.map(\.value).filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[language: $0.id]
        })
    }
    
    public func languages(for translatableEntity: TranslatableEntity) -> [Language] {
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
    
    public func translations(for entry: Entry.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].translations)
    }
    
    public func usages(for entry: Entry.ID) -> [Usage] {
        Query(expandWith: { self[usage: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].usages)
    }
    
    public func notes(for entry: Entry.ID) -> [Note] {
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
