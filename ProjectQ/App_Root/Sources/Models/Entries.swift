
import ComposableArchitecture
import Foundation

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Entries>> {
    public static var entries: Self {
        PersistenceKeyDefault(
            FileStorageKey.fileStorage(URL.documentsDirectory.appending(component: "entries.json")),
            .init()
        )
    }
}

public struct Entries: Equatable, Codable, Sendable {
    public init() {}
    fileprivate var _storage: [Entry.ID: Entry] = [:]
    fileprivate init(_storage: [Entry.ID : Entry] = [:]) {
        self._storage = _storage
    }
    public subscript(id id: Entry.ID) -> Entry? {
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
    var sortedLocaleCounts: [(locale: Locale, wordCount: Int)] {
        _storage.values.reduce(into: [:], { $0[$1.locale, default: 0] += 1 }).sorted(by: \.value).map({ (locale: $0.key, wordCount: $0.value) })
    }
}

extension Shared<Entries> {
    
    public var sharedElements: IdentifiedArrayOf<Shared<Entry>> {
        sharedElementsSorted(by: \.lastModified, reversed: true)
    }
    
    public func sharedElementsSorted<T: Comparable>(
        by keyPath: KeyPath<Entry, T>,
        reversed: Bool = false
    ) -> IdentifiedArrayOf<Shared<Entry>> {
        var result: IdentifiedArrayOf<Shared<Entry>> = []
        let sortedEntries = wrappedValue._storage.values.sorted(byKeyPath: keyPath, reversed: reversed)
        for entry in sortedEntries {
            result[id: entry.id] = projectedValue[id: entry.id]
        }
        return result
    }
    
    public func matching(spelling: String) -> Shared<Entry>? {
        guard let entry = wrappedValue._storage.values.first(where: { $0.spelling == spelling }) else { return .none }
        return projectedValue[id: entry.id]
    }
    
    @discardableResult
    public mutating func add(new: Entry) -> Shared<Entry> {
        precondition(!new.spelling.isEmpty, "attempted to add an entry with an empty spelling. This is not intended behavior.")
        @Dependency(\.date) var date
        precondition(wrappedValue._storage[new.id] == .none, "Attempted to overwrite an entry via the .add(new:) endpoint. This is not expected behavior.")
        wrappedValue._storage[new.id] = new
        return projectedValue[id: new.id]!
    }
    
    public mutating func establishTranslationConnectionBetween(_ entry: Shared<Entry>, and translation: Shared<Entry>) {
        removeTranslationConnectionBetween(entry, and: translation)
        entry.wrappedValue.translations.append(translation.id)
        translation.wrappedValue.translations.append(entry.id)
    }
    
    public mutating func removeTranslationConnectionBetween(_ entry: Shared<Entry>, and translation: Shared<Entry>) {
        entry.wrappedValue.translations.removeAll(where: { $0 == translation.id })
        translation.wrappedValue.translations.removeAll(where: { $0 == entry.id })
    }
    
}

extension Entries {
    public func sorted<T: Comparable>(
        by keyPath: KeyPath<Entry, T>,
        reversed: Bool = false
    ) -> IdentifiedArrayOf<Entry> {
        IdentifiedArrayOf<Entry>.init(
            uncheckedUniqueElements: _storage.values.sorted(
                byKeyPath: keyPath,
                reversed: reversed
            )
        )
    }
    
    // should remove any stale ids from remaining entry connection lists
    public mutating func remove(entry: Entry) {
        precondition(_storage[entry.id] != .none, "Attempted to remove an entry via the .remove(entry:) endpoint that was not found. This is not expected behavior.")
        _storage[entry.id] = .none
        _storage.forEach { (id, _) in
            _storage[id]!.translations.removeAll(where: { $0 == entry.id })
//            _storage[id]!.related.removeAll(where: { $0 == entry.id })
        }
    }
}

extension Entries {
    public static func mock(count: Int = 10) -> Self {
        .init(_storage: .mock(count: count))
    }
    public static func mock(all: [Entry]) -> Self {
        .init(_storage: .mock(all: all))
    }
}

private extension Dictionary<Entry.ID, Entry> {
    static func mock(locale: Locale = .current, count: Int, added: (Int) -> Date = { _ in .now }) -> Self {
        var result = [Entry.ID: Entry]()
        for i in 0..<count {
            var entry = Entry.mock(id: i, locale: locale, spelling: "Mock Word \(i)")
            entry.translations.append(contentsOf: result.keys.reduce([], { Bool.random() ? $0 + [$1] : $0 }))
            result[entry.id] = entry
        }
        return result
    }
    static func mock(all: [Entry]) -> Self {
        var result = [Entry.ID: Entry]()
        for entry in all {
            result[entry.id] = entry
        }
        return result
    }
}
