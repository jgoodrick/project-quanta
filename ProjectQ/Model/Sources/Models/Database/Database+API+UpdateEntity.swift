
extension Database {
    
    public mutating func updateEntry<T>(_ keyPath: WritableKeyPath<Entry, T>, on id: Entry.ID, to value: T) {
        precondition(stored.entries[id] != nil)
        stored.entries[id]?[keyPath: keyPath] = value
    }
    
    public mutating func updateKeyword<T>(_ keyPath: WritableKeyPath<Keyword, T>, on id: Keyword.ID, to value: T) {
        precondition(stored.keywords[id] != nil)
        stored.keywords[id]?[keyPath: keyPath] = value
    }
    
    public mutating func updateLanguage<T>(_ keyPath: WritableKeyPath<Language, T>, on id: Language.ID, to value: T) {
        precondition(stored.languages[id] != nil)
        stored.languages[id]?[keyPath: keyPath] = value
    }
    
    public mutating func updateNote<T>(_ keyPath: WritableKeyPath<Note, T>, on id: Note.ID, to value: T) {
        precondition(stored.notes[id] != nil)
        stored.notes[id]?[keyPath: keyPath] = value
    }
    
    public mutating func updateUsage<T>(_ keyPath: WritableKeyPath<Usage, T>, on id: Usage.ID, to value: T) {
        precondition(stored.usages[id] != nil)
        stored.usages[id]?[keyPath: keyPath] = value
    }
    
    public mutating func updateUser<T>(_ keyPath: WritableKeyPath<User, T>, on id: User.ID, to value: T) {
        precondition(stored.users[id] != nil)
        stored.users[id]?[keyPath: keyPath] = value
    }
    
}

