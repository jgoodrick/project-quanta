
import StructuralModel
import RelationalModel
import XCTest

final class Database_Create_Tests: XCTestCase {
    
    let now = Date.now
    var db = Database()

    func test_create_new_entry() {
        let new = Entry.init(id: .mock(0))
        db.create(.entry(new), now: now)
        XCTAssertEqual(db[entry: new.id], new)
    }
    
    func test_create_new_language() throws {
        let new = try Language.init(bcp47: "en_US")
        db.create(.language(new), now: now)
        XCTAssertEqual(db[language: new.id], new)
    }
    
    func test_create_new_keyword() {
        let new = Keyword.init(id: .mock(0))
        db.create(.keyword(new), now: now)
        XCTAssertEqual(db[keyword: new.id], new)
    }
    
    func test_create_new_note() {
        let new = Note.init(id: .mock(0))
        db.create(.note(new), now: now)
        XCTAssertEqual(db[note: new.id], new)
    }
    
    func test_create_new_usage() {
        let new = Usage.init(id: .mock(0))
        db.create(.usage(new), now: now)
        XCTAssertEqual(db[usage: new.id], new)
    }
    
    func test_create_new_entryCollection() {
        let new = EntryCollection.init(id: .mock(0))
        db.create(.entryCollection(new), now: now)
        XCTAssertEqual(db[entryCollection: new.id], new)
    }
    
}
