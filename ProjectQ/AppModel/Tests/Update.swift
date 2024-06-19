
import AppModel
import StructuralModel
import XCTest

final class AppModel_Update_Tests: AppModelTestCase {
    
    func test_update_entry_spelling_toUniqueValue() {
        var model = AppModel()
        let entry = model.createNewEntry {
            $0.spelling = "old_spelling"
        }
        let entry_other = model.createNewEntry {
            $0.spelling = "other_spelling"
        }
        switch model.updateEntrySpelling(of: entry.id, to: "new_spelling") {
        case .success(let result):
            XCTAssertEqual(model[entry: entry.id], result)
            XCTAssertNotEqual(model[entry: entry_other.id], result)
        case .canceled:
            XCTFail("Expected to succeed without cancellation")
        case .conflicts(let conflicts):
            XCTFail("Expected to succeed without conflicts, but encountered: \(conflicts)")
        }
    }
    
    func test_update_entry_spelling_toConflictingValue() {
        var model = AppModel()
        let entry = model.createNewEntry {
            $0.spelling = "old_spelling"
        }
        let entry_other = model.createNewEntry {
            $0.spelling = "other_spelling"
        }
        switch model.updateEntrySpelling(of: entry.id, to: "other_spelling") {
        case .success(_):
            XCTFail("Expected to encounter a conflict, but did not")
        case .canceled:
            XCTFail("Expected to succeed without cancellation")
        case .conflicts(let conflicts):
            XCTAssertEqual(conflicts, [entry_other])
        }
    }
    
    func test_update_entryCollection_title_toUniqueValue() {
        var model = AppModel()
        let entryCollection = model.createNewEntryCollection {
            $0.title = "old_title"
        }
        let entryCollection_other = model.createNewEntryCollection {
            $0.title = "other_title"
        }
        switch model.updateEntryCollectionTitle(of: entryCollection.id, to: "new_title") {
        case .success(let result):
            XCTAssertEqual(model[entryCollection: entryCollection.id], result)
            XCTAssertNotEqual(model[entryCollection: entryCollection_other.id], result)
        case .canceled:
            XCTFail("Expected to succeed without cancellation")
        case .conflicts(let conflicts):
            XCTFail("Expected to succeed without conflicts, but encountered: \(conflicts)")
        }
    }
    
    func test_update_entryCollection_title_toConflictingValue() {
        var model = AppModel()
        let entryCollection = model.createNewEntryCollection {
            $0.title = "old_title"
        }
        let entryCollection_other = model.createNewEntryCollection {
            $0.title = "other_title"
        }
        switch model.updateEntryCollectionTitle(of: entryCollection.id, to: "other_title") {
        case .success(_):
            XCTFail("Expected to encounter a conflict, but did not")
        case .canceled:
            XCTFail("Expected to succeed without cancellation")
        case .conflicts(let conflicts):
            XCTAssertEqual(conflicts, [entryCollection_other])
        }
    }
    
    func test_update_keyword_title_toUniqueValue() {
        var model = AppModel()
        let keyword = model.createNewKeyword {
            $0.title = "old_title"
        }
        let keyword_other = model.createNewKeyword {
            $0.title = "other_title"
        }
        switch model.updateKeywordTitle(of: keyword.id, to: "new_title") {
        case .success(let result):
            XCTAssertEqual(model[keyword: keyword.id], result)
            XCTAssertNotEqual(model[keyword: keyword_other.id], result)
        case .canceled:
            XCTFail("Expected to succeed without cancellation")
        case .conflicts(let conflicts):
            XCTFail("Expected to succeed without conflicts, but encountered: \(conflicts)")
        }
    }
    
    func test_update_keyword_title_toConflictingValue() {
        var model = AppModel()
        let keyword = model.createNewKeyword {
            $0.title = "old_title"
        }
        let keyword_other = model.createNewKeyword {
            $0.title = "other_title"
        }
        switch model.updateKeywordTitle(of: keyword.id, to: "other_title") {
        case .success(_):
            XCTFail("Expected to encounter a conflict, but did not")
        case .canceled:
            XCTFail("Expected to succeed without cancellation")
        case .conflicts(let conflicts):
            XCTAssertEqual(conflicts, [keyword_other])
        }
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
    
}

