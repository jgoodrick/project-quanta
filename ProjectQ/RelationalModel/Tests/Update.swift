
import StructuralModel
import RelationalModel
import XCTest

final class Database_Update_Tests: XCTestCase {
    
    let now = Date.now

    func test_update_entry() {
        var db = Database.mock(entries: 0..<10, created: now)
        db.update(.entry(.init(id: .mock(0), spelling: "new spelling")))
        XCTAssertEqual(db[entry: .mock(0)]?.spelling, "new spelling")
        XCTAssertEqual(db[entry: .mock(1)]?.spelling, "1")
    }
    
    func test_update_keyword() {
        var db = Database.mock(keywords: 0..<10, created: now)
        db.update(.keyword(.init(id: .mock(0), title: "updated")))
        XCTAssertEqual(db[keyword: .mock(0)]?.title, "updated")
        XCTAssertEqual(db[keyword: .mock(1)]?.title, "1")
    }
    
    func test_update_note() {
        var db = Database.mock(notes: 0..<10, created: now)
        db.update(.note(.init(id: .mock(0), value: "updated")))
        XCTAssertEqual(db[note: .mock(0)]?.value, "updated")
        XCTAssertEqual(db[note: .mock(1)]?.value, "1")
    }
    
    func test_update_usage() {
        var db = Database.mock(usages: 0..<10, created: now)
        db.update(.usage(.init(id: .mock(0), value: "updated")))
        XCTAssertEqual(db[usage: .mock(0)]?.value, "updated")
        XCTAssertEqual(db[usage: .mock(1)]?.value, "1")
    }
    
    func test_update_entryCollection() {
        var db = Database.mock(entryCollections: 0..<10, created: now)
        db.update(.entryCollection(.init(id: .mock(0), title: "updated")))
        XCTAssertEqual(db[entryCollection: .mock(0)]?.title, "updated")
        XCTAssertEqual(db[entryCollection: .mock(1)]?.title, "1")
    }
    
}

