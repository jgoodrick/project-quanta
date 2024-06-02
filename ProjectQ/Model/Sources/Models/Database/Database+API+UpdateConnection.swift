
extension Database {
    
    public mutating func updateEntryLanguage(to language: Language.ID, for entry: Entry.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.setEntryLanguage(of: entry, toLanguage: language)
    }
    
    public mutating func updateUsageLanguage(to language: Language.ID, for usage: Usage.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.setUsageLanguage(of: usage, toLanguage: language)
    }
    
    public mutating func updateRoot(to root: Entry.ID, for entry: Entry.ID) {
        precondition(stored.entries[root] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.setRoot(of: entry, to: root)
    }
    
}
