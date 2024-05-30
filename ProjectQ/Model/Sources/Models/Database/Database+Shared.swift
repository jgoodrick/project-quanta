
import ComposableArchitecture

extension Shared<Database> {
    
    public subscript(entry id: Entry.ID) -> Entry.Expansion? {
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
        let entryCollections = relationships.entryCollections.compactMap({ wrappedValue.stored.entryCollections[$0] })
        return .init(
            shared: entry,
            language: language,
            root: root,
            derived: derived,
            translations: translations,
            backTranslations: backTranslations,
            seeAlso: seeAlso,
            usages: usages,
            keywords: keywords,
            notes: notes,
            entryCollections: entryCollections
        )
    }
    
    public subscript(keyword id: Keyword.ID) -> Keyword.Expansion? {
        guard let keyword = projectedValue.stored.keywords[id] else { return nil }
        let relationships = wrappedValue.relationships.keywords[id, default: .init()]
        let matches = relationships.matches.compactMap({ wrappedValue.stored.entries[$0] })
        return .init(
            shared: keyword,
            matches: matches
        )
    }
    
    public subscript(language id: Language.ID) -> Language.Expansion? {
        guard let language = projectedValue.stored.languages[id] else { return nil }
        let relationships = wrappedValue.relationships.languages[id, default: .init()]
        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[$0] })
        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[$0] })
        return .init(
            shared: language,
            entries: entries,
            usages: usages
        )
    }
    
    public subscript(note id: Note.ID) -> Note.Expansion? {
        guard let note = projectedValue.stored.notes[id] else { return nil }
        let relationships = wrappedValue.relationships.notes[id, default: .init()]
        var target: Note.Expansion.Target?
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
            shared: note,
            target: target
        )
    }

    public subscript(usage id: Usage.ID) -> Usage.Expansion? {
        guard let usage = projectedValue.stored.usages[id] else { return nil }
        let relationships = wrappedValue.relationships.usages[id, default: .init()]
        let note = relationships.note.flatMap({ wrappedValue.stored.notes[$0] })
        let uses = relationships.uses.compactMap({ wrappedValue.stored.entries[$0] })
        return .init(
            shared: usage,
            note: note,
            uses: uses
        )
    }
    
    public subscript(entryCollection id: EntryCollection.ID) -> EntryCollection.Expansion? {
        guard let entryCollection = projectedValue.stored.entryCollections[id] else { return nil }
        let relationships = wrappedValue.relationships.entryCollections[id, default: .init()]
        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[$0] })
        return .init(
            shared: entryCollection,
            entries: entries
        )
    }
    
}

