
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
    
    public var displayNameForDefaultNewEntryLanguage: String {
        displayName(for: settings.defaultNewEntryLanguage)
    }
    
    
    
    public enum NewValueAddAttemptResult<Value> {
        case canceled
        case success(Value)
        case conflicts([Value])
    }
    
    public enum AutoConflictResolution {
        case cancel
        case useFirstMatch
        case createNew
    }
    
    public mutating func addNewEntry(
        fromSpelling spelling: String,
        in language: Language.ID? = nil,
        spellingConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Entry> {
        let entry: Entry
        let matches = db.entries(where: { $0.spelling == spelling })
        if let firstMatch = matches.first {
            switch spellingConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .useFirstMatch:
                entry = firstMatch
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
        addExisting(language: language ?? settings.defaultNewEntryLanguage.id, toEntry: entry.id)
        return .success(entry)
    }
    
    public mutating func addNewTranslation(
        fromSpelling spelling: String,
        in language: Language.ID? = nil,
        forEntry translated: Entry.ID,
        spellingConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Entry> {
        let result = addNewEntry(fromSpelling: spelling, in: language, spellingConflictResolution: spellingConflictResolution)
        if case .success(let translation) = result {
            addExisting(language: language ?? settings.defaultTranslationLanguage.id, toEntry: translation.id)
            addExisting(translation: translation.id, toEntry: translated)
        }
        return result
    }
    
    public mutating func addExisting(translation: Entry.ID, toEntry translated: Entry.ID, bidirectional: Bool = true) {
        db.connect(
            translation: translation,
            toEntry: translated,
            bidirectional: bidirectional
        )
    }
    
    public mutating func addNewKeyword(
        title: String,
        toEntry referenced: Entry.ID,
        titleConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Keyword> {
        let keyword: Keyword
        let matches = db.keywords(where: { $0.title == title })
        if let firstMatch = matches.first {
            switch titleConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .useFirstMatch:
                keyword = firstMatch
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
        return .success(keyword)
    }
    
    public mutating func addExisting(keyword: Keyword.ID, toEntry entry: Entry.ID) {
        db.connect(keyword: keyword, toEntry: entry)
    }
    
    
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
    
    public mutating func addNewUsage(
        content value: String,
        toEntry referenced: Entry.ID,
        valueConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Usage> {
        let usage: Usage
        let matches = db.usages(where: { $0.value == value })
        if let firstMatch = matches.first {
            switch valueConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .useFirstMatch:
                usage = firstMatch
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
        return .success(usage)
    }
    
    public mutating func addExisting(usage: Usage.ID, toEntry entry: Entry.ID) {
        db.connect(usage: usage, toEntry: entry)
    }
    
    public mutating func addNewEntry(
        fromSpelling spelling: String,
        in language: Language.ID? = nil,
        toEntryCollection collection: EntryCollection.ID,
        atOffset: Int? = nil,
        spellingConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Entry> {
        let result = addNewEntry(fromSpelling: spelling, in: language, spellingConflictResolution: spellingConflictResolution)
        switch result {
        case .success(let entry):
            addExisting(entry: entry.id, toEntryCollection: collection, atOffset: atOffset)
            return .success(entry)
        default: return result
        }
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
    
    public mutating func addNewRoot(
        fromSpelling spelling: String,
        language: Language.ID? = nil,
        toEntry derived: Entry.ID,
        spellingConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Entry> {
        let languageOfDerivedEntry = languages(.of(.entry(derived))).first?.id
        let result = addNewEntry(fromSpelling: spelling, in: language ?? languageOfDerivedEntry, spellingConflictResolution: spellingConflictResolution)
        if case .success(let root) = result {
            addExisting(root: root.id, toEntry: derived)
        }
        return result
    }
    
    public mutating func addExisting(root: Entry.ID, toEntry entry: Entry.ID) {
        db.connect(root: root, toEntry: entry)
    }
    
    public mutating func addNewSeeAlso(
        spelling: String,
        language: Language.ID? = nil,
        toEntry target: Entry.ID,
        spellingConflictResolution: AutoConflictResolution? = nil
    ) -> NewValueAddAttemptResult<Entry> {
        let languageOfTargetEntry = languages(.of(.entry(target))).first?.id
        let result = addNewEntry(fromSpelling: spelling, in: language ?? languageOfTargetEntry, spellingConflictResolution: spellingConflictResolution)
        if case .success(let seeAlso) = result {
            addExisting(seeAlso: seeAlso.id, toEntry: target)
        }
        return result
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
