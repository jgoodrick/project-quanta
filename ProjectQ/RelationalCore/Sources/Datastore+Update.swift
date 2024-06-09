
import ModelCore

extension Database {
    
    public mutating func update(_ entity: Entity) {
        precondition(contains(entity.id))
        switch entity {
        case .entry(let entry):
            stored.entries[entry.id]!.value = entry
        case .language(let language):
            stored.languages[language.id]!.value = language
        case .keyword(let keyword):
            stored.keywords[keyword.id]!.value = keyword
        case .note(let note):
            stored.notes[note.id]!.value = note
        case .usage(let usage):
            stored.usages[usage.id]!.value = usage
        case .entryCollection(let entryCollection):
            stored.entryCollections[entryCollection.id]!.value = entryCollection
        }
    }
    
}

extension Database {
    
    public mutating func connect(translation: Entry.ID, toEntry translated: Entry.ID, bidirectional: Bool = true) {
        precondition(stored.entries[translated] != nil)
        precondition(stored.entries[translation] != nil)
        relationships.connect(
            translation: translation,
            toEntry: translated,
            bidirectional: bidirectional
        )
    }
    
    public mutating func connect(keyword: Keyword.ID, toEntry entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.keywords[keyword] != nil)
        relationships.connect(keyword: keyword, toEntry: entry)
    }
    
    public mutating func connect(note: Note.ID, toEntry entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.notes[note] != nil)
        relationships.connect(note: note, toEntry: entry)
    }
    
    public mutating func connect(note: Note.ID, toUsage usage: Usage.ID) {
        precondition(stored.usages[usage] != nil)
        precondition(stored.notes[note] != nil)
        relationships.connect(note: note, toUsage: usage)
    }
    
    public mutating func connect(usage: Usage.ID, toEntry entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.connect(usage: usage, toEntry: entry)
    }
    
    public mutating func connect(entry: Entry.ID, toCollection entryCollection: EntryCollection.ID, atOffset: Int? = nil) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.connect(entry: entry, toEntryCollection: entryCollection)
    }
    
    public mutating func connect(language: Language.ID, toEntry entry: Entry.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.connect(language: language, toEntry: entry)
    }
    
    public mutating func connect(language: Language.ID, toUsage usage: Usage.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.connect(language: language, toUsage: usage)
    }
    
    public mutating func connect(root: Entry.ID, toEntry entry: Entry.ID) {
        precondition(stored.entries[root] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.connect(root: root, toEntry: entry, bidirectional: true)
    }
    
    public mutating func connect(seeAlso: Entry.ID, toEntry entry: Entry.ID) {
        precondition(stored.entries[seeAlso] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.connect(seeAlso: seeAlso, toEntry: entry, bidirectional: true)
    }

}

extension Database.Relationships {
    
    mutating func connect(language: Language.ID, toEntry entry: Entry.ID) {
        entries[id: entry].languages.append(language)
        languages[id: language].entries.insert(entry)
    }
    
    mutating func connect(language: Language.ID, toUsage usage: Usage.ID) {
        usages[id: usage].languages.append(language)
        languages[id: language].usages.insert(usage)
    }
    
    mutating func connect(root: Entry.ID, toEntry derived: Entry.ID, bidirectional: Bool) {
        entries[id: derived].roots.append(root)
        if bidirectional {
            entries[id: root].derived.insert(derived)
        }
    }
    
    mutating func connect(translation: Entry.ID, toEntry translated: Entry.ID, bidirectional: Bool) {
        entries[id: translated].translations.append(translation)
        entries[id: translation].backTranslations.insert(translated)
        if bidirectional {
            entries[id: translation].translations.append(translated)
            entries[id: translated].backTranslations.insert(translation)
        }
    }
    
    mutating func connect(seeAlso: Entry.ID, toEntry entry: Entry.ID, bidirectional: Bool) {
        entries[id: entry].seeAlso.append(seeAlso)
        if bidirectional {
            entries[id: seeAlso].seeAlso.append(entry)
        }
    }
    
    mutating func connect(usage: Usage.ID, toEntry entry: Entry.ID) {
        entries[id: entry].usages.append(usage)
        usages[id: usage].uses.insert(entry)
    }
    
    mutating func connect(keyword: Keyword.ID, toEntry entry: Entry.ID) {
        entries[id: entry].keywords.insert(keyword)
        keywords[id: keyword].matches.append(entry)
    }
    
    mutating func connect(note: Note.ID, toEntry entry: Entry.ID) {
        entries[id: entry].notes.append(note)
        notes[id: note].entryTargets.insert(entry)
    }
    
    mutating func connect(note: Note.ID, toUsage usage: Usage.ID) {
        usages[id: usage].notes.append(note)
        notes[id: note].usageTargets.insert(usage)
    }
    
    mutating func connect(entry: Entry.ID, toEntryCollection entryCollection: EntryCollection.ID) {
        entryCollections[id: entryCollection].entries.append(entry)
        entries[id: entry].entryCollections.insert(entryCollection)
    }
    

}

extension Database {
    
    public mutating func disconnect(translation: Entry.ID, fromEntry translated: Entry.ID, bidirectional: Bool = true, deleteIfOrphaned: Bool = false) {
        precondition(stored.entries[translated] != nil)
        precondition(stored.entries[translation] != nil)
        relationships.disconnect(
            translation: translation,
            fromEntry: translated,
            bidirectional: bidirectional
        )
        if relationships.entries[id: translation].isOrphan {
            stored.entries[translation] = nil
        }
    }
    
    public mutating func disconnect(keyword: Keyword.ID, fromEntry entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.keywords[keyword] != nil)
        relationships.disconnect(keyword: keyword, fromEntry: entry)
    }
    
    public mutating func disconnect(note: Note.ID, fromEntry entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.notes[note] != nil)
        relationships.disconnect(note: note, fromEntry: entry)
    }
    
    public mutating func disconnect(note: Note.ID, fromUsage usage: Usage.ID) {
        precondition(stored.usages[usage] != nil)
        precondition(stored.notes[note] != nil)
        relationships.disconnect(note: note, fromUsage: usage)
    }
    
    public mutating func disconnect(usage: Usage.ID, fromEntry entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.disconnect(usage: usage, fromEntry: entry)
    }
    
    public mutating func disconnect(entry: Entry.ID, fromEntryCollection entryCollection: EntryCollection.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.disconnect(entry: entry, fromEntryCollection: entryCollection)
    }
    
    public mutating func disconnect(language: Language.ID, fromEntry entry: Entry.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.disconnect(language: language, fromEntry: entry)
    }
    

    public mutating func disconnect(language: Language.ID, fromUsage usage: Usage.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.disconnect(language: language, fromUsage: usage)
    }
    

    public mutating func disconnect(root: Entry.ID, fromEntry entry: Entry.ID) {
        precondition(stored.entries[root] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.disconnect(root: root, fromEntry: entry, bidirectional: true)
    }

    public mutating func disconnect(seeAlso: Entry.ID, fromEntry entry: Entry.ID) {
        precondition(stored.entries[seeAlso] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.disconnect(seeAlso: seeAlso, fromEntry: entry, bidirectional: true)
    }

}

extension Database.Relationships {
    
    mutating func disconnect(language: Language.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].languages.removeAll(where: { $0 == language })
        languages[id: language].entries.remove(entry)
    }

    mutating func disconnect(language: Language.ID, fromUsage usage: Usage.ID) {
        usages[id: usage].languages.removeAll(where: { $0 == language })
        languages[id: language].usages.remove(usage)
    }
    
    mutating func disconnect(root: Entry.ID, fromEntry derived: Entry.ID, bidirectional: Bool) {
        entries[id: derived].roots.removeAll(where: { $0 == root })
        entries[id: root].derived.remove(derived)
        if bidirectional {
            entries[id: root].roots.removeAll(where: { $0 == derived })
            entries[id: derived].derived.remove(root)
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
    
    mutating func disconnect(seeAlso: Entry.ID, fromEntry entry: Entry.ID, bidirectional: Bool) {
        entries[id: entry].seeAlso.removeAll(where: { $0 == seeAlso })
        if bidirectional {
            entries[id: seeAlso].seeAlso.removeAll(where: { $0 == entry })
        }
    }
    
    mutating func disconnect(usage: Usage.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].usages.removeAll(where: { $0 == usage })
        usages[id: usage].uses.remove(entry)
    }
    
    mutating func disconnect(keyword: Keyword.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].keywords.remove(keyword)
        keywords[id: keyword].matches.removeAll(where: { $0 == entry })
    }
    
    mutating func disconnect(note: Note.ID, fromEntry entry: Entry.ID) {
        entries[id: entry].notes.removeAll(where: { $0 == note })
        notes[id: note].entryTargets.remove(entry)
    }
    
    mutating func disconnect(note: Note.ID, fromUsage usage: Usage.ID) {
        usages[id: usage].notes.removeAll(where: { $0 == note })
        notes[id: note].usageTargets.remove(usage)
    }
        
    mutating func disconnect(entry: Entry.ID, fromEntryCollection entryCollection: EntryCollection.ID) {
        entryCollections[id: entryCollection].entries.removeAll(where: { $0 == entry })
        entries[id: entry].entryCollections.remove(entryCollection)
    }

}
