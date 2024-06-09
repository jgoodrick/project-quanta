
import ComposableArchitecture
import ModelCore
import RelationalCore

extension Database {
    
    public mutating func createNewEntry(language: Language? = nil, builder: (inout Entry) -> Void) -> Entry {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        var new = Entry(id: .init(rawValue: uuid()))
        builder(&new)
        precondition(!new.spelling.isEmpty)
        create(.entry(new), now: date.now)
        if let language {
            connect(language: language.id, toEntry: new.id)
        }
        return new
    }
    
    public mutating func createNewKeyword(builder: (inout Keyword) -> Void) -> Keyword {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        var new = Keyword(id: .init(rawValue: uuid()))
        builder(&new)
        precondition(!new.title.isEmpty)
        create(.keyword(new), now: date.now)
        return new
    }
    
    public mutating func createNewNote(builder: (inout Note) -> Void = { _ in }) -> Note {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        var new = Note(id: .init(rawValue: uuid()))
        builder(&new)
        create(.note(new), now: date.now)
        return new
    }
    
    public mutating func createNewUsage(language: Language? = nil, builder: (inout Usage) -> Void) -> Usage {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        var new = Usage(id: .init(rawValue: uuid()))
        builder(&new)
        precondition(!new.value.isEmpty)
        create(.usage(new), now: date.now)
        if let language {
            connect(language: language.id, toUsage: new.id)
        }
        return new
    }
    
    public mutating func createNewEntryCollection(builder: (inout EntryCollection) -> Void) -> EntryCollection {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        var new = EntryCollection(id: .init(rawValue: uuid()))
        builder(&new)
        precondition(!new.title.isEmpty)
        create(.entryCollection(new), now: date.now)
        return new
    }

}
