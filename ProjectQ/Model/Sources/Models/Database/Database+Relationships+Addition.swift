
extension Database.Relationships {
    
    // Languages
    
    mutating func connect(language: Language.ID, toEntry entry: Entry.ID) {
        entries[id: entry].languages.append(language)
        languages[id: language].entries.insert(entry)
    }
    
    mutating func disconnect(language: Language.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].languages.removeAll(where: { $0 == language })
        languages[id: language].entries.remove(entry)
    }

    mutating func connect(language: Language.ID, toUsage usage: Usage.ID) {
        usages[id: usage].languages.append(language)
        languages[id: language].usages.insert(usage)
    }
    
    mutating func disconnect(language: Language.ID, fromUsage usage: Usage.ID) {
        usages[id: usage].languages.removeAll(where: { $0 == language })
        languages[id: language].usages.remove(usage)
    }
    
    // Roots
    
    mutating func connect(root: Entry.ID, toEntry derived: Entry.ID, bidirectional: Bool) {
        entries[id: derived].roots.append(root)
        entries[id: root].backTranslations.insert(derived)
        if bidirectional {
            entries[id: root].roots.append(derived)
            entries[id: derived].backTranslations.insert(root)
        }
    }
    
    mutating func disconnect(root: Entry.ID, fromEntry derived: Entry.ID, bidirectional: Bool) {
        entries[id: derived].roots.removeAll(where: { $0 == root })
        entries[id: root].backTranslations.remove(derived)
        if bidirectional {
            entries[id: root].roots.removeAll(where: { $0 == derived })
            entries[id: derived].backTranslations.remove(root)
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
        notes[id: note].targets.insert(.entry(entry))
    }
    
    mutating func disconnect(note: Note.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].notes.removeAll(where: { $0 == note })
        notes[id: note].targets.remove(.entry(entry))
    }
    
    mutating func connect(note: Note.ID, toUsage usage: Usage.ID) {
        usages[id: usage].notes.append(note)
        notes[id: note].targets.insert(.usage(usage))
    }
    
    mutating func disconnect(note: Note.ID, fromUsage usage: Usage.ID) {
        usages[id: usage].notes.removeAll(where: { $0 == note })
        notes[id: note].targets.remove(.usage(usage))
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
