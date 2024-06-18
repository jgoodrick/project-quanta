
import AppModel
import StructuralModel
import XCTest

final class AppModel_Create_Tests: AppModelTestCase {
    
    func test_create_new_entry() {
        var model = AppModel()
        let new = model.createNewEntry {
            $0.spelling = "0"
        }
        XCTAssertEqual(model[entry: new.id], new)
    }
    
    func test_create_new_language() throws {
        var model = AppModel()
        let new = try Language.init(bcp47: "en_US")
        model.ensureExistenceOf(language: new)
        XCTAssertEqual(model[language: new.id], new)
    }
    
    func test_create_new_keyword() {
        var model = AppModel()
        let new = model.createNewKeyword {
            $0.title = "title"
        }
        XCTAssertEqual(model[keyword: new.id], new)
    }
    
    func test_create_new_note() {
        var model = AppModel()
        let new = model.createNewNote {
            $0.value = "value"
        }
        XCTAssertEqual(model[note: new.id], new)
    }
    
    func test_create_new_usage() {
        var model = AppModel()
        let new = model.createNewUsage {
            $0.value = "value"
        }
        XCTAssertEqual(model[usage: new.id], new)
    }
    
    func test_create_new_entryCollection() {
        var model = AppModel()
        let new = model.createNewEntryCollection {
            $0.title = "title"
        }
        XCTAssertEqual(model[entryCollection: new.id], new)
    }
    
}
