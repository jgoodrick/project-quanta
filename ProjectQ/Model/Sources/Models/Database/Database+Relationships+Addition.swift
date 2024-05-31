
extension Database.Relationships {
    
    mutating func setLanguage(of entry: Entry.ID, toLanguage language: Language.ID) {
        let previous = entries[entry]
        entries[id: entry].language = language
        languages[id: language].entries.insert(entry)
        if let previousLanguage = previous?.language {
            languages[id: previousLanguage].entries.remove(entry)
        }
    }
    
    mutating func setRoot(of derived: Entry.ID, to root: Entry.ID) {
        let previous = entries[derived]
        entries[id: derived].root = root
        entries[id: root].derived.insert(derived)
        if let previousRoot = previous?.root {
            entries[previousRoot]?.derived.remove(derived)
        }
    }
    
    // Translations
    
    mutating func connect(translation: Entry.ID, toEntry translated: Entry.ID, bidirectional: Bool) {
        entries[id: translated].translations.append(translation)
        entries[id: translation].backTranslations.insert(translated)
        if bidirectional {
            entries[id: translation].translations.append(translated)
            entries[id: translated].backTranslations.insert(translation)
        }
    }
    
    mutating func disconnect(translation: Entry.ID, fromEntry translated: Entry.ID, bidirectional: Bool) {
        entries[id: translated].translations.removeAll(where: { $0 == translation })
        entries[id: translation].backTranslations.remove(translated)
        if bidirectional {
            entries[id: translation].translations.removeAll(where: { $0 == translated })
            entries[id: translated].backTranslations.remove(translation)
        }
    }
    
    // See Also
    
    mutating func connect(seeAlso: Entry.ID, toEntry entry: Entry.ID) {
        entries[id: entry].seeAlso.append(seeAlso)
        entries[id: seeAlso].seeAlso.append(entry)
    }
    
    mutating func disconnect(seeAlso: Entry.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].seeAlso.removeAll(where: { $0 == seeAlso })
        entries[id: seeAlso].seeAlso.removeAll(where: { $0 == seeAlso })
    }
    
    // Usages
    
    mutating func connect(usage: Usage.ID, toEntry entry: Entry.ID) {
        entries[id: entry].usages.append(usage)
        usages[id: usage].uses.insert(entry)
    }
    
    mutating func disconnect(usage: Usage.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].usages.removeAll(where: { $0 == usage })
        usages[id: usage].uses.remove(entry)
    }
    
    // Keywords
    
    mutating func connect(keyword: Keyword.ID, toEntry entry: Entry.ID) {
        entries[id: entry].keywords.insert(keyword)
        keywords[id: keyword].matches.append(entry)
    }
    
    mutating func disconnect(keyword: Keyword.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].keywords.remove(keyword)
        keywords[id: keyword].matches.removeAll(where: { $0 == entry })
    }
    
    // Notes
    
    mutating func connect(note: Note.ID, toEntry entry: Entry.ID) {
        entries[id: entry].notes.append(note)
        notes[id: note].target = .entry(entry)
    }
    
    mutating func disconnect(note: Note.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].notes.removeAll(where: { $0 == note })
        if case .entry(let target) = notes[note]?.target, target == entry {
            notes[id: note].target = nil
        }
    }
    
    // EntryCollections
    
    mutating func connect(entry: Entry.ID, toEntryCollection entryCollection: EntryCollection.ID) {
        entryCollections[id: entryCollection].entries.append(entry)
        entries[id: entry].entryCollections.insert(entryCollection)
    }
    
    mutating func remove(entry: Entry.ID, fromEntryCollection entryCollection: EntryCollection.ID) {
        entryCollections[id: entryCollection].entries.removeAll(where: { $0 == entry })
        entries[id: entry].entryCollections.remove(entryCollection)
    }
    
}
