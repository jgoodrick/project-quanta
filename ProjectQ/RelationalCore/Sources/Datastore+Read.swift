
import ModelCore

extension Database {
    
    public func contains(_ entity: Entity.ID) -> Bool {
        switch entity {
        case .entry(let entry):
            stored.entries[entry] != nil
        case .language(let language):
            stored.languages[language] != nil
        case .keyword(let keyword):
            stored.keywords[keyword] != nil
        case .note(let note):
            stored.notes[note] != nil
        case .usage(let usage):
            stored.usages[usage] != nil
        case .entryCollection(let entryCollection):
            stored.entryCollections[entryCollection] != nil
        }
    }
        
}

extension Database {
    
    public subscript(entry id: Entry.ID) -> Entry? {
        stored.entries[id]?.value
    }
    
    public subscript(entryCollection id: EntryCollection.ID) -> EntryCollection? {
        stored.entryCollections[id]?.value
    }
    
    public subscript(keyword id: Keyword.ID) -> Keyword? {
        stored.keywords[id]?.value
    }
    
    public subscript(language id: Language.ID) -> Language? {
        stored.languages[id]?.value
    }
    
    public subscript(note id: Note.ID) -> Note? {
        stored.notes[id]?.value
    }

    public subscript(usage id: Usage.ID) -> Usage? {
        stored.usages[id]?.value
    }
        
}

