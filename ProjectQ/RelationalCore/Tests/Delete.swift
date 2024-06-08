

import ModelCore
import RelationalCore
import XCTest

final class RelationalCore_Delete_Tests: XCTestCase {
    
    let now = Date.now

    @MainActor
    func test_delete_entry() {
        var db = Database.mock(entries: 0..<10, created: now)
        XCTAssertEqual(db.entries().count, 10)
        db.delete(.entry(.init(0)))
        XCTAssertEqual(db.entries().count, 9)
        XCTAssertNil(db[entry: .init(0)])
        XCTAssertNotNil(db[entry: .init(1)])
    }
    
}

