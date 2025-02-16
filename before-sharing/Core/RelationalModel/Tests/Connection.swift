
import StructuralModel
import RelationalModel
import XCTest

final class Database_Connection_Tests: XCTestCase {
    
    let now = Date.now
    var db = Database()

    func test_connection_of_entry_to_root() {
        let entry = Entry.init(id: .mock(0))
        let root = Entry.init(id: .mock(1))
        db.create(.entry(entry), now: now)
        db.create(.entry(root), now: now)
        db.connect(root: root.id, toEntry: entry.id)
        XCTAssertEqual(db.roots(forEntry: entry.id), [root])
        XCTAssertEqual(db.derived(forEntry: root.id), [entry])
        XCTAssertEqual(db.roots(forEntry: root.id), [])
        XCTAssertEqual(db.derived(forEntry: entry.id), [])
        db.disconnect(root: root.id, fromEntry: entry.id)
        XCTAssertEqual(db.roots(forEntry: entry.id), [])
        XCTAssertEqual(db.derived(forEntry: root.id), [])
        XCTAssertEqual(db.roots(forEntry: root.id), [])
        XCTAssertEqual(db.derived(forEntry: entry.id), [])
    }
    
    func test_connection_of_entry_to_seeAlso() {
        let entry = Entry.init(id: .mock(0))
        let related = Entry.init(id: .mock(1))
        db.create(.entry(entry), now: now)
        db.create(.entry(related), now: now)
        db.connect(seeAlso: related.id, toEntry: entry.id)
        XCTAssertEqual(db.seeAlso(forEntry: entry.id), [related])
        XCTAssertEqual(db.seeAlso(forEntry: related.id), [entry])
        db.disconnect(seeAlso: related.id, fromEntry: entry.id)
        XCTAssertEqual(db.seeAlso(forEntry: entry.id), [])
        XCTAssertEqual(db.seeAlso(forEntry: related.id), [])
    }
        
    func test_connection_of_language_to_entry() throws {
        let entry = Entry.init(id: .mock(0))
        let language = Language.mock(1)
        db.create(.entry(entry), now: now)
        db.create(.language(language), now: now)
        db.connect(language: language.id, toEntry: entry.id)
        XCTAssertEqual(db.languages(forEntry: entry.id), [language])
        XCTAssertEqual(db.entries(forLanguage: language.id), [entry])
        db.disconnect(language: language.id, fromEntry: entry.id)
        XCTAssertEqual(db.languages(forEntry: entry.id), [])
        XCTAssertEqual(db.entries(forLanguage: language.id), [])
    }
    
    func test_connection_of_language_to_usage() throws {
        let usage = Usage.init(id: .mock(0))
        let language = Language.mock(1)
        db.create(.usage(usage), now: now)
        db.create(.language(language), now: now)
        db.connect(language: language.id, toUsage: usage.id)
        XCTAssertEqual(db.languages(forUsage: usage.id), [language])
        XCTAssertEqual(db.usages(forLanguage: language.id), [usage])
        db.disconnect(language: language.id, fromUsage: usage.id)
        XCTAssertEqual(db.languages(forUsage: usage.id), [])
        XCTAssertEqual(db.entries(forLanguage: language.id), [])
    }
    
    func test_connection_of_keyword_to_entry() {
        let entry = Entry.init(id: .mock(0))
        let keyword = Keyword.init(id: .mock(1))
        db.create(.entry(entry), now: now)
        db.create(.keyword(keyword), now: now)
        db.connect(keyword: keyword.id, toEntry: entry.id)
        XCTAssertEqual(db.keywords(forEntry: entry.id), [keyword])
        XCTAssertEqual(db.entries(matchingKeyword: keyword.id), [entry])
        db.disconnect(keyword: keyword.id, fromEntry: entry.id)
        XCTAssertEqual(db.keywords(forEntry: entry.id), [])
        XCTAssertEqual(db.entries(matchingKeyword: keyword.id), [])
    }
    
    func test_connection_of_note_to_entry() {
        let entry = Entry.init(id: .mock(0))
        let note = Note.init(id: .mock(1))
        db.create(.entry(entry), now: now)
        db.create(.note(note), now: now)
        db.connect(note: note.id, toEntry: entry.id)
        XCTAssertEqual(db.notes(forEntry: entry.id), [note])
        XCTAssertEqual(db.entries(targetedByNote: note.id), [entry])
        db.disconnect(note: note.id, fromEntry: entry.id)
        XCTAssertEqual(db.notes(forEntry: entry.id), [])
        XCTAssertEqual(db.entries(targetedByNote: note.id), [])
    }
    
    func test_connection_of_note_to_usage() {
        let usage = Usage.init(id: .mock(0))
        let note = Note.init(id: .mock(1))
        db.create(.usage(usage), now: now)
        db.create(.note(note), now: now)
        db.connect(note: note.id, toUsage: usage.id)
        XCTAssertEqual(db.notes(forUsage: usage.id), [note])
        XCTAssertEqual(db.usages(targetedByNote: note.id), [usage])
        db.disconnect(note: note.id, fromUsage: usage.id)
        XCTAssertEqual(db.notes(forUsage: usage.id), [])
        XCTAssertEqual(db.usages(targetedByNote: note.id), [])
    }
    
    func test_connection_of_usage_to_entry() {
        let usage = Usage.init(id: .mock(0))
        let entry = Entry.init(id: .mock(1))
        db.create(.usage(usage), now: now)
        db.create(.entry(entry), now: now)
        db.connect(usage: usage.id, toEntry: entry.id)
        XCTAssertEqual(db.entries(inUsage: usage.id), [entry])
        XCTAssertEqual(db.usages(forEntry: entry.id), [usage])
        db.disconnect(usage: usage.id, fromEntry: entry.id)
        XCTAssertEqual(db.entries(inUsage: usage.id), [])
        XCTAssertEqual(db.usages(forEntry: entry.id), [])
    }
    
    func test_connection_of_entryCollection_to_entry() {
        let entryCollection = EntryCollection.init(id: .mock(0))
        let entry = Entry.init(id: .mock(1))
        db.create(.entryCollection(entryCollection), now: now)
        db.create(.entry(entry), now: now)
        db.connect(entry: entry.id, toCollection: entryCollection.id)
        XCTAssertEqual(db.entries(inCollection: entryCollection.id), [entry])
        XCTAssertEqual(db.entryCollections(forEntry: entry.id), [entryCollection])
        db.disconnect(entry: entry.id, fromEntryCollection: entryCollection.id)
        XCTAssertEqual(db.entries(inCollection: entryCollection.id), [])
        XCTAssertEqual(db.entryCollections(forEntry: entry.id), [])
    }
    
}

