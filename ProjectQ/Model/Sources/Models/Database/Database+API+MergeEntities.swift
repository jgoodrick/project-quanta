
extension Database {
    
    public mutating func merge(entry incomingID: Entry.ID, into existing: Entry.ID) {
        precondition(stored.entries[incomingID] != nil)
        precondition(stored.entries[existing] != nil)
        guard var primary = stored.entries[existing], let incoming = stored.entries[incomingID] else { return }
        primary.merge(with: incoming)
        stored.entries[existing] = primary
        relationships.entries[id: existing].merge(with: relationships.entries[id: incomingID])
        remove(entry: incomingID)
    }
    
    public mutating func merge(language incomingID: Language.ID, into existing: Language.ID) {
        precondition(stored.languages[incomingID] != nil)
        precondition(stored.languages[existing] != nil)
        guard var primary = stored.languages[existing], let incoming = stored.languages[incomingID] else { return }
        primary.merge(with: incoming)
        stored.languages[existing] = primary
        relationships.languages[id: existing].merge(with: relationships.languages[id: incomingID])
        remove(language: incomingID)
    }

    public mutating func merge(keyword incomingID: Keyword.ID, into existing: Keyword.ID) {
        precondition(stored.keywords[incomingID] != nil)
        precondition(stored.keywords[existing] != nil)
        guard var primary = stored.keywords[existing], let incoming = stored.keywords[incomingID] else { return }
        primary.merge(with: incoming)
        stored.keywords[existing] = primary
        relationships.keywords[id: existing].merge(with: relationships.keywords[id: incomingID])
        remove(keyword: incomingID)
    }

}

