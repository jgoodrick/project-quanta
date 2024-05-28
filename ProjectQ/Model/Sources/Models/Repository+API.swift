
import ComposableArchitecture
import Foundation

public enum Operation {
    case add
    case remove
}

@DependencyClient
public struct Entries: TestDependencyKey {
    public static var testValue: Self = .init()
    var individual: (Operation, Entry) async throws -> Void
    var setLanguage: (_ for: Entry, _ to: Language) async throws -> Void
    var translations: (_ for: Entry, Operation, _ translation: Entry) async throws -> Void
    var moveTranslations: (_ fromOffsets: IndexSet, _ toOffset: Int) async throws -> Void
    var keywords: (_ for: Entry, Operation, _ keyword: Keyword) async throws -> Void
    var moveKeywords: (_ fromOffsets: IndexSet, _ toOffset: Int) async throws -> Void
    var notes: (_ for: Entry, Operation, _ note: Note) async throws -> Void
    var moveNotes: (_ fromOffsets: IndexSet, _ toOffset: Int) async throws -> Void
    var usages: (_ for: Entry, Operation, _ usage: Usage) async throws -> Void
    var moveUsages: (_ fromOffsets: IndexSet, _ toOffset: Int) async throws -> Void
}

@DependencyClient
public struct Keywords: TestDependencyKey {
    public static var testValue: Self = .init()
    var individual: (Operation, Keyword) async throws -> Void
}

@DependencyClient
public struct Languages: TestDependencyKey {
    public static var testValue: Self = .init()
    var individual: (Operation, Language) async throws -> Void
}

@DependencyClient
public struct Notes: TestDependencyKey {
    public static var testValue: Self = .init()
    var individual: (Operation, Note) async throws -> Void
}

@DependencyClient
public struct Usages: TestDependencyKey {
    public static var testValue: Self = .init()
    var individual: (Operation, Usage) async throws -> Void
}

@DependencyClient
public struct UserCollections: TestDependencyKey {
    public static var testValue: Self = .init()
    var individual: (Operation, UserCollection) async throws -> Void
    var entries: (_ for: UserCollection, Operation, _ entry: Entry) async throws -> Void
    var moveEntries: (_ fromOffsets: IndexSet, _ toOffset: Int) async throws -> Void
}

