
import AppModel
import StructuralModel
import XCTest

final class AppModel_Update_Tests: AppModelTestCase {
    
    func test_update_entry() async {
        var model = AppModel()
        let entry = model.createNewEntry {
            $0.spelling = "old_spelling"
        }
        let entry_other = model.createNewEntry {
            $0.spelling = "other_spelling"
        }
        model.updateEntry(\.spelling, of: entry.id, to: "new_spelling")
        XCTAssertEqual(model[entry: entry.id]?.spelling, "new_spelling")
        XCTAssertEqual(model[entry: entry_other.id]?.spelling, "other_spelling")
    }
    
    func test_update_keyword() {
        var model = AppModel()
        let keyword = model.createNewKeyword {
            $0.title = "old_title"
        }
        let keyword_other = model.createNewKeyword {
            $0.title = "other_title"
        }
        model.updateKeyword(\.title, of: keyword.id, to: "new_title")
        XCTAssertEqual(model[keyword: keyword.id]?.title, "new_title")
        XCTAssertEqual(model[keyword: keyword_other.id]?.title, "other_title")
    }
    
    func test_update_note() {
        var model = AppModel()
        let note = model.createNewNote {
            $0.value = "old_value"
        }
        let note_other = model.createNewNote {
            $0.value = "other_value"
        }
        model.updateNote(\.value, of: note.id, to: "new_value")
        XCTAssertEqual(model[note: note.id]?.value, "new_value")
        XCTAssertEqual(model[note: note_other.id]?.value, "other_value")
    }
    
    func test_update_usage() {
        var model = AppModel()
        let usage = model.createNewUsage {
            $0.value = "old_value"
        }
        let usage_other = model.createNewUsage {
            $0.value = "other_value"
        }
        model.updateUsage(\.value, of: usage.id, to: "new_value")
        XCTAssertEqual(model[usage: usage.id]?.value, "new_value")
        XCTAssertEqual(model[usage: usage_other.id]?.value, "other_value")
    }
    
    func test_update_entryCollection() {
        var model = AppModel()
        let entryCollection = model.createNewEntryCollection {
            $0.title = "old_title"
        }
        let entryCollection_other = model.createNewEntryCollection {
            $0.title = "other_title"
        }
        model.updateEntryCollection(\.title, of: entryCollection.id, to: "new_title")
        XCTAssertEqual(model[entryCollection: entryCollection.id]?.title, "new_title")
        XCTAssertEqual(model[entryCollection: entryCollection_other.id]?.title, "other_title")
    }
    
}

