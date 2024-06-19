
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
        let new = try Language.init(bcp47: "some_mock")
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

final class AppModel_Add_Tests: AppModelTestCase {

    @MainActor
    func test_addNewEntry_and_addNewTranslation_adopt_settingsDefaultLanguages() async throws {
        var model = AppModel()
        let translationLanguage: Language = try .init(bcp47: "mock_language")
        model.ensureExistenceOf(language: translationLanguage)
        model.settings.defaultTranslationLanguage = translationLanguage
        
        let newEntryResult = model.addNewEntry(
            fromSpelling: "spelling",
            spellingConflictResolution: .none
        )
        
        switch newEntryResult {
        case .success(let new):
            XCTAssertEqual(new.id, .mock(0)) // due to incrementing UUIDGenerator
            XCTAssertEqual(model.languages(for: .entry(new.id)), [model.settings.defaultNewEntryLanguage])
        case .conflicts(let conflicts):
            XCTFail("Expected to successfully insert new entry, but encountered conflicts instead: \(conflicts)")
        case .canceled:
            XCTFail("Expected to successfully insert new entry, but canceled instead")
        }
        

        let newTranslationResult = model.addNewTranslation(
            fromSpelling: "translation",
            forEntry: .mock(0),
            spellingConflictResolution: .none
        )
        
        switch newTranslationResult {
        case .success(let newTranslation):
            XCTAssertEqual(newTranslation.id, .mock(1)) // due to incrementing UUIDGenerator
            XCTAssertEqual(model.languages(for: .entry(newTranslation.id)), [translationLanguage])
        case .conflicts(let conflicts):
            XCTFail("Expected to successfully insert new translation, but encountered conflicts instead: \(conflicts)")
        case .canceled:
            XCTFail("Expected to successfully insert new translation, but canceled instead")
        }
        
    }
    
    
}
