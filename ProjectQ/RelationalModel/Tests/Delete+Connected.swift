
import StructuralModel
import RelationalModel
import XCTest

final class Database_Delete_Connected_Tests: XCTestCase {
    
    let now = Date.now

    func test_delete_connected_entry_removesRelationships() throws {
        var db = Database.mockConnected(entries: 0..<10, created: now)
        let topTranslation = try XCTUnwrap(db.translations(forEntry: .mock(0)).first)
        XCTAssert(db.backTranslations(forEntry: topTranslation.id).contains(where: { $0.id == .mock(0) }))
        db.delete(.entry(.mock(0)))
        XCTAssertFalse(db.backTranslations(forEntry: topTranslation.id).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_language_removesRelationships() throws {
        var db = Database.mockConnected(languages: 0..<3, entries: 0..<10, created: now)
        let topEntry = try XCTUnwrap(db.entries(forLanguage: .mock(0)).first)
        XCTAssert(db.languages(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
        db.delete(.language(.mock(0)))
        XCTAssertFalse(db.languages(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_keyword_removesRelationships() throws {
        var db = Database.mockConnected(keywords: 0..<3, entries: 0..<10, created: now)
        let topEntry = try XCTUnwrap(db.entries(matchingKeyword: .mock(0)).first)
        XCTAssert(db.keywords(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
        db.delete(.keyword(.mock(0)))
        XCTAssertFalse(db.keywords(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_note_removesRelationships() throws {
        var db = Database.mockConnected(notes: 0..<3, entries: 0..<10, created: now)
        let topEntry = try XCTUnwrap(db.entries(targetedByNote: .mock(0)).first)
        XCTAssert(db.notes(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
        db.delete(.note(.mock(0)))
        XCTAssertFalse(db.notes(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_usage_removesRelationships() throws {
        var db = Database.mockConnected(usages: 0..<3, entries: 0..<10, created: now)
        let topEntry = try XCTUnwrap(db.entries(inUsage: .mock(0)).first)
        XCTAssert(db.usages(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
        db.delete(.usage(.mock(0)))
        XCTAssertFalse(db.usages(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_entryCollection_removesRelationships() throws {
        var db = Database.mockConnected(entryCollections: 0..<3, entries: 0..<10, created: now)
        let topEntry = try XCTUnwrap(db.entries(inCollection: .mock(0)).first)
        XCTAssert(db.entryCollections(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
        db.delete(.entryCollection(.mock(0)))
        XCTAssertFalse(db.entryCollections(forEntry: topEntry.id).contains(where: { $0.id == .mock(0) }))
    }
        
    
}

