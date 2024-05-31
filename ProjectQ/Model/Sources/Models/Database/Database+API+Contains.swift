
extension Database {
    
    public subscript(entry id: Entry.ID) -> Entry? {
        stored.entries[id]
    }
    
    public subscript(entryCollection id: EntryCollection.ID) -> EntryCollection? {
        stored.entryCollections[id]
    }
    
    public subscript(keyword id: Keyword.ID) -> Keyword? {
        stored.keywords[id]
    }
    
    public subscript(language id: Language.ID) -> Language? {
        stored.languages[id]
    }
    
    public subscript(note id: Note.ID) -> Note? {
        stored.notes[id]
    }

    public subscript(usage id: Usage.ID) -> Usage? {
        stored.usages[id]
    }
    
    public subscript(user id: User.ID) -> User? {
        stored.users[id]
    }
    
}

