
import ComposableArchitecture

extension Shared<Repository> {

    func entryAggregate(id: Entry.ID) -> Entry.Aggregate? {
        guard let entry = projectedValue.stored.entries[id] else { return nil }
        let relationships = wrappedValue.relationships.entries[id, default: .init()]
        let language = relationships.language.flatMap({ wrappedValue.stored.languages[$0] })
        let root = relationships.root.flatMap({ wrappedValue.stored.entries[$0] })
        let derived = relationships.derived.compactMap({ wrappedValue.stored.entries[$0] })
        let translations = relationships.translations.compactMap({ wrappedValue.stored.entries[$0] })
        let backTranslations = relationships.backTranslations.compactMap({ wrappedValue.stored.entries[$0] })
        let seeAlso = relationships.seeAlso.compactMap({ wrappedValue.stored.entries[$0] })
        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[$0] })
        let keywords = relationships.keywords.compactMap({ wrappedValue.stored.keywords[$0] })
        let notes = relationships.notes.compactMap({ wrappedValue.stored.notes[$0] })
        let userCollections = relationships.userCollections.compactMap({ wrappedValue.stored.userCollections[$0] })
        return .init(
            entry: entry,
            language: language,
            root: root,
            derived: derived,
            translations: translations,
            backTranslations: backTranslations,
            seeAlso: seeAlso,
            usages: usages,
            keywords: keywords,
            notes: notes,
            userCollections: userCollections
        )
    }
    
    func keywordAggregate(id: Keyword.ID) -> Keyword.Aggregate? {
        guard let keyword = projectedValue.stored.keywords[id] else { return nil }
        let relationships = wrappedValue.relationships.keywords[id, default: .init()]
        let matches = relationships.matches.compactMap({ wrappedValue.stored.entries[$0] })
        return .init(
            keyword: keyword,
            matches: matches
        )
    }
    
    func languageAggregate(id: Language.ID) -> Language.Aggregate? {
        guard let language = projectedValue.stored.languages[id] else { return nil }
        let relationships = wrappedValue.relationships.languages[id, default: .init()]
        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[$0] })
        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[$0] })
        return .init(
            language: language,
            entries: entries,
            usages: usages
        )
    }
    
    func noteAggregate(id: Note.ID) -> Note.Aggregate? {
        guard let note = projectedValue.stored.notes[id] else { return nil }
        let relationships = wrappedValue.relationships.notes[id, default: .init()]
        var target: Note.Aggregate.Target?
        switch relationships.target {
        case .none: break
        case .entry(let entryID):
            if let entry = wrappedValue.stored.entries[entryID] {
                target = .entry(entry)
            }
        case .usage(let usageID):
            if let usage = wrappedValue.stored.usages[usageID] {
                target = .usage(usage)
            }
        }
        return .init(
            note: note,
            target: target
        )
    }

    func usageAggregate(id: Usage.ID) -> Usage.Aggregate? {
        guard let usage = projectedValue.stored.usages[id] else { return nil }
        let relationships = wrappedValue.relationships.usages[id, default: .init()]
        let note = relationships.note.flatMap({ wrappedValue.stored.notes[$0] })
        let uses = relationships.uses.compactMap({ wrappedValue.stored.entries[$0] })
        return .init(
            usage: usage,
            note: note,
            uses: uses
        )
    }
    
    func userCollectionAggregate(id: UserCollection.ID) -> UserCollection.Aggregate? {
        guard let userCollection = projectedValue.stored.userCollections[id] else { return nil }
        let relationships = wrappedValue.relationships.userCollections[id, default: .init()]
        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[$0] })
        return .init(
            userCollection: userCollection,
            entries: entries
        )
    }
    
}

extension Shared<Repository> {
    
    func entryAggregates(for ids: (any Collection<Entry.ID>)? = nil, filteredBy: ((Entry.Aggregate) -> Bool)? = nil, sortedBy: ((Entry.Aggregate, Entry.Aggregate) -> Bool)? = nil) -> [Entry.Aggregate] {
        Query({ entryAggregate(id: $0) }, filteredBy, sortedBy)
            .execute(on: ids ?? wrappedValue.stored.entries.keys)
    }
    
    func keywordAggregates(for ids: (any Collection<Keyword.ID>)? = nil, filteredBy: ((Keyword.Aggregate) -> Bool)? = nil, sortedBy: @escaping (Keyword.Aggregate, Keyword.Aggregate) -> Bool) -> [Keyword.Aggregate] {
        Query({ keywordAggregate(id: $0) }, filteredBy, sortedBy)
            .execute(on: ids ?? wrappedValue.stored.keywords.keys)
    }
    
    func languageAggregates(for ids: (any Collection<Language.ID>)? = nil, filteredBy: ((Language.Aggregate) -> Bool)? = nil, sortedBy: ((Language.Aggregate, Language.Aggregate) -> Bool)?) -> [Language.Aggregate] {
        Query({ languageAggregate(id: $0) }, filteredBy, sortedBy)
            .execute(on: ids ?? wrappedValue.stored.languages.keys)
    }
    
    func noteAggregates(for ids: (any Collection<Note.ID>)? = nil, filteredBy: ((Note.Aggregate) -> Bool)? = nil, sortedBy: ((Note.Aggregate, Note.Aggregate) -> Bool)?) -> [Note.Aggregate] {
        Query({ noteAggregate(id: $0) }, filteredBy, sortedBy)
            .execute(on: ids ?? wrappedValue.stored.notes.keys)
    }
    
    func usageAggregates(for ids: (any Collection<Usage.ID>)? = nil, filteredBy: ((Usage.Aggregate) -> Bool)? = nil, sortedBy: ((Usage.Aggregate, Usage.Aggregate) -> Bool)?) -> [Usage.Aggregate] {
        Query({ usageAggregate(id: $0) }, filteredBy, sortedBy)
            .execute(on: ids ?? wrappedValue.stored.usages.keys)
    }
    
    func userCollectionAggregates(for ids: (any Collection<UserCollection.ID>)? = nil, filteredBy: ((UserCollection.Aggregate) -> Bool)? = nil, sortedBy: ((UserCollection.Aggregate, UserCollection.Aggregate) -> Bool)?) -> [UserCollection.Aggregate] {
        Query({ userCollectionAggregate(id: $0) }, filteredBy, sortedBy)
            .execute(on: ids ?? wrappedValue.stored.userCollections.keys)
    }
    
}

struct Query<Value: Identifiable> {
    fileprivate init(_ expand: @escaping (Value.ID) -> Value?, _ predicate: ((Value) -> Bool)?, _ sortComparator: ((Value, Value) -> Bool)?) {
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
