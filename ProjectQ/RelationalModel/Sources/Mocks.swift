
import Foundation
import StructuralModel

extension Database {
    public static func mock(entries: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        entries.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        return result
    }
    
    public static func mockConnected(entries: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        entries.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        let ids = entries.map({ Entry.ID.mock($0) })
        ids.forEach { translation in
            ids.forEach { target in
                result.connect(translation: translation, toEntry: target)
            }
        }
        return result
    }
    
    public static func mock(languages: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        languages.forEach {
            result.create(.language(.mock($0)), now: created)
        }
        return result
    }

    public static func mockConnected(languages range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        let languages = range.map(Language.mock)
        languages.forEach {
            result.create(.language($0), now: created)
        }
        eRange.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        languages.forEach { language in
            eRange.forEach { entry in
                result.connect(language: language.id, toEntry: .mock(entry))
            }
        }
        return result
    }

    public static func mock(keywords: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        keywords.forEach {
            result.create(.keyword(.init(id: .mock($0), title: "\($0)")), now: created)
        }
        return result
    }
    
    public static func mockConnected(keywords range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        let keywords = range.map({
            Keyword.init(id: .mock($0), title: "\($0)")
        })
        keywords.forEach {
            result.create(.keyword($0), now: created)
        }
        eRange.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        keywords.forEach { keyword in
            eRange.forEach { entry in
                result.connect(keyword: keyword.id, toEntry: .mock(entry))
            }
        }
        return result
    }

    public static func mock(notes: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        notes.forEach {
            result.create(.note(.init(id: .mock($0), value: "\($0)")), now: created)
        }
        return result
    }
    
    public static func mockConnected(notes range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        let notes = range.map({
            Note.init(id: .mock($0), value: "\($0)")
        })
        notes.forEach {
            result.create(.note($0), now: created)
        }
        eRange.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        notes.forEach { note in
            eRange.forEach { entry in
                result.connect(note: note.id, toEntry: .mock(entry))
            }
        }
        return result
    }

    public static func mock(usages: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        usages.forEach {
            result.create(.usage(.init(id: .mock($0), value: "\($0)")), now: created)
        }
        return result
    }
    
    public static func mockConnected(usages range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        let usages = range.map({
            Usage.init(id: .mock($0), value: "\($0)")
        })
        usages.forEach {
            result.create(.usage($0), now: created)
        }
        eRange.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        usages.forEach { usage in
            eRange.forEach { entry in
                result.connect(usage: usage.id, toEntry: .mock(entry))
            }
        }
        return result
    }

    public static func mock(entryCollections: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        entryCollections.forEach {
            result.create(.entryCollection(.init(id: .mock($0), title: "\($0)")), now: created)
        }
        return result
    }
    
    public static func mockConnected(entryCollections range: Range<Int>, entries eRange: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        let entryCollections = range.map({
            EntryCollection.init(id: .mock($0))
        })
        entryCollections.forEach {
            result.create(.entryCollection($0), now: created)
        }
        eRange.forEach {
            result.create(.entry(.init(id: .mock($0), spelling: "\($0)")), now: created)
        }
        entryCollections.forEach { entryCollection in
            eRange.forEach { entry in
                result.connect(entry: .mock(entry), toCollection: entryCollection.id)
            }
        }
        return result
    }

}

extension Language {
    public static func mock(_ int: Int) -> Self {
        try! .init(bcp47: "en_US_\(int)")
    }
}
extension Language.ID {
    public static func mock(_ int: Int) -> Language.ID {
        Language.mock(int).id
    }
}

