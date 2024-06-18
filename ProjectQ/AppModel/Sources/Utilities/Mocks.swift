
import ComposableArchitecture
import Foundation
import StructuralModel
import RelationalModel

extension AppModel {
    public static func mock(entries: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mock(entries: entries, created: created)))
    }
    
    public static func mockConnected(entries: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mockConnected(entries: entries, created: created)))
    }
    
    public static func mock(languages: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mock(languages: languages, created: created)))
    }

    public static func mockConnected(languages range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mockConnected(languages: range, entries: eRange, created: created)))
    }

    public static func mock(keywords: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mock(keywords: keywords, created: created)))
    }
    
    public static func mockConnected(keywords range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mockConnected(keywords: range, entries: eRange, created: created)))
    }

    public static func mock(notes: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mock(notes: notes, created: created)))
    }
    
    public static func mockConnected(notes range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mockConnected(notes: range, entries: eRange, created: created)))
    }

    public static func mock(usages: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mock(usages: usages, created: created)))
    }
    
    public static func mockConnected(usages range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mockConnected(usages: range, entries: eRange, created: created)))
    }

    public static func mock(entryCollections: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mock(entryCollections: entryCollections, created: created)))
    }
    
    public static func mockConnected(entryCollections range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        Self.init(db: Shared(Database.mockConnected(entryCollections: range, entries: eRange, created: created)))
    }

}
