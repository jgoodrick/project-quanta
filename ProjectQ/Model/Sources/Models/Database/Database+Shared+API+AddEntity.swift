
import ComposableArchitecture

extension Shared<Database> {
    
    struct EntityMissingImmediatelyAfterAddition<Entity: Identifiable>: Error {
        let entity: Entity
    }
    
    public mutating func addNewEntry(language: Language? = nil, builder: (inout Entry) -> Void) throws -> Entry.Expansion {
        @Dependency(\.uuid) var uuid
        var new = Entry(id: uuid())
        builder(&new)
        precondition(!new.spelling.isEmpty)
        wrappedValue.add(entry: new)
        if let language {
            wrappedValue.updateLanguage(to: language.id, for: new.id)
        }
        guard let expansion = self[entry: new.id] else { throw EntityMissingImmediatelyAfterAddition(entity: new) }
        return expansion
    }
    
    public mutating func addNewLanguage(id: Language.ID, builder: (inout Language) -> Void) throws -> Language.Expansion {
        var new = Language(id: id)
        builder(&new)
        precondition(!new.id.string.isEmpty)
        wrappedValue.add(language: new)
        guard let expansion = self[language: new.id] else { throw EntityMissingImmediatelyAfterAddition(entity: new) }
        return expansion
    }
    
    public mutating func addNewKeyword(builder: (inout Keyword) -> Void) throws -> Keyword.Expansion {
        @Dependency(\.uuid) var uuid
        var new = Keyword(id: uuid())
        builder(&new)
        precondition(!new.title.isEmpty)
        wrappedValue.add(keyword: new)
        guard let expansion = self[keyword: new.id] else { throw EntityMissingImmediatelyAfterAddition(entity: new) }
        return expansion
    }
    
    public mutating func addNewNote(builder: (inout Note) -> Void) throws -> Note.Expansion {
        @Dependency(\.uuid) var uuid
        var new = Note(id: uuid())
        builder(&new)
        precondition(!new.value.isEmpty)
        wrappedValue.add(note: new)
        guard let expansion = self[note: new.id] else { throw EntityMissingImmediatelyAfterAddition(entity: new) }
        return expansion
    }
    
    public mutating func addNewUsage(builder: (inout Usage) -> Void) throws -> Usage.Expansion {
        @Dependency(\.uuid) var uuid
        var new = Usage(id: uuid())
        builder(&new)
        precondition(!new.value.isEmpty)
        wrappedValue.add(usage: new)
        guard let expansion = self[usage: new.id] else { throw EntityMissingImmediatelyAfterAddition(entity: new) }
        return expansion
    }
    
    public mutating func addNewEntryCollection(builder: (inout EntryCollection) -> Void) throws -> EntryCollection.Expansion {
        @Dependency(\.uuid) var uuid
        var new = EntryCollection(id: uuid())
        builder(&new)
        precondition(!new.title.isEmpty)
        wrappedValue.add(entryCollection: new)
        guard let expansion = self[entryCollection: new.id] else { throw EntityMissingImmediatelyAfterAddition(entity: new) }
        return expansion
    }

}
