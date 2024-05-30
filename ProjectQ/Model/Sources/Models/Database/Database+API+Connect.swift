
extension Database {
        
    public mutating func add(translation: Entry.ID, to translated: Entry.ID, bidirectional: Bool = true) {
        precondition(stored.entries[translated] != nil)
        precondition(stored.entries[translation] != nil)
        relationships.add(
            translation: translation,
            toEntry: translated,
            bidirectional: bidirectional
        )
    }
    
    public mutating func add(keyword: Keyword.ID, to entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.keywords[keyword] != nil)
        relationships.add(keyword: keyword, toEntry: entry)
    }
    
    public mutating func add(note: Note.ID, to entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.notes[note] != nil)
        relationships.add(note: note, toEntry: entry)
    }
    
    public mutating func add(usage: Usage.ID, to entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.add(usage: usage, toEntry: entry)
    }
    
    public mutating func add(entry: Entry.ID, to entryCollection: EntryCollection.ID, atOffset: Int? = nil) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.add(entry: entry, toEntryCollection: entryCollection)
    }
    
}

