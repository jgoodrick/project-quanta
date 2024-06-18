
import AppModel
import StructuralModel
import XCTest

final class AppModel_Delete_Connected_Tests: AppModelTestCase {
    
    func test_delete_connected_entry_removesRelationships() throws {
        var model = AppModel.mockConnected(entries: 0..<10, created: .now)
        let topTranslation = try XCTUnwrap(model.entries(.thatAre(.translations(of: .mock(0)))).first)
        XCTAssert(model.entries(.thatAre(.backTranslations(of: topTranslation.id))).contains(where: { $0.id == .mock(0) }))
        model.delete(.entry(.mock(0)))
        XCTAssertFalse(model.entries(.thatAre(.backTranslations(of: topTranslation.id))).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_language_removesRelationships() throws {
        var model = AppModel.mockConnected(languages: 0..<3, entries: 0..<10, created: .now)
        let topEntry = try XCTUnwrap(model.entries(.of(.language(.mock(0)))).first)
        XCTAssert(model.languages(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
        model.delete(.language(.mock(0)))
        XCTAssertFalse(model.languages(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_keyword_removesRelationships() throws {
        var model = AppModel.mockConnected(keywords: 0..<3, entries: 0..<10, created: .now)
        let topEntry = try XCTUnwrap(model.entries(.of(.keyword(.mock(0)))).first)
        XCTAssert(model.keywords(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
        model.delete(.keyword(.mock(0)))
        XCTAssertFalse(model.keywords(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_note_removesRelationships() throws {
        var model = AppModel.mockConnected(notes: 0..<3, entries: 0..<10, created: .now)
        let topEntry = try XCTUnwrap(model.entries(.of(.note(.mock(0)))).first)
        XCTAssert(model.notes(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
        model.delete(.note(.mock(0)))
        XCTAssertFalse(model.notes(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_usage_removesRelationships() throws {
        var model = AppModel.mockConnected(usages: 0..<3, entries: 0..<10, created: .now)
        let topEntry = try XCTUnwrap(model.entries(.of(.usage(.mock(0)))).first)
        XCTAssert(model.usages(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
        model.delete(.usage(.mock(0)))
        XCTAssertFalse(model.usages(.of(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
    }
        
    func test_delete_connected_entryCollection_removesRelationships() throws {
        var model = AppModel.mockConnected(entryCollections: 0..<3, entries: 0..<10, created: .now)
        let topEntry = try XCTUnwrap(model.entries(.of(.entryCollection(.mock(0)))).first)
        XCTAssert(model.entryCollections(.thatContain(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
        model.delete(.entryCollection(.mock(0)))
        XCTAssertFalse(model.entryCollections(.thatContain(.entry(topEntry.id))).contains(where: { $0.id == .mock(0) }))
    }
        
    
}

