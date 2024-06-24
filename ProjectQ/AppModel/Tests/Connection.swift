
import AppModel
import ComposableArchitecture
import StructuralModel
import XCTest

final class AppModel_Connection_Tests: AppModelTestCase {
        
    func test_connection_of_entry_to_existing_root() {
        var model = AppModel.init()
        let root = model.createNewEntry {
            $0.spelling = "root_spelling"
        }
        let entry = model.createNewEntry {
            $0.spelling = "derived_spelling"
        }
        model.addExisting(root: root.id, toEntry: entry.id)
        XCTAssertEqual(model.entries(.thatAre(.roots(of: entry.id))), [root])
        XCTAssertEqual(model.entries(.thatAre(.derived(from: root.id))), [entry])
        XCTAssertEqual(model.entries(.thatAre(.derived(from: entry.id))), [])
        model.remove(root: root.id, fromEntry: entry.id)
        XCTAssertEqual(model.entries(.thatAre(.roots(of: entry.id))), [])
        XCTAssertEqual(model.entries(.thatAre(.derived(from: root.id))), [])
        XCTAssertEqual(model.entries(.thatAre(.roots(of: root.id))), [])
        XCTAssertEqual(model.entries(.thatAre(.derived(from: entry.id))), [])
    }
    
    @MainActor
    func test_connection_of_entry_to_new_root() async {
        var model = AppModel.init()
        let entry = model.createNewEntry {
            $0.spelling = "derived_spelling"
        }
        let rootResult = model.attemptToAddNewRoot(
            fromSpelling: "new_root_spelling",
            toEntry: entry.id,
            autoAppliedSpellingConflictResolution: .maintainDistinction
        )
        switch rootResult {
        case .success(let root):
            XCTAssertEqual(model.entries(.thatAre(.roots(of: entry.id))), [root])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: root.id))), [entry])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: entry.id))), [])
            model.remove(root: root.id, fromEntry: entry.id)
            XCTAssertEqual(model.entries(.thatAre(.roots(of: entry.id))), [])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: root.id))), [])
            XCTAssertEqual(model.entries(.thatAre(.roots(of: root.id))), [])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: entry.id))), [])
        case .conflicts(let conflicts):
            XCTFail("Expected to successfully insert new entry, but encountered conflicts instead: \(conflicts)")
        case .canceled:
            XCTFail("Expected to successfully insert new entry, but canceled instead")
        }
    }
    
    func test_connection_of_entry_to_existing_root_after_conflict() async {
        var model = AppModel.init()
        let entry = model.createNewEntry {
            $0.spelling = "derived_spelling"
        }
        let existingRoot = model.createNewEntry {
            $0.spelling = "new_root_spelling"
        }
        let returnedRootResult = model.attemptToAddNewRoot(
            fromSpelling: "new_root_spelling",
            toEntry: entry.id,
            autoAppliedSpellingConflictResolution: .mergeWithFirstMatch
        )
        switch returnedRootResult {
        case .success(let returnedRoot):
            XCTAssertEqual(returnedRoot, existingRoot)
            XCTAssertEqual(model.entries(.thatAre(.roots(of: entry.id))), [existingRoot])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: existingRoot.id))), [entry])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: entry.id))), [])
            model.remove(root: existingRoot.id, fromEntry: entry.id)
            XCTAssertEqual(model.entries(.thatAre(.roots(of: entry.id))), [])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: existingRoot.id))), [])
            XCTAssertEqual(model.entries(.thatAre(.roots(of: existingRoot.id))), [])
            XCTAssertEqual(model.entries(.thatAre(.derived(from: entry.id))), [])
        case .conflicts(let conflicts):
            XCTFail("Expected to successfully insert new entry, but encountered conflicts instead: \(conflicts)")
        case .canceled:
            XCTFail("Expected to successfully insert new entry, but canceled instead")
        }
    }
    
    func test_connection_of_entry_to_seeAlso() {
        var model = AppModel.init()
        let entry = model.createNewEntry {
            $0.spelling = "entry_spelling"
        }
        let seeAlso = model.createNewEntry {
            $0.spelling = "seeAlso_spelling"
        }
        model.addExisting(seeAlso: seeAlso.id, toEntry: entry.id)
        XCTAssertEqual(model.entries(.thatAre(.seeAlsos(of: entry.id))), [seeAlso])
        XCTAssertEqual(model.entries(.thatAre(.seeAlsos(of: seeAlso.id))), [entry])
        model.remove(seeAlso: seeAlso.id, fromEntry: entry.id)
        XCTAssertEqual(model.entries(.thatAre(.seeAlsos(of: entry.id))), [])
        XCTAssertEqual(model.entries(.thatAre(.seeAlsos(of: seeAlso.id))), [])
    }
        
    func test_connection_of_language_to_entry() throws {
        var model = AppModel.init()
        let entry = model.createNewEntry {
            $0.spelling = "entry_spelling"
        }
        let language = Language.mock(1)
        model.ensureExistenceOf(language: language)
        model.addExisting(language: language.id, toEntry: entry.id)
        XCTAssertEqual(model.languages(.of(.entry(entry.id))), [language])
        XCTAssertEqual(model.entries(.of(.language(language.id))), [entry])
        model.remove(language: language.id, fromEntry: entry.id)
        XCTAssertEqual(model.languages(.of(.entry(entry.id))), [])
        XCTAssertEqual(model.entries(.of(.language(language.id))), [])
    }
    
    func test_connection_of_language_to_usage() throws {
        var model = AppModel.init()
        let usage = model.createNewUsage {
            $0.value = "new usage value"
        }
        let language = Language.mock(1)
        model.ensureExistenceOf(language: language)
        model.addExisting(language: language.id, toUsage: usage.id)
        XCTAssertEqual(model.languages(.of(.usage(usage.id))), [language])
        XCTAssertEqual(model.usages(.of(.language(language.id))), [usage])
        model.remove(language: language.id, fromUsage: usage.id)
        XCTAssertEqual(model.languages(.of(.usage(usage.id))), [])
        XCTAssertEqual(model.usages(.of(.language(language.id))), [])
    }
    
    func test_connection_of_keyword_to_entry() {
        var model = AppModel.init()
        let entry = model.createNewEntry {
            $0.spelling = "entry_spelling"
        }
        let keyword = model.createNewKeyword {
            $0.title = "new_keyword"
        }
        model.addExisting(keyword: keyword.id, toEntry: entry.id)
        XCTAssertEqual(model.keywords(.of(.entry(entry.id))), [keyword])
        XCTAssertEqual(model.entries(.of(.keyword(keyword.id))), [entry])
        model.remove(keyword: keyword.id, fromEntry: entry.id)
        XCTAssertEqual(model.keywords(.of(.entry(entry.id))), [])
        XCTAssertEqual(model.entries(.of(.keyword(keyword.id))), [])
    }
    
    func test_connection_of_note_to_entry() {
        var model = AppModel.init()
        let entry = model.createNewEntry {
            $0.spelling = "entry_spelling"
        }
        let note = model.createNewNote {
            $0.value = "new note value"
        }
        model.addExisting(note: note.id, toEntry: entry.id)
        XCTAssertEqual(model.notes(.of(.entry(entry.id))), [note])
        model.remove(note: note.id, fromEntry: entry.id)
        XCTAssertEqual(model.notes(.of(.entry(entry.id))), [])
    }
    
    func test_connection_of_note_to_usage() {
        var model = AppModel.init()
        let usage = model.createNewUsage {
            $0.value = "usage_spelling"
        }
        let note = model.createNewNote {
            $0.value = "new note value"
        }
        model.addExisting(note: note.id, toUsage: usage.id)
        XCTAssertEqual(model.notes(.of(.usage(usage.id))), [note])
        model.remove(note: note.id, fromUsage: usage.id)
        XCTAssertEqual(model.notes(.of(.usage(usage.id))), [])
    }
    
    func test_connection_of_usage_to_entry() {
        var model = AppModel.init()
        let usage = model.createNewUsage {
            $0.value = "usage_spelling"
        }
        let entry = model.createNewEntry {
            $0.spelling = "entry_spelling"
        }
        model.addExisting(usage: usage.id, toEntry: entry.id)
        XCTAssertEqual(model.entries(.of(.usage(usage.id))), [entry])
        XCTAssertEqual(model.usages(.of(.entry(entry.id))), [usage])
        model.remove(usage: usage.id, fromEntry: entry.id)
        XCTAssertEqual(model.entries(.of(.usage(usage.id))), [])
        XCTAssertEqual(model.usages(.of(.entry(entry.id))), [])
    }
    
    func test_connection_of_entryCollection_to_entry() {
        var model = AppModel.init()
        let entryCollection = model.createNewEntryCollection {
            $0.title = "entryCollection_title"
        }
        let entry = model.createNewEntry {
            $0.spelling = "entry_spelling"
        }
        model.addExisting(entry: entry.id, toEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry.id))), [entryCollection])
        model.remove(entry: entry.id, fromEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry.id))), [])
    }
    
    func test_addition_of_sequential_entries_to_entryCollection() {
        var model = AppModel.init()
        let entryCollection = model.createNewEntryCollection {
            $0.title = "entryCollection_title"
        }
        let entry_a = model.createNewEntry {
            $0.spelling = "entry_a"
        }
        let entry_b = model.createNewEntry {
            $0.spelling = "entry_b"
        }
        let entry_c = model.createNewEntry {
            $0.spelling = "entry_c"
        }
        let entry_d = model.createNewEntry {
            $0.spelling = "entry_d"
        }
        model.addExisting(entry: entry_a.id, toEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_a])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_a.id))), [entryCollection])
        model.addExisting(entry: entry_b.id, toEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_a, entry_b])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_b.id))), [entryCollection])
        model.addExisting(entry: entry_c.id, toEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_a, entry_b, entry_c])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_c.id))), [entryCollection])
        model.addExisting(entry: entry_d.id, toEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_a, entry_b, entry_c, entry_d])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_d.id))), [entryCollection])

        
        model.remove(entry: entry_a.id, fromEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_b, entry_c, entry_d])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_a.id))), [])
        model.remove(entry: entry_c.id, fromEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_b, entry_d])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_c.id))), [])
        
        model.remove(entry: entry_c.id, fromEntryCollection: entryCollection.id)
        XCTAssertEqual(model.entries(.of(.entryCollection(entryCollection.id))), [entry_b, entry_d])
        XCTAssertEqual(model.entryCollections(.thatContain(.entry(entry_c.id))), [])
    }
    
}

