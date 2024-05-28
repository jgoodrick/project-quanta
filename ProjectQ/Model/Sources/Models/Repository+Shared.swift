
import ComposableArchitecture

extension Shared<Repository> {

    func entryAggregate(id: Entry.ID) -> Entry.Aggregate? {
        guard let entry = projectedValue.stored.entries[id: id] else { return nil }
        let relationships = wrappedValue.relationships.entries[id, default: .init()]
        let language = relationships.language.flatMap({ wrappedValue.stored.languages[id: $0] })
        let root = relationships.root.flatMap({ wrappedValue.stored.entries[id: $0] })
        let translations = relationships.translations.compactMap({ wrappedValue.stored.entries[id: $0] })
        let backTranslations = relationships.backTranslations.compactMap({ wrappedValue.stored.entries[id: $0] })
        let other = relationships.other.compactMap({ wrappedValue.stored.entries[id: $0] })
        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[id: $0] })
        let keywords = relationships.keywords.compactMap({ wrappedValue.stored.keywords[id: $0] })
        let notes = relationships.notes.compactMap({ wrappedValue.stored.notes[id: $0] })
        let userCollections = relationships.userCollections.compactMap({ wrappedValue.stored.userCollections[id: $0] })
        return .init(
            entry: entry,
            language: language,
            root: root,
            translations: translations,
            backTranslations: backTranslations,
            other: other,
            usages: usages,
            keywords: keywords,
            notes: notes,
            userCollections: userCollections
        )
    }
    
    func keywordAggregate(id: Keyword.ID) -> Keyword.Aggregate? {
        guard let keyword = projectedValue.stored.keywords[id: id] else { return nil }
        let relationships = wrappedValue.relationships.keywords[id, default: .init()]
        let matches = relationships.matches.compactMap({ wrappedValue.stored.entries[id: $0] })
        return .init(
            keyword: keyword,
            matches: matches
        )
    }
    
    func languageAggregate(id: Language.ID) -> Language.Aggregate? {
        guard let language = projectedValue.stored.languages[id: id] else { return nil }
        let relationships = wrappedValue.relationships.languages[id, default: .init()]
        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[id: $0] })
        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[id: $0] })
        return .init(
            language: language,
            entries: entries,
            usages: usages
        )
    }
    
    func noteAggregate(id: Note.ID) -> Note.Aggregate? {
        guard let note = projectedValue.stored.notes[id: id] else { return nil }
        let relationships = wrappedValue.relationships.notes[id, default: .init()]
        let entry = relationships.entry.flatMap({ wrappedValue.stored.entries[id: $0] })
        return .init(
            note: note,
            entry: entry
        )
    }

    func usageAggregate(id: Usage.ID) -> Usage.Aggregate? {
        guard let usage = projectedValue.stored.usages[id: id] else { return nil }
        let relationships = wrappedValue.relationships.usages[id, default: .init()]
        let note = relationships.note.flatMap({ wrappedValue.stored.notes[id: $0] })
        let uses = relationships.uses.compactMap({ wrappedValue.stored.entries[id: $0] })
        return .init(
            usage: usage,
            note: note,
            uses: uses
        )
    }
    
    func userCollectionAggregate(id: UserCollection.ID) -> UserCollection.Aggregate? {
        guard let userCollection = projectedValue.stored.userCollections[id: id] else { return nil }
        let relationships = wrappedValue.relationships.userCollections[id, default: .init()]
        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[id: $0] })
        return .init(
            userCollection: userCollection,
            entries: entries
        )
    }
    
}

extension Shared<Repository> {
    
    func entryAggregates(for ids: [Entry.ID], filteredBy: @escaping (Entry.Aggregate) -> Bool = { _ in true }, sortedBy: @escaping (Entry.Aggregate, Entry.Aggregate) -> Bool) -> [Entry.Aggregate] {
        Query({ entryAggregate(id: $0) }, filteredBy, sortedBy).execute(on: ids)
    }
    
    func keywordAggregates(for ids: [Keyword.ID], filteredBy: @escaping (Keyword.Aggregate) -> Bool = { _ in true }, sortedBy: @escaping (Keyword.Aggregate, Keyword.Aggregate) -> Bool) -> [Keyword.Aggregate] {
        Query({ keywordAggregate(id: $0) }, filteredBy, sortedBy).execute(on: ids)
    }
    
    func languageAggregates(for ids: [Language.ID], filteredBy: @escaping (Language.Aggregate) -> Bool = { _ in true }, sortedBy: @escaping (Language.Aggregate, Language.Aggregate) -> Bool) -> [Language.Aggregate] {
        Query({ languageAggregate(id: $0) }, filteredBy, sortedBy).execute(on: ids)
    }
    
    func noteAggregates(for ids: [Note.ID], filteredBy: @escaping (Note.Aggregate) -> Bool = { _ in true }, sortedBy: @escaping (Note.Aggregate, Note.Aggregate) -> Bool) -> [Note.Aggregate] {
        Query({ noteAggregate(id: $0) }, filteredBy, sortedBy).execute(on: ids)
    }
    
    func usageAggregates(for ids: [Usage.ID], filteredBy: @escaping (Usage.Aggregate) -> Bool = { _ in true }, sortedBy: @escaping (Usage.Aggregate, Usage.Aggregate) -> Bool) -> [Usage.Aggregate] {
        Query({ usageAggregate(id: $0) }, filteredBy, sortedBy).execute(on: ids)
    }
    
    func userCollectionAggregates(for ids: [UserCollection.ID], filteredBy: @escaping (UserCollection.Aggregate) -> Bool = { _ in true }, sortedBy: @escaping (UserCollection.Aggregate, UserCollection.Aggregate) -> Bool) -> [UserCollection.Aggregate] {
        Query({ userCollectionAggregate(id: $0) }, filteredBy, sortedBy).execute(on: ids)
    }
    
}

extension Array where Element: Identifiable {
    var identified: IdentifiedArrayOf<Element> {
        var result: IdentifiedArrayOf<Element> = []
        for element in self {
            result.append(element)
        }
        return result
    }
}

struct Query<Value: Identifiable> {
    fileprivate init(_ expand: @escaping (Value.ID) -> Value?, _ predicate: @escaping (Value) -> Bool, _ sortComparator: @escaping (Value, Value) -> Bool) {
        self.expand = expand
        self.predicate = predicate
        self.sortComparator = sortComparator
    }
    
    var expand: (Value.ID) -> Value?
    var predicate: (Value) -> Bool
    var sortComparator: (Value, Value) -> Bool
    func execute(on ids: [Value.ID]) -> [Value] {
        var result = [Value]()
        for element in ids.compactMap({ expand($0) }) {
            if predicate(element) {
                result.append(element)
            }
        }
        result.sort(by: sortComparator)
        return result
    }
}
