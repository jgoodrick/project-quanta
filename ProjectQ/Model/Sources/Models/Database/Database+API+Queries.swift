
import ComposableArchitecture

public enum TranslatableEntity: Equatable {
    case entry(Entry.ID)
    case usage(Usage.ID)
}

extension Database {
    
    public var focusedEntriesList: [Entry.Expansion] {
        @Shared(.db) var db
        return Query(expandWith: { $db[entry: $0] }, predicate: {
            @Shared(.settings) var settings
            return $0.languages.contains(where: { $0.id == settings.focusedLanguage.id })
        }, sortComparator: {
            $0[keyPath: \.modified] > $1[keyPath: \.modified]
        })
        .execute(on: stored.entries.keys)
    }

    public func keyboardLanguageID(for entity: TranslatableEntity) -> Language.ID {
        @Dependency(\.systemLanguages) var systemLanguages
        let result: Language.ID? = switch entity {
        case .entry(let entryID):
            relationships.entries[id: entryID].languages.first
        case .usage(let usageID):
            relationships.usages[id: usageID].languages.first
        }
        return result ?? systemLanguages.current().id
    }
    
}

extension Shared<Database> {
    
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
    
    public func usages<T: Equatable>(where keyPath: KeyPath<Usage, T>, is value: T) -> [Usage.Expansion] {
        wrappedValue.stored.usages.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[usage: $0.id]
        })
    }
    
    public func notes<T: Equatable>(where keyPath: KeyPath<Note, T>, is value: T) -> [Note.Expansion] {
        wrappedValue.stored.notes.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[note: $0.id]
        })
    }
    
    public func languages<T: Equatable>(where keyPath: KeyPath<Language, T>, is value: T) -> [Language.Expansion] {
        wrappedValue.stored.languages.values.filter({
            $0[keyPath: keyPath] == value
        }).compactMap({
            self[language: $0.id]
        })
    }
    
    public func translations(for entry: Entry.ID) -> [Entry.Expansion] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: wrappedValue.relationships.entries[id: entry].translations)
    }
    
    public func usages(for entry: Entry.ID) -> [Usage.Expansion] {
        Query(expandWith: { self[usage: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: wrappedValue.relationships.entries[id: entry].usages)
    }
    
    public func notes(for entry: Entry.ID) -> [Note.Expansion] {
        Query(expandWith: { self[note: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: wrappedValue.relationships.entries[id: entry].notes)
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
