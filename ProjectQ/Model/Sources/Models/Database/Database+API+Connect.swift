
extension Database {
        
    public mutating func connect(translation: Entry.ID, to translated: Entry.ID, bidirectional: Bool = true) {
        precondition(stored.entries[translated] != nil)
        precondition(stored.entries[translation] != nil)
        relationships.connect(
            translation: translation,
            toEntry: translated,
            bidirectional: bidirectional
        )
    }
    
    public mutating func connect(keyword: Keyword.ID, to entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.keywords[keyword] != nil)
        relationships.connect(keyword: keyword, toEntry: entry)
    }
    
    public mutating func connect(note: Note.ID, to entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.notes[note] != nil)
        relationships.connect(note: note, toEntry: entry)
    }
    
    public mutating func connect(usage: Usage.ID, to entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.connect(usage: usage, toEntry: entry)
    }
    
    public mutating func connect(entry: Entry.ID, to entryCollection: EntryCollection.ID, atOffset: Int? = nil) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.connect(entry: entry, toEntryCollection: entryCollection)
    }
    
}

