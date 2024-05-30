
extension Database {
    
    mutating func add(entry: Entry) {
        precondition(stored.entries[entry.id] == nil)
        stored.entries[entry.id] = entry
    }
    
    mutating func add(language: Language) {
        precondition(stored.languages[language.id] == nil)
        stored.languages[language.id] = language
    }
    
    mutating func add(keyword: Keyword) {
        precondition(stored.keywords[keyword.id] == nil)
        stored.keywords[keyword.id] = keyword
    }
    
    mutating func add(note: Note) {
        precondition(stored.notes[note.id] == nil)
        stored.notes[note.id] = note
    }
    
    mutating func add(usage: Usage) {
        precondition(stored.usages[usage.id] == nil)
        stored.usages[usage.id] = usage
    }
    
    mutating func add(entryCollection: EntryCollection) {
        precondition(stored.entryCollections[entryCollection.id] == nil)
        stored.entryCollections[entryCollection.id] = entryCollection
    }
    
}

