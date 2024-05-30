
extension Database {
    
    public mutating func remove(translation: Entry.ID, from translated: Entry.ID, bidirectional: Bool = true, deleteIfOrphaned: Bool = false) {
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
    
    public mutating func remove(keyword: Keyword.ID, from entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.keywords[keyword] != nil)
        relationships.disconnect(keyword: keyword, fromEntry: entry)
    }
    
    public mutating func remove(note: Note.ID, from entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.notes[note] != nil)
        relationships.disconnect(note: note, fromEntry: entry)
    }
    
    public mutating func remove(usage: Usage.ID, from entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.disconnect(usage: usage, fromEntry: entry)
    }
    
    public mutating func remove(entry: Entry.ID, from entryCollection: EntryCollection.ID) {
        precondition(stored.entries[entry] != nil)
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.remove(entry: entry, fromEntryCollection: entryCollection)
    }
    

}
