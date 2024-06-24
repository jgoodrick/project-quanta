
import StructuralModel

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
    
    public func connectedEntities(for entity: Entity.ID) -> Set<Entity.ID> {
        switch entity {
        case .entry(let entry):
            relationships.entries[entry]?.connectedEntities ?? []
        case .entryCollection(let entryCollection):
            relationships.entryCollections[entryCollection]?.connectedEntities ?? []
        case .keyword(let keyword):
            relationships.keywords[keyword]?.connectedEntities ?? []
        case .language(let language):
            relationships.languages[language]?.connectedEntities ?? []
        case .note(let note):
            relationships.notes[note]?.connectedEntities ?? []
        case .usage(let usage):
            relationships.usages[usage]?.connectedEntities ?? []
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

extension Database {
    
    public func tracked(entry id: Entry.ID) -> Tracked<Entry>? {
        stored.entries[id]
    }
    
    public func tracked(entryCollection id: EntryCollection.ID) -> Tracked<EntryCollection>? {
        stored.entryCollections[id]
    }
    
    public func tracked(keyword id: Keyword.ID) -> Tracked<Keyword>? {
        stored.keywords[id]
    }
    
    public func tracked(language id: Language.ID) -> Tracked<Language>? {
        stored.languages[id]
    }
    
    public func tracked(note id: Note.ID) -> Tracked<Note>? {
        stored.notes[id]
    }

    public func tracked(usage id: Usage.ID) -> Tracked<Usage>? {
        stored.usages[id]
    }
        
}

