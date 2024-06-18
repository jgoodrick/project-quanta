
import Foundation // IndexSet
import StructuralModel

/**
 AppModel.Intents
 */
extension AppModel {
    
    public mutating func createNewEntry(language: Language? = nil, builder: (inout Entry) -> Void) -> Entry {
        var new = Entry(id: .tagged(uuid()))
        builder(&new)
        precondition(!new.spelling.isEmpty)
        db.create(.entry(new), now: date.now)
        if let language {
            db.connect(language: language.id, toEntry: new.id)
        }
        return new
    }
    
    public mutating func createNewKeyword(builder: (inout Keyword) -> Void) -> Keyword {
        var new = Keyword(id: .tagged(uuid()))
        builder(&new)
        precondition(!new.title.isEmpty)
        db.create(.keyword(new), now: date.now)
        return new
    }
    
    public mutating func createNewNote(builder: (inout Note) -> Void = { _ in }) -> Note {
        var new = Note(id: .tagged(uuid()))
        builder(&new)
        db.create(.note(new), now: date.now)
        return new
    }
    
    public mutating func createNewUsage(language: Language? = nil, builder: (inout Usage) -> Void) -> Usage {
        var new = Usage(id: .tagged(uuid()))
        builder(&new)
        precondition(!new.value.isEmpty)
        db.create(.usage(new), now: date.now)
        if let language {
            db.connect(language: language.id, toUsage: new.id)
        }
        return new
    }
    
    public mutating func createNewEntryCollection(builder: (inout EntryCollection) -> Void) -> EntryCollection {
        var new = EntryCollection(id: .tagged(uuid()))
        builder(&new)
        precondition(!new.title.isEmpty)
        db.create(.entryCollection(new), now: date.now)
        return new
    }
    
    public mutating func ensureExistenceOf(language: Language) {
        guard db[language: language.id] != nil else {
            db.create(.language(language), now: date.now)
            return
        }
    }
    
    public func displayName(for language: Language) -> String {
        // we only want to show the additional (region) information if the primary language is not unique
        var copy = settings.languageSelectionList
        copy.removeAll(where: { $0.id == language.id })
        if copy.contains(where: { $0.primaryLanguage == language.primaryLanguage }) {
            return locale.localizedString(forIdentifier: language.bcp47.rawValue) ?? language.id.rawValue
        } else {
            return language.primaryLanguage.flatMap({ locale.localizedString(forLanguageCode: $0) }) ?? language.id.rawValue
        }
    }
    
    
    
    
    public enum ConflictDecision<Entity> {
        case useExisting(Entity)
        case createNew
    }
    
    public typealias DeferredUserDecision<Entity> = ([Entity]) async throws -> ConflictDecision<Entity>
    
    @discardableResult
    public mutating func addNewTranslation(
        fromSpelling spelling: String,
        forEntry translated: Entry.ID,
        ifTranslationSpellingIsNotUnique userDecision: DeferredUserDecision<Entry>
    ) async rethrows -> Entry {
        let translation: Entry
        let matches = db.entries(where: { $0.spelling == spelling })
        if !matches.isEmpty {
            switch try await userDecision(matches) {
            case .useExisting(let existing):
                translation = existing
            case .createNew:
                translation = createNewEntry {
                    $0.spelling = spelling
                }
            }
        } else {
            translation = createNewEntry {
                $0.spelling = spelling
            }
        }
        addExisting(translation: translation.id, toEntry: translated)
        return translation
    }
    
    public mutating func addExisting(translation: Entry.ID, toEntry translated: Entry.ID, bidirectional: Bool = true) {
        db.connect(
            translation: translation,
            toEntry: translated,
            bidirectional: bidirectional
        )
    }
    
    @discardableResult
    public mutating func addNewKeyword(
        title: String,
        toEntry referenced: Entry.ID,
        ifKeywordTitleIsNotUnique userDecision: DeferredUserDecision<Keyword>
    ) async rethrows -> Keyword {
        let keyword: Keyword
        let matches = db.keywords(where: { $0.title == title })
        if !matches.isEmpty {
            switch try await userDecision(matches) {
            case .useExisting(let existing):
                keyword = existing
            case .createNew:
                keyword = createNewKeyword {
                    $0.title = title
                }
            }
        } else {
            keyword = createNewKeyword {
                $0.title = title
            }
        }
        addExisting(keyword: keyword.id, toEntry: referenced)
        return keyword
    }
    
    public mutating func addExisting(keyword: Keyword.ID, toEntry entry: Entry.ID) {
        db.connect(keyword: keyword, toEntry: entry)
    }
    
    
    @discardableResult
    public mutating func addNewNote(
        content value: String,
        toEntry referenced: Entry.ID
    ) -> Note {
        let note = createNewNote {
            $0.value = value
        }
        addExisting(note: note.id, toEntry: referenced)
        return note
    }
    
    public mutating func addExisting(note: Note.ID, toEntry entry: Entry.ID) {
        db.connect(note: note, toEntry: entry)
    }
    
    @discardableResult
    public mutating func addNewNote(
        content value: String,
        toUsage referenced: Usage.ID
    ) -> Note {
        let note = createNewNote {
            $0.value = value
        }
        addExisting(note: note.id, toUsage: referenced)
        return note
    }
    
    public mutating func addExisting(note: Note.ID, toUsage usage: Usage.ID) {
        db.connect(note: note, toUsage: usage)
    }
    
    @discardableResult
    public mutating func addNewUsage(
        content value: String,
        toEntry referenced: Entry.ID,
        ifUsageTitleIsNotUnique userDecision: DeferredUserDecision<Usage>
    ) async rethrows -> Usage {
        let usage: Usage
        let matches = db.usages(where: { $0.value == value })
        if !matches.isEmpty {
            switch try await userDecision(matches) {
            case .useExisting(let existing):
                usage = existing
            case .createNew:
                usage = createNewUsage {
                    $0.value = value
                }
            }
        } else {
            usage = createNewUsage {
                $0.value = value
            }
        }
        addExisting(usage: usage.id, toEntry: referenced)
        return usage
    }
    
    public mutating func addExisting(usage: Usage.ID, toEntry entry: Entry.ID) {
        db.connect(usage: usage, toEntry: entry)
    }
    
    @discardableResult
    public mutating func addNewEntry(
        spelling: String,
        toEntryCollection collection: EntryCollection.ID,
        atOffset: Int? = nil,
        ifSpellingIsNotUnique userDecision: DeferredUserDecision<Entry>
    ) async rethrows -> Entry {
        let entry: Entry
        let matches = db.entries(where: { $0.spelling == spelling })
        if !matches.isEmpty {
            switch try await userDecision(matches) {
            case .useExisting(let existing):
                entry = existing
            case .createNew:
                entry = createNewEntry {
                    $0.spelling = spelling
                }
            }
        } else {
            entry = createNewEntry {
                $0.spelling = spelling
            }
        }
        addExisting(entry: entry.id, toEntryCollection: collection, atOffset: atOffset)
        return entry
    }
    
    public mutating func addExisting(entry: Entry.ID, toEntryCollection entryCollection: EntryCollection.ID, atOffset: Int? = nil) {
        db.connect(entry: entry, toCollection: entryCollection, atOffset: atOffset)
    }
    
    public mutating func addExisting(language: Language.ID, toEntry entry: Entry.ID) {
        db.connect(language: language, toEntry: entry)
    }
    
    public mutating func addExisting(language: Language.ID, toUsage usage: Usage.ID) {
        db.connect(language: language, toUsage: usage)
    }
    
    @discardableResult
    public mutating func addNewRoot(
        fromSpelling spelling: String,
        toEntry derived: Entry.ID,
        ifRootSpellingIsNotUnique userDecision: DeferredUserDecision<Entry>
    ) async rethrows -> Entry {
        let root: Entry
        let matches = db.entries(where: { $0.spelling == spelling })
        if !matches.isEmpty {
            switch try await userDecision(matches) {
            case .useExisting(let existing):
                root = existing
            case .createNew:
                root = createNewEntry {
                    $0.spelling = spelling
                }
            }
        } else {
            root = createNewEntry {
                $0.spelling = spelling
            }
        }
        addExisting(root: root.id, toEntry: derived)
        return root
    }
    
    public mutating func addExisting(root: Entry.ID, toEntry entry: Entry.ID) {
        db.connect(root: root, toEntry: entry)
    }
    
    @discardableResult
    public mutating func addNewSeeAlso(
        spelling: String,
        toEntry target: Entry.ID,
        ifSeeAlsoSpellingIsNotUnique userDecision: DeferredUserDecision<Entry>
    ) async rethrows -> Entry {
        let seeAlso: Entry
        let matches = db.entries(where: { $0.spelling == spelling })
        if !matches.isEmpty {
            switch try await userDecision(matches) {
            case .useExisting(let existing):
                seeAlso = existing
            case .createNew:
                seeAlso = createNewEntry {
                    $0.spelling = spelling
                }
            }
        } else {
            seeAlso = createNewEntry {
                $0.spelling = spelling
            }
        }
        addExisting(seeAlso: seeAlso.id, toEntry: target)
        return seeAlso
    }
    
    public mutating func addExisting(seeAlso: Entry.ID, toEntry entry: Entry.ID) {
        db.connect(seeAlso: seeAlso, toEntry: entry)
    }
    
    
    
    
    fileprivate mutating func removeOrphan(_ entity: Entity.ID, if condition: Bool) {
        if condition, !db.containsRelationships(for: entity) {
            db.delete(entity)
        }
    }
    
    public mutating func remove(translation: Entry.ID, fromEntry translated: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(translation: translation, fromEntry: translated, bidirectional: true)
        removeOrphan(.entry(translation), if: deleteIfOrphaned)
    }
    
    public mutating func remove(keyword: Keyword.ID, fromEntry entry: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(keyword: keyword, fromEntry: entry)
        removeOrphan(.keyword(keyword), if: deleteIfOrphaned)
    }
    
    public mutating func remove(note: Note.ID, fromEntry entry: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(note: note, fromEntry: entry)
        removeOrphan(.note(note), if: deleteIfOrphaned)
    }
    
    public mutating func remove(note: Note.ID, fromUsage usage: Usage.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(note: note, fromUsage: usage)
        removeOrphan(.note(note), if: deleteIfOrphaned)
    }
    
    public mutating func remove(usage: Usage.ID, fromEntry entry: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(usage: usage, fromEntry: entry)
        removeOrphan(.usage(usage), if: deleteIfOrphaned)
    }
    
    public mutating func remove(entry: Entry.ID, fromEntryCollection entryCollection: EntryCollection.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(entry: entry, fromEntryCollection: entryCollection)
        removeOrphan(.entry(entry), if: deleteIfOrphaned)
    }
    
    public mutating func remove(language: Language.ID, fromEntry entry: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(language: language, fromEntry: entry)
        removeOrphan(.language(language), if: deleteIfOrphaned)
    }
    
    public mutating func remove(language: Language.ID, fromUsage usage: Usage.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(language: language, fromUsage: usage)
        removeOrphan(.language(language), if: deleteIfOrphaned)
    }
    
    public mutating func remove(root: Entry.ID, fromEntry entry: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(root: root, fromEntry: entry)
        removeOrphan(.entry(root), if: deleteIfOrphaned)
    }
    
    public mutating func remove(seeAlso: Entry.ID, fromEntry entry: Entry.ID, deleteIfOrphaned: Bool = false) {
        db.disconnect(seeAlso: seeAlso, fromEntry: entry)
        removeOrphan(.entry(seeAlso), if: deleteIfOrphaned)
    }
    

    
    public mutating func moveTranslations(on entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        db.moveTranslations(on: entry, fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveLanguages(onEntry entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        db.moveLanguages(onEntry: entry, fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveLanguages(onUsage usage: Usage.ID, fromOffsets: IndexSet, toOffset: Int) {
        db.moveLanguages(onUsage: usage, fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveNotes(on entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        db.moveNotes(on: entry, fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveUsages(on entry: Entry.ID, fromOffsets: IndexSet, toOffset: Int) {
        db.moveUsages(on: entry, fromOffsets: fromOffsets, toOffset: toOffset)
    }
    
    public mutating func moveEntries(in entryCollection: EntryCollection.ID, fromOffsets: IndexSet, toOffset: Int) {
        db.moveEntries(in: entryCollection, fromOffsets: fromOffsets, toOffset: toOffset)
    }

        
    public mutating func updateEntry<T>(_ keyPath: WritableKeyPath<Entry, T>, of entry: Entry.ID, to newValue: T) {
        guard var copy = db[entry: entry] else { preconditionFailure() }
        copy[keyPath: keyPath] = newValue
        db.update(.entry(copy))
    }

    public mutating func updateEntryCollection<T>(_ keyPath: WritableKeyPath<EntryCollection, T>, of entryCollection: EntryCollection.ID, to newValue: T) {
        guard var copy = db[entryCollection: entryCollection] else { preconditionFailure() }
        copy[keyPath: keyPath] = newValue
        db.update(.entryCollection(copy))
    }

    public mutating func updateKeyword<T>(_ keyPath: WritableKeyPath<Keyword, T>, of keyword: Keyword.ID, to newValue: T) {
        guard var copy = db[keyword: keyword] else { preconditionFailure() }
        copy[keyPath: keyPath] = newValue
        db.update(.keyword(copy))
    }

    public mutating func updateLanguage<T>(_ keyPath: WritableKeyPath<Language, T>, of language: Language.ID, to newValue: T) {
        guard var copy = db[language: language] else { preconditionFailure() }
        copy[keyPath: keyPath] = newValue
        db.update(.language(copy))
    }

    public mutating func updateNote<T>(_ keyPath: WritableKeyPath<Note, T>, of note: Note.ID, to newValue: T) {
        guard var copy = db[note: note] else { preconditionFailure() }
        copy[keyPath: keyPath] = newValue
        db.update(.note(copy))
    }

    public mutating func updateUsage<T>(_ keyPath: WritableKeyPath<Usage, T>, of usage: Usage.ID, to newValue: T) {
        guard var copy = db[usage: usage] else { preconditionFailure() }
        copy[keyPath: keyPath] = newValue
        db.update(.usage(copy))
    }


    
            
    public mutating func delete(_ entity: Entity.ID) {
        db.delete(entity)
    }


}
