
extension Repository.Relationships {
    
    mutating func setLanguage(of entry: Entry.ID, toLanguage language: Language.ID) {
        let previous = entries[entry]
        entries[entry, default: .init()].language = language
        languages[language, default: .init()].entries.insert(entry)
        if let previousLanguage = previous?.language {
            languages[previousLanguage, default: .init()].entries.remove(entry)
        }
    }
    
    mutating func setRoot(of derived: Entry.ID, to root: Entry.ID) {
        let previous = entries[derived]
        entries[derived, default: .init()].root = root
        entries[root, default: .init()].derived.insert(derived)
        if let previousRoot = previous?.root {
            entries[previousRoot]?.derived.remove(derived)
        }
    }
    
    // Translations
    
    mutating func add(translation: Entry.ID, toEntry translated: Entry.ID, bidirectional: Bool) {
        entries[translated, default: .init()].translations.append(translation)
        entries[translation, default: .init()].backTranslations.insert(translated)
        if bidirectional {
            entries[translation, default: .init()].translations.append(translated)
            entries[translated, default: .init()].backTranslations.insert(translation)
        }
    }
    
    mutating func disconnect(translation: Entry.ID, fromEntry translated: Entry.ID, bidirectional: Bool) {
        entries[translated, default: .init()].translations.removeAll(where: { $0 == translation })
        entries[translation, default: .init()].backTranslations.remove(translated)
        if bidirectional {
            entries[translation, default: .init()].translations.removeAll(where: { $0 == translated })
            entries[translated, default: .init()].backTranslations.remove(translation)
        }
    }
    
    // See Also
    
    mutating func add(seeAlso: Entry.ID, toEntry entry: Entry.ID) {
        entries[entry, default: .init()].seeAlso.append(seeAlso)
        entries[seeAlso, default: .init()].seeAlso.append(entry)
    }
    
    mutating func disconnect(seeAlso: Entry.ID, fromEntry entry: Entry.ID) {
        entries[entry, default: .init()].seeAlso.removeAll(where: { $0 == seeAlso })
        entries[seeAlso, default: .init()].seeAlso.removeAll(where: { $0 == seeAlso })
    }
    
    // Usages
    
    mutating func add(usage: Usage.ID, toEntry entry: Entry.ID) {
        entries[entry, default: .init()].usages.append(usage)
        usages[usage, default: .init()].uses.insert(entry)
    }
    
    mutating func disconnect(usage: Usage.ID, fromEntry entry: Entry.ID) {
        entries[entry, default: .init()].usages.removeAll(where: { $0 == usage })
        usages[usage, default: .init()].uses.remove(entry)
    }
    
    // Keywords
    
    mutating func add(keyword: Keyword.ID, toEntry entry: Entry.ID) {
        entries[entry, default: .init()].keywords.insert(keyword)
        keywords[keyword, default: .init()].matches.append(entry)
    }
    
    mutating func disconnect(keyword: Keyword.ID, fromEntry entry: Entry.ID) {
        entries[entry, default: .init()].keywords.remove(keyword)
        keywords[keyword, default: .init()].matches.removeAll(where: { $0 == entry })
    }
    
    // Notes
    
    mutating func add(note: Note.ID, toEntry entry: Entry.ID) {
        entries[entry, default: .init()].notes.append(note)
        notes[note, default: .init()].target = .entry(entry)
    }
    
    mutating func disconnect(note: Note.ID, fromEntry entry: Entry.ID) {
        entries[entry, default: .init()].notes.removeAll(where: { $0 == note })
        if case .entry(let target) = notes[note]?.target, target == entry {
            notes[note, default: .init()].target = nil
        }
    }
    
    // UserCollections
    
    mutating func add(entry: Entry.ID, toUserCollection userCollection: UserCollection.ID) {
        userCollections[userCollection, default: .init()].entries.append(entry)
        entries[entry, default: .init()].userCollections.insert(userCollection)
    }
    
    mutating func remove(entry: Entry.ID, fromUserCollection userCollection: UserCollection.ID) {
        userCollections[userCollection, default: .init()].entries.removeAll(where: { $0 == entry })
        entries[entry, default: .init()].userCollections.remove(userCollection)
    }
    
    
//        entries.mutateAll {
//            if $0.root == entryID { $0.root = nil }
//            $0.translations.removeAll(where: { $0 == entryID })
//            $0.backTranslations.remove(entryID)
//            $0.seeAlso.removeAll(where: { $0 == entryID })
//        }
//        keywords.mutateAll {
//            $0.matches.removeAll(where: { $0 == entryID })
//        }
//        languages.mutateAll {
//            $0.entries.remove(entryID)
//        }
//        notes.mutateAll {
//            if $0.entry == entryID { $0.entry = nil }
//        }
//        usages.mutateAll {
//            $0.uses.remove(entryID)
//        }
//        userCollections.mutateAll {
//            $0.entries.removeAll(where: { $0 == entryID })
//        }
//    }
//    mutating func removeAllReferences(toKeyword keywordID: Keyword.ID) {
//        keywords[keywordID] = nil
//        entries.mutateAll {
//            $0.keywords.remove(keywordID)
//        }
//    }
//    mutating func removeAllReferences(toLanguage languageID: Language.ID) {
//        languages[languageID] = nil
//        entries.mutateAll {
//            if $0.language == languageID { $0.language = nil }
//        }
//    }
//    mutating func removeAllReferences(toNote noteID: Note.ID) {
//        notes[noteID] = nil
//        entries.mutateAll {
//            $0.notes.removeAll(where: { $0 == noteID })
//        }
//        usages.mutateAll {
//            if $0.note == noteID { $0.note = nil }
//        }
//    }
//    mutating func removeAllReferences(toUsage usageID: Usage.ID) {
//        usages[usageID] = nil
//        entries.mutateAll {
//            $0.usages.removeAll(where: { $0 == usageID })
//        }
//    }
//    mutating func removeAllReferences(toUserCollection userCollectionID: UserCollection.ID) {
//        userCollections[userCollectionID] = nil
//        entries.mutateAll {
//            $0.userCollections.remove(userCollectionID)
//        }
//    }
}
