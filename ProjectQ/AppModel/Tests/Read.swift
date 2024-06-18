
import AppModel
import StructuralModel
import XCTest

final class AppModel_Read_Tests: AppModelTestCase {
    
    func test_read_expected_entry() throws {
        let model = AppModel.mock(entries: 0..<10, created: .now)
        XCTAssertNotNil(model[entry: .mock(0)])
    }
    
    func test_read_expected_language() throws {
        let model = AppModel.mock(languages: 0..<10, created: .now)
        XCTAssertNotNil(model[language: .mock(0)])
    }
    
    func test_read_expected_keyword() throws {
        let model = AppModel.mock(keywords: 0..<10, created: .now)
        XCTAssertNotNil(model[keyword: .mock(0)])
    }
    
    func test_read_expected_note() throws {
        let model = AppModel.mock(notes: 0..<10, created: .now)
        XCTAssertNotNil(model[note: .mock(0)])
    }
    
    func test_read_expected_usage() throws {
        let model = AppModel.mock(usages: 0..<10, created: .now)
        XCTAssertNotNil(model[usage: .mock(0)])
    }
    
    func test_read_expected_entryCollection() throws {
        let model = AppModel.mock(entryCollections: 0..<10, created: .now)
        XCTAssertNotNil(model[entryCollection: .mock(0)])
    }
    
}
