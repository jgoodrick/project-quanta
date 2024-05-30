
import Foundation

extension Database {
    
    public mutating func moveTranslations(on entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        precondition(stored.entries[entry] != nil)
        relationships.entries[id: entry].translations.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveLanguages(for user: User.ID, fromOffsets: IndexSet, toOffset: Int) {
        precondition(stored.users[user] != nil)
        relationships.users[id: user].languages.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveNotes(on entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        precondition(stored.entries[entry] != nil)
        relationships.entries[id: entry].notes.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveUsages(on entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        precondition(stored.entries[entry] != nil)
        relationships.entries[id: entry].usages.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveEntries(in entryCollection: EntryCollection.ID, fromOffsets: IndexSet, toOffset: Int) {
        precondition(stored.entryCollections[entryCollection] != nil)
        relationships.entryCollections[id: entryCollection].entries.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }

}

