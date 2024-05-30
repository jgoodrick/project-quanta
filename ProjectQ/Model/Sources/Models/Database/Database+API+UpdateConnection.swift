
extension Database {
    
    public mutating func updateLanguage(to language: Language.ID, for entry: Entry.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.setLanguage(of: entry, toLanguage: language)
    }
    
    public mutating func updateRoot(to root: Entry.ID, for entry: Entry.ID) {
        precondition(stored.entries[root] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.setRoot(of: entry, to: root)
    }
    
}
