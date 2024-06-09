
import ModelCore

public enum TranslatableEntity: Equatable {
    case entry(Entry.ID)
    case usage(Usage.ID)
}

extension Database {

    public func entries(forLanguage language: Language.ID? = nil) -> [Entry] {
        let ids: any Collection<Entry.ID>
        if let language {
            ids = relationships.languages[language]?.entries ?? []
        } else {
            ids = stored.entries.keys
        }
        return Query(expandWith: { self[entry: $0] }, predicate: { _ in true }, sortComparator: {
            guard let lhs = stored.entries[$0.id], let rhs = stored.entries[$1.id] else {
                return true
            }
            return lhs.metadata.modified > rhs.metadata.modified
        })
        .execute(on: ids)
    }

    public func usages(forLanguage language: Language.ID? = nil) -> [Usage] {
        let ids: any Collection<Usage.ID>
        if let language {
            ids = relationships.languages[language]?.usages ?? []
        } else {
            ids = stored.usages.keys
        }
        return Query(expandWith: { self[usage: $0] }, predicate: { _ in true }, sortComparator: {
            guard let lhs = stored.usages[$0.id], let rhs = stored.usages[$1.id] else {
                return true
            }
            return lhs.metadata.modified > rhs.metadata.modified
        })
        .execute(on: ids)
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
    
    public func firstEntry(where predicate: (Entry) -> Bool) -> Entry? {
        for entry in stored.entries.values.map(\.value) {
            if predicate(entry) {
                return entry
            }
        }
        return nil
    }
    
    public func entries(where filter: ((Entry) -> Bool)? = nil, sort: ((Entry, Entry) -> Bool)? = nil) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: filter, sortComparator: sort)
            .execute(on: stored.entries.keys)
    }
    
    public func languages(where filter: ((Language) -> Bool)? = nil, sort: ((Language, Language) -> Bool)? = nil) -> [Language] {
        Query(expandWith: { self[language: $0] }, predicate: filter, sortComparator: sort)
            .execute(on: stored.languages.keys)
    }
    
    public func keywords(where filter: ((Keyword) -> Bool)? = nil, sort: ((Keyword, Keyword) -> Bool)? = nil) -> [Keyword] {
        Query(expandWith: { self[keyword: $0] }, predicate: filter, sortComparator: sort)
            .execute(on: stored.keywords.keys)
    }
    
    public func notes(where filter: ((Note) -> Bool)? = nil, sort: ((Note, Note) -> Bool)? = nil) -> [Note] {
        Query(expandWith: { self[note: $0] }, predicate: filter, sortComparator: sort)
            .execute(on: stored.notes.keys)
    }
    
    public func usages(where filter: ((Usage) -> Bool)? = nil, sort: ((Usage, Usage) -> Bool)? = nil) -> [Usage] {
        Query(expandWith: { self[usage: $0] }, predicate: filter, sortComparator: sort)
            .execute(on: stored.usages.keys)
    }
    
    public func entryCollections(where filter: ((EntryCollection) -> Bool)? = nil, sort: ((EntryCollection, EntryCollection) -> Bool)? = nil) -> [EntryCollection] {
        Query(expandWith: { self[entryCollection: $0] }, predicate: filter, sortComparator: sort)
            .execute(on: stored.entryCollections.keys)
    }
    
    public func languages(for translatableEntity: TranslatableEntity) -> [Language] {
        switch translatableEntity {
        case .entry(let id):
            languages(forEntry: id)
        case .usage(let id):
            languages(forUsage: id)
        }
    }
    
    public func languages(forEntry entry: Entry.ID) -> [Language] {
        Query(expandWith: { self[language: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].languages)
    }
    
    public func translations(forEntry entry: Entry.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].translations)
    }
    
    public func backTranslations(forEntry entry: Entry.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].backTranslations)
    }
    
    public func roots(forEntry entry: Entry.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].roots)
    }
    
    public func derived(forEntry entry: Entry.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].derived)
    }
    
    public func seeAlso(forEntry entry: Entry.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].seeAlso)
    }
    
    public func keywords(forEntry entry: Entry.ID) -> [Keyword] {
        Query(expandWith: { self[keyword: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].keywords)
    }
    
    public func usages(forEntry entry: Entry.ID) -> [Usage] {
        Query(expandWith: { self[usage: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].usages)
    }
    
    public func notes(forEntry entry: Entry.ID) -> [Note] {
        Query(expandWith: { self[note: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].notes)
    }
    
    public func entries(inCollection entryCollection: EntryCollection.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entryCollections[id: entryCollection].entries)
    }
    
    public func entries(matchingKeyword keyword: Keyword.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.keywords[id: keyword].matches)
    }
    
    public func entries(targetedByNote note: Note.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.notes[id: note].entryTargets)
    }
    
    public func entries(inUsage usage: Usage.ID) -> [Entry] {
        Query(expandWith: { self[entry: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.usages[id: usage].uses)
    }
    
    public func notes(forUsage usage: Usage.ID) -> [Note] {
        Query(expandWith: { self[note: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.usages[id: usage].notes)
    }
    
    public func languages(forUsage usage: Usage.ID) -> [Language] {
        Query(expandWith: { self[language: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.usages[id: usage].languages)
    }
    
    public func usages(targetedByNote note: Note.ID) -> [Usage] {
        Query(expandWith: { self[usage: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.notes[id: note].usageTargets)
    }
    
    public func entryCollections(forEntry entry: Entry.ID) -> [EntryCollection] {
        Query(expandWith: { self[entryCollection: $0] }, predicate: .none, sortComparator: .none)
            .execute(on: relationships.entries[id: entry].entryCollections)
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
