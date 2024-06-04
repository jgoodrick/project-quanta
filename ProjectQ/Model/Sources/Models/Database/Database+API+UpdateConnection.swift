
extension Database {
    
    public mutating func add(language: Language.ID, toEntry entry: Entry.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.connect(language: language, toEntry: entry)
    }
    
    public mutating func remove(language: Language.ID, fromEntry entry: Entry.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.disconnect(language: language, fromEntry: entry)
    }
    
    public mutating func add(language: Language.ID, toUsage usage: Usage.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.connect(language: language, toUsage: usage)
    }
    
    public mutating func remove(language: Language.ID, fromUsage usage: Usage.ID) {
        precondition(stored.languages[language] != nil)
        precondition(stored.usages[usage] != nil)
        relationships.disconnect(language: language, fromUsage: usage)
    }
    
    public mutating func add(root: Entry.ID, toEntry entry: Entry.ID) {
        precondition(stored.entries[root] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.connect(root: root, toEntry: entry, bidirectional: true)
    }
    
    public mutating func remove(root: Entry.ID, fromEntry entry: Entry.ID) {
        precondition(stored.entries[root] != nil)
        precondition(stored.entries[entry] != nil)
        relationships.disconnect(root: root, fromEntry: entry, bidirectional: true)
    }
    
}
