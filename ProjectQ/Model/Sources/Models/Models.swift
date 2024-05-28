
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Entry: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var spelling: String = ""
    var alternateSpellings: [String] = []

//    var diagram: Diagram = .init()
//    struct Diagram: Equatable, Codable, Sendable {
//        var sections: [ClosedRange<Int>: Section] = [:]
//        struct Section: Equatable, Codable, Sendable {
//            var title: String = ""
//            var accentMark: String = ""
//            var colorHex: String = ""
//        }
//    }
//    var review: Review = .init()
//    struct Review: Equatable, Codable, Sendable {
//        var lastReviewed: Date = .distantPast
//        var confidenceLevel: Int = 0
//        var ommitted: Bool = false
//    }
    var metadata: RepositoryMetadata = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var language: Language.ID?
        var root: UUID?
        var translations: [Entry.ID] = []
        var backTranslations: Set<Entry.ID> = []
        var other: [Entry.ID] = []
        var usages: [Usage.ID] = []
        var keywords: Set<Keyword.ID> = []
        var notes: [Note.ID] = []
        var userCollections: Set<UserCollection.ID> = []
//        var recordings: [Recording.ID] = []
    }
    public struct View: Identifiable, Equatable, Codable, Sendable {
        public let id: UUID
        public let spelling: String
        public let alternateSpellings: [String]
        public let metadata: RepositoryMetadata
        public let language: Language
        public let root: Entry?
        public let translations: [Entry]
        public let backTranslations: [Entry]
        public let other: [Entry]
        public let usages: [Usage]
        public let keywords: [Keyword]
        public let notes: [Note]
        public let userCollections: [UserCollection]
//        var recordings: [Recording]
    }
}

@ObservableState
public struct Usage: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var value: String = ""
    var metadata: RepositoryMetadata = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var note: Note? = nil
        var uses: Set<Entry.ID> = []
    }
    public struct View: Identifiable, Equatable, Codable, Sendable {
        public let id: UUID
        public let value: String
        public let metadata: RepositoryMetadata
        public let note: Note?
        public let uses: [Entry]
    }
}

@ObservableState
public struct Language: Identifiable, Equatable, Codable, Sendable {
    public let id: ID
    public enum ID: Identifiable, Hashable, Codable, Sendable {
        public var id: String {
            switch self {
            case .bcp47(let code): return code
            }
        }
        case bcp47(String)
    }
    var customLocalizedTitles: [String: String] = [:]
    var metadata: RepositoryMetadata = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var entries: Set<Entry.ID> = []
        var usages: Set<Usage.ID> = []
    }
    public struct View: Identifiable, Equatable, Codable, Sendable {
        public let id: Language.ID
        public let customLocalizedTitles: [String: String]
        public let metadata: RepositoryMetadata
        public let entries: [Entry]
        public let usages: [Usage]
    }
}

@ObservableState
public struct Keyword: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var title: String = ""
    var metadata: RepositoryMetadata = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var matches: [Entry.ID] = []
    }
    public struct View: Identifiable, Equatable, Codable, Sendable {
        public let id: UUID
        public let title: String
        public let metadata: RepositoryMetadata
        public let matches: [Entry]
    }
}

@ObservableState
public struct Note: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var value: String = ""
    var metadata: RepositoryMetadata = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var entry: Entry.ID?
    }
    public struct View: Identifiable, Equatable, Codable, Sendable {
        public let id: UUID
        public let value: String
        public let metadata: RepositoryMetadata
        public let entry: Entry?
    }
}

//@ObservableState
//struct Recording: Identifiable, Equatable, Codable, Sendable {
//    public let id: UUID
//    var fileLocation: URL
//    var metadata: RepositoryMetadata = .init()
//    fileprivate struct Relationships: Equatable, Codable, Sendable {
//    }
//    struct View: Identifiable, Equatable, Codable, Sendable {
//        public let id: UUID
//        let fileLocation: URL
//        let metadata: RepositoryMetadata
//    }
//}

@ObservableState
public struct UserCollection: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var title: String
    var metadata: RepositoryMetadata = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var entries: [Entry.ID] = []
    }
    public struct View: Identifiable, Equatable, Codable, Sendable {
        public let id: UUID
        public let title: String
        public let metadata: RepositoryMetadata
        public let entries: [Entry]
    }
}

@ObservableState
public struct RepositoryMetadata: Equatable, Codable, Sendable {
    init() {
        @Dependency(\.date) var date
        let now = date.now
        self.added = now
        self.modified = now
    }
    
    let added: Date
    var modified: Date
}


// Storage:
public struct Repository: Equatable, Codable, Sendable {
    public init() {}
    fileprivate var stored: Stored = .init()
    fileprivate struct Stored: Equatable, Codable, Sendable {
        var entries: Storage<Entry> = .init()
        var usages: Storage<Usage> = .init()
        var languages: Storage<Language> = .init()
        var keywords: Storage<Keyword> = .init()
        var notes: Storage<Note> = .init()
        var userCollections: Storage<UserCollection> = .init()
    }
    fileprivate var relationships: Relationships = .init()
    fileprivate struct Relationships: Equatable, Codable, Sendable {
        var entries: [Entry.ID: Entry.Relationships] = [:]
        var usages: [Usage.ID: Usage.Relationships] = [:]
        var languages: [Language.ID: Language.Relationships] = [:]
        var keywords: [Keyword.ID: Keyword.Relationships] = [:]
        var notes: [Note.ID: Note.Relationships] = [:]
        var userCollections: [UserCollection.ID: UserCollection.Relationships] = [:]
    }
}

// Read:
extension Shared<Repository> {

    func entryViews(of ids: [Entry.ID]) -> IdentifiedArrayOf<Entry.View> {
        var result: IdentifiedArrayOf<Entry.View> = []
        ids.forEach { id in
            result[id: id] = createEntryView(of: id)
        }
        return result
    }

    func createEntryView(of id: Entry.ID) -> Entry.View? {
        nil
//        guard let entry = projectedValue.stored.entries[id: id] else { return nil }
//        let relationships = wrappedValue.relationships.entries[id, default: .init()]
//        let language = relationships.language projectedValue.stored.languages[id: ]
//        let root = projectedValue.stored.entries[id: entry.root]
//        let translations
//        let backTranslations
//        let other
//        let usages
//        let keywords
//        let notes
//        let userCollections
    }
    
}

// Write:
extension Repository {
    
    func insert(newEntry: Entry) throws {
                
//        @Dependency(\.date) var date
//
//        let now = date.now
//
//        let newEntry = Entry(
//            added: now,
//            modified: now,
//            spelling: spelling
//        )
//
//        insert(newEntry)
//
//        try save()
//
//        return newEntry
        
    }
    
}

typealias Entries = LookupStorage<Entry>

protocol LookupStorage<Value> {
    associatedtype Value: Identifiable
    init()
    subscript(id id: Value.ID) -> Value? { get set }
    func values(predicate: (Value) -> Bool, sort: (Value, Value) -> Bool) -> [Value]
}

struct Storage<Value: Identifiable & Equatable & Codable & Sendable>: Equatable, Codable, Sendable, LookupStorage where Value.ID: Hashable & Codable & Sendable {
    init() {}
    fileprivate var _storage: [Value.ID: Value] = [:]
    fileprivate init(_storage: [Value.ID : Value] = [:]) {
        self._storage = _storage
    }
    subscript(id id: Value.ID) -> Value? {
        _read { yield self._storage[id] }
        set {
            if let newValue {
                self._storage.updateValue(newValue, forKey: id)
            } else {
                self._storage.removeValue(forKey: id)
            }
        }
        _modify {
            yield &self._storage[id]
        }
    }
    func values(predicate isIncluded: (Value) -> Bool, sort comparator: (Value, Value) -> Bool) -> [Value] {
        _storage.values.filter(isIncluded).sorted(by: comparator)
    }
}

extension Shared where Value: LookupStorage {
    
    func sharedElements<T: Comparable>(
        filteredBy predicate: (Value.Value) -> Bool = { _ in true },
        sortedBy keyPath: KeyPath<Value.Value, T>,
        reversed: Bool = false
    ) -> IdentifiedArrayOf<Shared<Value.Value>> {
        var result: IdentifiedArrayOf<Shared<Value.Value>> = []
        var sortedElements = wrappedValue.values(predicate: predicate, sort: {
            if reversed {
                $0[keyPath: keyPath] > $1[keyPath: keyPath]
            } else {
                $0[keyPath: keyPath] < $1[keyPath: keyPath]
            }
        })
        for element in sortedElements {
            result[id: element.id] = projectedValue[id: element.id]
        }
        return result
    }
    
}

extension Shared<Repository> {
    
    func entriesMatching(spelling: String) -> [Shared<Entry>] {
        []
//        guard let entry = wrappedValue._storage.values.first(where: { $0.spelling == spelling }) else { return .none }
//        return projectedValue[id: entry.id]
    }
    
//    @discardableResult
//    mutating func add(new: Entry) -> Shared<Entry> {
//        precondition(!new.spelling.isEmpty, "attempted to add an entry with an empty spelling. This is not intended behavior.")
//        @Dependency(\.date) var date
//        precondition(wrappedValue._storage[new.id] == .none, "Attempted to overwrite an entry via the .add(new:) endpoint. This is not expected behavior.")
//        wrappedValue._storage[new.id] = new
//        return projectedValue[id: new.id]!
//    }
    
    mutating func establishTranslationConnectionBetween(_ entry: Shared<Entry>, and translation: Shared<Entry>) {
//        removeTranslationConnectionBetween(entry, and: translation)
//        entry.wrappedValue.translations.append(translation.id)
//        translation.wrappedValue.translations.append(entry.id)
    }
    
    mutating func removeTranslationConnectionBetween(_ entry: Shared<Entry>, and translation: Shared<Entry>) {
//        entry.wrappedValue.translations.removeAll(where: { $0 == translation.id })
//        translation.wrappedValue.translations.removeAll(where: { $0 == entry.id })
    }

    // should remove any stale ids from remaining entry connection lists
    mutating func remove(entry: Entry) {
//        precondition(_storage[entry.id] != .none, "Attempted to remove an entry via the .remove(entry:) endpoint that was not found. This is not expected behavior.")
//        _storage[entry.id] = .none
//        _storage.forEach { (id, _) in
//            _storage[id]!.translations.removeAll(where: { $0 == entry.id })
////            _storage[id]!.related.removeAll(where: { $0 == entry.id })
//        }
    }

    func entriesUsing(language: Language.ID) -> Int {
        0
    }
    
}

extension Entries {
//    var sortedLocaleCounts: [(locale: Locale, wordCount: Int)] {
//        _storage.values.reduce(into: [:], { $0[$1.locale, default: 0] += 1 }).sorted(by: \.value).map({ (locale: $0.key, wordCount: $0.value) })
//    }

}

extension Entries {
    static func mock(count: Int = 10) -> Self {
        .init()
//        .init(_storage: .mock(count: count))
    }
    static func mock(all: [Entry]) -> Self {
        .init()
//        .init(_storage: .mock(all: all))
    }
}

private extension Dictionary<UUID, Entry> {
    static func mock(locale: Locale = .current, count: Int, added: (Int) -> Date = { _ in .now }) -> Self {
        var result = [UUID: Entry]()
        for id in (0..<count).map({UUID($0)}) {
            result[id] = .init(id: id, spelling: "Mock Word \(id.uuidString.suffix(3))")
        }
        return result
    }
    static func mock(all: [Entry]) -> Self {
        var result = [UUID: Entry]()
        for entry in all {
            result[entry.id] = entry
        }
        return result
    }
}
