
import RelationalModel
import StructuralModel

/**
 AppModel.Entities
 */
extension AppModel {
    
    public subscript(entry id: Entry.ID) -> Entry? {
        db[entry: id]
    }
    
    public subscript(entryCollection id: EntryCollection.ID) -> EntryCollection? {
        db[entryCollection: id]
    }
    
    public subscript(keyword id: Keyword.ID) -> Keyword? {
        db[keyword: id]
    }
    
    public subscript(language id: Language.ID) -> Language? {
        db[language: id]
    }
    
    public subscript(note id: Note.ID) -> Note? {
        db[note: id]
    }

    public subscript(usage id: Usage.ID) -> Usage? {
        db[usage: id]
    }
    
    
    
    public func tracked(entry id: Entry.ID) -> Tracked<Entry>? {
        db.tracked(entry: id)
    }
    
    public func tracked(entryCollection id: EntryCollection.ID) -> Tracked<EntryCollection>? {
        db.tracked(entryCollection: id)
    }
    
    public func tracked(keyword id: Keyword.ID) -> Tracked<Keyword>? {
        db.tracked(keyword: id)
    }
    
    public func tracked(language id: Language.ID) -> Tracked<Language>? {
        db.tracked(language: id)
    }
    
    public func tracked(note id: Note.ID) -> Tracked<Note>? {
        db.tracked(note: id)
    }

    public func tracked(usage id: Usage.ID) -> Tracked<Usage>? {
        db.tracked(usage: id)
    }
        
}

