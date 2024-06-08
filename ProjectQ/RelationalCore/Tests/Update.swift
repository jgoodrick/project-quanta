
import ModelCore
import RelationalCore
import XCTest

final class RelationalCore_Update_Tests: XCTestCase {
    
    let now = Date.now

    @MainActor
    func test_update_entry() {
        var db = Database.mock(entries: 0..<10, created: now)
        db.update(.entry(.init(id: .init(0), spelling: "new spelling")))
        XCTAssertEqual(db[entry: .init(0)]?.spelling, "new spelling")
        XCTAssertEqual(db[entry: .init(1)]?.spelling, "1")
    }
    
}

