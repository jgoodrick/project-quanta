
import ModelCore
import RelationalCore
import XCTest

final class RelationalCore_Read_Tests: XCTestCase {
    
    let now = Date.now

    @MainActor
    func test_read_expected_entry() throws {
        let db = Database.mock(entries: 0..<10, created: now)
        let first = try XCTUnwrap(db.entries(where: { $0.id == .mock(0) }).first)
        XCTAssertEqual(db[entry: first.id], first)
    }
    
    @MainActor
    func test_read_expected_language() throws {
        let db = Database.mock(languages: 0..<10, created: now)
        let first = try XCTUnwrap(db.languages(where: { $0.id == .mock(0) }).first)
        XCTAssertEqual(db[language: first.id], first)
    }
    
    @MainActor
    func test_read_expected_keyword() throws {
        let db = Database.mock(keywords: 0..<10, created: now)
        let first = try XCTUnwrap(db.keywords(where: { $0.id == .mock(0) }).first)
        XCTAssertEqual(db[keyword: first.id], first)
    }
    
    @MainActor
    func test_read_expected_note() throws {
        let db = Database.mock(notes: 0..<10, created: now)
        let first = try XCTUnwrap(db.notes(where: { $0.id == .mock(0) }).first)
        XCTAssertEqual(db[note: first.id], first)
    }
    
    @MainActor
    func test_read_expected_usage() throws {
        let db = Database.mock(usages: 0..<10, created: now)
        let first = try XCTUnwrap(db.usages(where: { $0.id == .mock(0) }).first)
        XCTAssertEqual(db[usage: first.id], first)
    }
    
    @MainActor
    func test_read_expected_entryCollection() throws {
        let db = Database.mock(entryCollections: 0..<10, created: now)
        let first = try XCTUnwrap(db.entryCollections(where: { $0.id == .mock(0) }).first)
        XCTAssertEqual(db[entryCollection: first.id], first)
    }
    
}
