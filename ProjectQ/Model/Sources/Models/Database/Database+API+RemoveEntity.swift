
extension Database {
    
    public mutating func remove(entry: Entry.ID) {
        precondition(stored.entries[entry] != nil)
        stored.entries[entry] = nil
        relationships.removeAllReferences(toEntry: entry)
    }
    
    public mutating func remove(language: Language.ID) {
        precondition(stored.languages[language] != nil)
        stored.languages[language] = nil
        relationships.removeAllReferences(toLanguage: language)
    }
    
    public mutating func remove(keyword: Keyword.ID) {
        precondition(stored.keywords[keyword] != nil)
        relationships.removeAllReferences(toKeyword: keyword)
    }
    
    public mutating func remove(note: Note.ID) {
        precondition(stored.notes[note] != nil)
        relationships.removeAllReferences(toNote: note)
    }
    
    public mutating func remove(usage: Usage.ID) {
        precondition(stored.usages[usage] != nil)
        relationships.removeAllReferences(toUsage: usage)
    }
    
    public mutating func remove(entryCollection: EntryCollection.ID) {
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.removeAllReferences(toEntryCollection: entryCollection)
    }
    
}

