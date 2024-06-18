
import StructuralModel

extension Database {
    
    public mutating func merge(entry incomingID: Entry.ID, into existing: Entry.ID) {
        precondition(stored.entries[incomingID] != nil)
        precondition(stored.entries[existing] != nil)
        stored.entries[existing]!.merge(with: stored.entries[incomingID]!)
        relationships.entries[id: existing].merge(with: relationships.entries[id: incomingID])
        delete(.entry(incomingID))
    }
    
    public mutating func merge(language incomingID: Language.ID, into existing: Language.ID) {
        precondition(stored.languages[incomingID] != nil)
        precondition(stored.languages[existing] != nil)
        stored.languages[existing]!.merge(with: stored.languages[incomingID]!)
        relationships.languages[id: existing].merge(with: relationships.languages[id: incomingID])
        delete(.language(incomingID))
    }

    public mutating func merge(keyword incomingID: Keyword.ID, into existing: Keyword.ID) {
        precondition(stored.keywords[incomingID] != nil)
        precondition(stored.keywords[existing] != nil)
        stored.keywords[existing]!.merge(with: stored.keywords[incomingID]!)
        relationships.keywords[id: existing].merge(with: relationships.keywords[id: incomingID])
        delete(.keyword(incomingID))
    }

}

