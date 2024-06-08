//
//import ComposableArchitecture
//
//extension Shared<Database> {
//    
//    public subscript(entry id: Entry.ID) -> Entry.Expansion? {
//        guard let entry = projectedValue.stored.entries[id] else { return nil }
//        let relationships = wrappedValue.relationships.entries[id, default: .init()]
//        let languages = relationships.languages.compactMap({ wrappedValue.stored.languages[$0] })
//        let roots = relationships.roots.compactMap({ wrappedValue.stored.entries[$0] })
//        let derived = relationships.derived.compactMap({ wrappedValue.stored.entries[$0] })
//        let translations = relationships.translations.compactMap({ wrappedValue.stored.entries[$0] })
//        let backTranslations = relationships.backTranslations.compactMap({ wrappedValue.stored.entries[$0] })
//        let seeAlso = relationships.seeAlso.compactMap({ wrappedValue.stored.entries[$0] })
//        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[$0] })
//        let keywords = relationships.keywords.compactMap({ wrappedValue.stored.keywords[$0] })
//        let notes = relationships.notes.compactMap({ wrappedValue.stored.notes[$0] })
//        let entryCollections = relationships.entryCollections.compactMap({ wrappedValue.stored.entryCollections[$0] })
//        return .init(
//            shared: entry,
//            languages: languages,
//            roots: roots,
//            derived: derived,
//            translations: translations,
//            backTranslations: backTranslations,
//            seeAlso: seeAlso,
//            usages: usages,
//            keywords: keywords,
//            notes: notes,
//            entryCollections: entryCollections
//        )
//    }
//    
//    public subscript(entryCollection id: EntryCollection.ID) -> EntryCollection.Expansion? {
//        guard let entryCollection = projectedValue.stored.entryCollections[id] else { return nil }
//        let relationships = wrappedValue.relationships.entryCollections[id, default: .init()]
//        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[$0] })
//        return .init(
//            shared: entryCollection,
//            entries: entries
//        )
//    }
//
//    public subscript(keyword id: Keyword.ID) -> Keyword.Expansion? {
//        guard let keyword = projectedValue.stored.keywords[id] else { return nil }
//        let relationships = wrappedValue.relationships.keywords[id, default: .init()]
//        let matches = relationships.matches.compactMap({ wrappedValue.stored.entries[$0] })
//        return .init(
//            shared: keyword,
//            matches: matches
//        )
//    }
//    
//    public subscript(language id: Language.ID) -> Language.Expansion? {
//        guard let language = projectedValue.stored.languages[id] else { return nil }
//        let relationships = wrappedValue.relationships.languages[id, default: .init()]
//        let entries = relationships.entries.compactMap({ wrappedValue.stored.entries[$0] })
//        let usages = relationships.usages.compactMap({ wrappedValue.stored.usages[$0] })
//        return .init(
//            shared: language,
//            entries: entries,
//            usages: usages
//        )
//    }
//    
//    public subscript(note id: Note.ID) -> Note.Expansion? {
//        guard let note = projectedValue.stored.notes[id] else { return nil }
//        let relationships = wrappedValue.relationships.notes[id, default: .init()]
//        return .init(
//            shared: note,
//            targets: relationships.targets
//        )
//    }
//
//    public subscript(usage id: Usage.ID) -> Usage.Expansion? {
//        guard let usage = projectedValue.stored.usages[id] else { return nil }
//        let relationships = wrappedValue.relationships.usages[id, default: .init()]
//        let languages = relationships.languages.compactMap({ wrappedValue.stored.languages[$0] })
//        let notes = relationships.notes.compactMap({ wrappedValue.stored.notes[$0] })
//        let uses = relationships.uses.compactMap({ wrappedValue.stored.entries[$0] })
//        return .init(
//            shared: usage,
//            languages: languages,
//            notes: notes,
//            uses: uses
//        )
//    }
//    
//    public subscript(user id: User.ID) -> User.Expansion? {
//        guard let user = projectedValue.stored.users[id] else { return nil }
//        let relationships = wrappedValue.relationships.users[id, default: .init()]
//        let languages = relationships.languages.compactMap({ wrappedValue.stored.languages[$0] })
//        return .init(
//            shared: user,
//            languages: languages
//        )
//    }
//    
//}
//
//extension Database {
//    
//    public func snapshotOf(entity: Entity.ID) -> Entity? {
//        switch entity {
//        case .entry(let id): stored.entries[id].map({ .entry($0) })
//        case .entryCollection(let id): stored.entryCollections[id].map({ .entryCollection($0) })
//        case .keyword(let id): stored.keywords[id].map({ .keyword($0) })
//        case .language(let id): stored.languages[id].map({ .language($0) })
//        case .note(let id): stored.notes[id].map({ .note($0) })
//        case .usage(let id): stored.usages[id].map({ .usage($0) })
//        case .user(let id): stored.users[id].map({ .user($0) })
//        }
//    }
//    
//}
//
