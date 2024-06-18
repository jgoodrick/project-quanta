

import StructuralModel
import RelationalModel
import XCTest

final class Database_Delete_Tests: XCTestCase {
    
    let now = Date.now

    func test_delete_entry() {
        var db = Database.mock(entries: 0..<10, created: now)
        XCTAssertEqual(db.entries().count, 10)
        db.delete(.entry(.mock(0)))
        XCTAssertEqual(db.entries().count, 9)
        XCTAssertNil(db[entry: .mock(0)])
        XCTAssertNotNil(db[entry: .mock(1)])
    }
    
    func test_delete_language() {
        var db = Database.mock(languages: 0..<10, created: now)
        XCTAssertEqual(db.languages().count, 10)
        db.delete(.language(.mock(0)))
        XCTAssertEqual(db.languages().count, 9)
        XCTAssertNil(db[language: .mock(0)])
        XCTAssertNotNil(db[language: .mock(1)])
    }
    
    func test_delete_keyword() {
        var db = Database.mock(keywords: 0..<10, created: now)
        XCTAssertEqual(db.keywords().count, 10)
        db.delete(.keyword(.mock(0)))
        XCTAssertEqual(db.keywords().count, 9)
        XCTAssertNil(db[keyword: .mock(0)])
        XCTAssertNotNil(db[keyword: .mock(1)])
    }
    
    func test_delete_note() {
        var db = Database.mock(notes: 0..<10, created: now)
        XCTAssertEqual(db.notes().count, 10)
        db.delete(.note(.mock(0)))
        XCTAssertEqual(db.notes().count, 9)
        XCTAssertNil(db[note: .mock(0)])
        XCTAssertNotNil(db[note: .mock(1)])
    }
    
    func test_delete_usage() {
        var db = Database.mock(usages: 0..<10, created: now)
        XCTAssertEqual(db.usages().count, 10)
        db.delete(.usage(.mock(0)))
        XCTAssertEqual(db.usages().count, 9)
        XCTAssertNil(db[usage: .mock(0)])
        XCTAssertNotNil(db[usage: .mock(1)])
    }
    
    func test_delete_entryCollection() {
        var db = Database.mock(entryCollections: 0..<10, created: now)
        XCTAssertEqual(db.entryCollections().count, 10)
        db.delete(.entryCollection(.mock(0)))
        XCTAssertEqual(db.entryCollections().count, 9)
        XCTAssertNil(db[entryCollection: .mock(0)])
        XCTAssertNotNil(db[entryCollection: .mock(1)])
    }
    
    
}

