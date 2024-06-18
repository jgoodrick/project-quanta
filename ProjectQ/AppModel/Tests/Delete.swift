

import AppModel
import StructuralModel
import XCTest

final class AppModel_Delete_Tests: AppModelTestCase {
    
    func test_delete_entry() {
        var model = AppModel.mock(entries: 0..<10, created: .now)
        XCTAssertEqual(model.entries(.all).count, 10)
        model.delete(.entry(.mock(0)))
        XCTAssertEqual(model.entries(.all).count, 9)
        XCTAssertNil(model[entry: .mock(0)])
        XCTAssertNotNil(model[entry: .mock(1)])
    }
    
    func test_delete_language() {
        var model = AppModel.mock(languages: 0..<10, created: .now)
        XCTAssertEqual(model.languages(.all).count, 10)
        model.delete(.language(.mock(0)))
        XCTAssertEqual(model.languages(.all).count, 9)
        XCTAssertNil(model[language: .mock(0)])
        XCTAssertNotNil(model[language: .mock(1)])
    }
    
    func test_delete_keyword() {
        var model = AppModel.mock(keywords: 0..<10, created: .now)
        XCTAssertEqual(model.keywords(.all).count, 10)
        model.delete(.keyword(.mock(0)))
        XCTAssertEqual(model.keywords(.all).count, 9)
        XCTAssertNil(model[keyword: .mock(0)])
        XCTAssertNotNil(model[keyword: .mock(1)])
    }
    
    func test_delete_note() {
        var model = AppModel.mock(notes: 0..<10, created: .now)
        XCTAssertEqual(model.notes(.all).count, 10)
        model.delete(.note(.mock(0)))
        XCTAssertEqual(model.notes(.all).count, 9)
        XCTAssertNil(model[note: .mock(0)])
        XCTAssertNotNil(model[note: .mock(1)])
    }
    
    func test_delete_usage() {
        var model = AppModel.mock(usages: 0..<10, created: .now)
        XCTAssertEqual(model.usages(.all).count, 10)
        model.delete(.usage(.mock(0)))
        XCTAssertEqual(model.usages(.all).count, 9)
        XCTAssertNil(model[usage: .mock(0)])
        XCTAssertNotNil(model[usage: .mock(1)])
    }
    
    func test_delete_entryCollection() {
        var model = AppModel.mock(entryCollections: 0..<10, created: .now)
        XCTAssertEqual(model.entryCollections(.all).count, 10)
        model.delete(.entryCollection(.mock(0)))
        XCTAssertEqual(model.entryCollections(.all).count, 9)
        XCTAssertNil(model[entryCollection: .mock(0)])
        XCTAssertNotNil(model[entryCollection: .mock(1)])
    }
    
    
}

