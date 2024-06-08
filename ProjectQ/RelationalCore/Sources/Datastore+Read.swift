
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
    
    public subscript(entry id: Entry.ID) -> Tracked<Entry>? {
        stored.entries[id]
    }
    
    public subscript(entryCollection id: EntryCollection.ID) -> Tracked<EntryCollection>? {
        stored.entryCollections[id]
    }
    
    public subscript(keyword id: Keyword.ID) -> Tracked<Keyword>? {
        stored.keywords[id]
    }
    
    public subscript(language id: Language.ID) -> Tracked<Language>? {
        stored.languages[id]
    }
    
    public subscript(note id: Note.ID) -> Tracked<Note>? {
        stored.notes[id]
    }

    public subscript(usage id: Usage.ID) -> Tracked<Usage>? {
        stored.usages[id]
    }
        
}

