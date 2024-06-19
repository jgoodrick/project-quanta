
import Foundation
import StructuralModel

public enum SortField<Value> {
    case created
    case modified
    case custom((Value, Value) -> Bool)
    var comparison: (Tracked<Value>, Tracked<Value>) -> Bool {
        switch self {
        case .created: { $0.metadata.created < $1.metadata.created }
        case .modified: { $0.metadata.modified < $1.metadata.modified }
        case .custom(let custom): { custom($0.value, $1.value) }
        }
    }
}

fileprivate extension Database {
    func trackedValues<ID: Hashable, Value>(ids: any Collection<ID>, expandWith expand: (ID) -> Tracked<Value>?, predicate: ((Value) -> Bool)?, sortComparator: ((Tracked<Value>, Tracked<Value>) -> Bool)?) -> [Tracked<Value>] {
        var result = [Tracked<Value>]()
        if let predicate {
            for element in ids.compactMap({ expand($0) }) {
                if predicate(element.value) {
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
    func values<ID: Hashable, Value>(ids: any Collection<ID>, expandWith expand: (ID) -> Tracked<Value>?, predicate: ((Value) -> Bool)?, sortComparator: ((Tracked<Value>, Tracked<Value>) -> Bool)?) -> [Value] {
        trackedValues(
            ids: ids,
            expandWith: expand,
            predicate: predicate,
            sortComparator: sortComparator
        ).map(\.value)
    }
}

// translatable entities
extension Database {
    
    public func languages(
        for translatableEntity: TranslatableEntity,
        where additionalPredicate: ((Language) -> Bool)? = nil,
        sortedBy sort: SortField<Language>? = nil
    ) -> [Language] {
        switch translatableEntity {
        case .entry(let id):
            languages(forEntry: id, where: additionalPredicate, sortedBy: sort)
        case .usage(let id):
            languages(forUsage: id, where: additionalPredicate, sortedBy: sort)
        }
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

// second order predicates
extension Database {
    
    public func entryCollections(
        includingLanguage language: Language.ID,
        where additionalPredicate: ((EntryCollection) -> Bool)? = nil,
        sortedBy sort: SortField<EntryCollection> = .modified
    ) -> [EntryCollection] {
        let languageEntries = relationships.languages[id: language].entries
        let matchingCollections = relationships.entryCollections.compactMap({ (id, relationships) in
            relationships.entries.first(where: { languageEntries.contains($0) }) != nil ? id : nil
        })
        return values(
            ids: matchingCollections,
            expandWith: { tracked(entryCollection: $0) },
            predicate: additionalPredicate,
            sortComparator: sort.comparison
        )
    }
    
}

// early out
extension Database {
    
    public func firstEntry(where predicate: (Entry) -> Bool) -> Entry? {
        for entry in stored.entries.values.map(\.value) {
            if predicate(entry) {
                return entry
            }
        }
        return nil
    }
    
}

// unrestricted model value predicates
extension Database {
    
    public func entries(
        where predicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: stored.entries.keys,
            expandWith: { tracked(entry: $0) },
            predicate: predicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func languages(
        where predicate: ((Language) -> Bool)? = nil,
        sortedBy sort: SortField<Language>? = nil
    ) -> [Language] {
        values(
            ids: stored.languages.keys,
            expandWith: { tracked(language: $0) },
            predicate: predicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func keywords(
        where predicate: ((Keyword) -> Bool)? = nil,
        sortedBy sort: SortField<Keyword>? = nil
    ) -> [Keyword] {
        values(
            ids: stored.keywords.keys,
            expandWith: { tracked(keyword: $0) },
            predicate: predicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func notes(
        where predicate: ((Note) -> Bool)? = nil,
        sortedBy sort: SortField<Note>? = nil
    ) -> [Note] {
        values(
            ids: stored.notes.keys,
            expandWith: { tracked(note: $0) },
            predicate: predicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func usages(
        where predicate: ((Usage) -> Bool)? = nil,
        sortedBy sort: SortField<Usage>? = nil
    ) -> [Usage] {
        values(
            ids: stored.usages.keys,
            expandWith: { tracked(usage: $0) },
            predicate: predicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func entryCollections(
        where predicate: ((EntryCollection) -> Bool)? = nil,
        sortedBy sort: SortField<EntryCollection>? = nil
    ) -> [EntryCollection] {
        values(
            ids: stored.entryCollections.keys,
            expandWith: { tracked(entryCollection: $0) },
            predicate: predicate,
            sortComparator: sort?.comparison
        )
    }
}

// first order predicate + additional
extension Database {
    
    public func languages(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Language) -> Bool)? = nil,
        sortedBy sort: SortField<Language>? = nil
    ) -> [Language] {
        values(
            ids: relationships.entries[id: entry].languages, 
            expandWith: { tracked(language: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func translations(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.entries[id: entry].translations,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func backTranslations(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.entries[id: entry].backTranslations,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func roots(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.entries[id: entry].roots,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func derived(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.entries[id: entry].derived,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func seeAlso(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.entries[id: entry].seeAlso,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func keywords(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Keyword) -> Bool)? = nil,
        sortedBy sort: SortField<Keyword>? = nil
    ) -> [Keyword] {
        values(
            ids: relationships.entries[id: entry].keywords,
            expandWith: { tracked(keyword: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func usages(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Usage) -> Bool)? = nil,
        sortedBy sort: SortField<Usage>? = nil
    ) -> [Usage] {
        values(
            ids: relationships.entries[id: entry].usages,
            expandWith: { tracked(usage: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func notes(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((Note) -> Bool)? = nil,
        sortedBy sort: SortField<Note>? = nil
    ) -> [Note] {
        values(
            ids: relationships.entries[id: entry].notes,
            expandWith: { tracked(note: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func entries(
        forLanguage language: Language.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.languages[id: language].entries,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }

    public func usages(
        forLanguage language: Language.ID,
        where additionalPredicate: ((Usage) -> Bool)? = nil,
        sortedBy sort: SortField<Usage>? = nil
    ) -> [Usage] {
        values(
            ids: relationships.languages[id: language].usages,
            expandWith: { tracked(usage: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func entries(
        inCollection entryCollection: EntryCollection.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.entryCollections[id: entryCollection].entries,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func entries(
        matchingKeyword keyword: Keyword.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.keywords[id: keyword].matches,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func entries(
        targetedByNote note: Note.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.notes[id: note].entryTargets,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func entries(
        inUsage usage: Usage.ID,
        where additionalPredicate: ((Entry) -> Bool)? = nil,
        sortedBy sort: SortField<Entry>? = nil
    ) -> [Entry] {
        values(
            ids: relationships.usages[id: usage].uses,
            expandWith: { tracked(entry: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func notes(
        forUsage usage: Usage.ID,
        where additionalPredicate: ((Note) -> Bool)? = nil,
        sortedBy sort: SortField<Note>? = nil
    ) -> [Note] {
        values(
            ids: relationships.usages[id: usage].notes,
            expandWith: { tracked(note: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func languages(
        forUsage usage: Usage.ID,
        where additionalPredicate: ((Language) -> Bool)? = nil,
        sortedBy sort: SortField<Language>? = nil
    ) -> [Language] {
        values(
            ids: relationships.usages[id: usage].languages,
            expandWith: { tracked(language: $0) },
            predicate: additionalPredicate,
            sortComparator: sort?.comparison
        )
    }
    
    public func usages(
        targetedByNote note: Note.ID,
        where additionalPredicate: ((Usage) -> Bool)? = nil,
        sortedBy sort: SortField<Usage> = .modified
    ) -> [Usage] {
        values(
            ids: relationships.notes[id: note].usageTargets,
            expandWith: { tracked(usage: $0) },
            predicate: additionalPredicate,
            sortComparator: sort.comparison
        )
    }
    
    public func entryCollections(
        forEntry entry: Entry.ID,
        where additionalPredicate: ((EntryCollection) -> Bool)? = nil,
        sortedBy sort: SortField<EntryCollection> = .modified
    ) -> [EntryCollection] {
        values(
            ids: relationships.entries[id: entry].entryCollections,
            expandWith: { tracked(entryCollection: $0) },
            predicate: additionalPredicate,
            sortComparator: sort.comparison
        )
    }
    
}

