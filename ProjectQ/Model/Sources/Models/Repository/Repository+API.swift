
import ComposableArchitecture
import Foundation
import OSLog

extension Repository {
    
    public enum AdditionOption {
        case enableOverwrite
        case requireEntriesToBeAddedExplicitly
        case unidirectionalTranslations
    }

    public enum EditOption {
        case ignoreMissingValues
        case deleteOrphans
        case unidirectionalTranslations
    }
    
    var log: Logger {
        @Dependency(\.logger["Repository"]) var logger
        return logger
    }
    
    public struct Failure: Error {
        init(_ description: String) { self.description = description }
        public let description: String
    }
    
    func existing(_ entry: Entry, given: Set<EditOption>) -> Bool {
        stored.entries[entry.id] == nil &&
        !given.contains(.ignoreMissingValues)
    }

    public mutating func add(entry: Entry, options: Set<AdditionOption> = []) throws {
        if !options.contains(.enableOverwrite), stored.entries[entry.id] != nil {
            throw Failure("Attempted to overwrite an existing value \(entry.id.short)")
        } else {
            stored.entries[entry.id] = entry
        }
    }
    
    public mutating func remove(entry: Entry, options: Set<EditOption> = []) throws {
        guard existing(entry, given: options) else {
            throw Failure("Attempted to remove an entry not found in the repository \(entry.id.short)")
        }
        stored.entries[entry.id] = nil
    }
    
    public mutating func update(language: Language, for entry: Entry, editing: Set<EditOption> = [], adding: Set<AdditionOption> = []) throws {
        if stored.languages[language.id] == nil {
            guard !adding.contains(.requireEntriesToBeAddedExplicitly) else {
                throw Failure("Attempted to update the language (id: \(language.id.short)) for entry id: \(entry.id.short), before the language was added to the repository")
            }
            try add(language: language, options: adding)
        }
        guard existing(entry, given: editing) else {
            throw Failure("Attempted to update the language (id: \(language.id.short)) for entry id: \(entry.id.short), but the entry was not found in the repository")
        }
        relationships.setLanguage(of: entry.id, toLanguage: language.id)
    }
    
    public mutating func add(translation: Entry, to translated: Entry, options: Set<AdditionOption> = []) throws {
        if stored.entries[translated.id] == nil {
            guard !options.contains(.requireEntriesToBeAddedExplicitly) else {
                throw Failure("Attempted to add translation id: \(translation.id.short) to entry id: \(translated.id.short), but the entry was not found in the repository")
            }
            try add(entry: translated, options: options)
        } else if stored.entries[translation.id] == nil {
            guard !options.contains(.requireEntriesToBeAddedExplicitly) else {
                throw Failure("Attempted to add translation id \(translation.id.short) to entry id \(translated.id.short) before the translation had been added to the repository")
            }
            try add(entry: translation, options: options)
        }
        relationships.add(translation: translation.id, toEntry: translated.id, bidirectional: !options.contains(.unidirectionalTranslations))
    }
    
    public mutating func remove(translation: Entry, from translated: Entry, options: Set<EditOption> = []) throws {
        guard !(stored.entries[translated.id] == nil && !options.contains(.ignoreMissingValues)) else {
            throw Failure("Attempted to remove translation id \(translation.id.short) from entry id \(translated.id.short), but entry was not found in the repository")
        }
        guard !(stored.entries[translation.id] == nil && !options.contains(.ignoreMissingValues)) else {
            throw Failure("Attempted to remove translation id \(translation.id.short) from entry id \(translated.id.short), but translation was not found in the repository")
        }
        relationships.disconnect(translation: translation.id, fromEntry: translated.id, bidirectional: !options.contains(.unidirectionalTranslations))
    }
    
    public mutating func moveTranslations(on entry: Entry, _ fromOffsets: IndexSet, _ toOffset: Int, options: Set<EditOption>) throws {
        guard !(stored.entries[entry.id] == nil && !options.contains(.ignoreMissingValues)) else {
            throw Failure("Attempted to move translations on entry id \(entry.id.short), but entry was not found in the repository")
        }
        relationships.entries[entry.id]?.translations.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func add(language: Language, options: Set<AdditionOption> = []) throws {
        
    }
    
    public mutating func remove(language: Language, options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func moveLanguages(_ fromOffsets: IndexSet, _ toOffset: Int) throws {
        
    }
    
    public mutating func add(keywords: [Keyword], to: Entry) throws {
        
    }
    
    public mutating func remove(keywords: [Keyword], from: Entry, options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func moveKeywords(on: Entry, _ fromOffsets: IndexSet, _ toOffset: Int) throws {
        
    }
    
    public mutating func add(notes: [Note], to: Entry) throws {
        
    }
    
    public mutating func remove(notes: [Note], from: Entry, options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func moveNotes(on: Entry, _ fromOffsets: IndexSet, _ toOffset: Int) throws {
        
    }
    
    public mutating func add(usages: [Usage], to: Entry) throws {
        
    }
    
    public mutating func remove(usages: [Usage], from: Entry, options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func moveEntryUsages(on: Entry, _ fromOffsets: IndexSet, _ toOffset: Int) throws {
        
    }
    
    public mutating func add(keywords: [Keyword]) throws {
        
    }
    
    public mutating func remove(keywords: [Keyword], options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func add(notes: [Note]) throws {
        
    }
    
    public mutating func remove(notes: [Note], options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func add(usages: [Usage]) throws {
        
    }
    
    public mutating func remove(usages: [Usage], options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func add(userCollections: [UserCollection]) throws {
        
    }
    
    public mutating func remove(userCollections: [UserCollection], options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func addEntries(to: UserCollection, _ atOffset: Int, _ entries: [Entry]) throws {
        
    }
    
    public mutating func removeEntries(from: UserCollection, _ entries: [Entry], options: Set<EditOption> = []) throws {
        
    }
    
    public mutating func moveUserCollectionEntries(_ for: UserCollection, _ fromOffsets: IndexSet, _ toOffset: Int) throws {
        
    }
}

extension UUID {
    var short: String { String(uuidString.suffix(3)) }
}
extension Language.ID {
    var short: String { switch self { case .bcp47(let value): return value } }
}
