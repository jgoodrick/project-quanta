
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
        let result: String?
        if copy.contains(where: { $0.primaryLanguage == language.primaryLanguage }) {
            result = locale.localizedString(forIdentifier: language.bcp47.rawValue)
        } else {
            result = language.primaryLanguage.flatMap({ locale.localizedString(forLanguageCode: $0) })
        }
        return result ?? language.id.rawValue
    }
    
    public var displayNameForDefaultNewEntryLanguage: String {
        displayName(for: settings.defaultNewEntryLanguage)
    }
    
    
    
    public enum ConflictsResult<Value> {
        case success(Value)
        case conflicts([Value])
        case canceled
    }
    
    public enum AutoConflictResolution {
        case maintainDistinction
        case mergeWithFirstMatch
        case cancel
    }
    
    public mutating func attemptToAddNewEntry(
        fromSpelling spelling: String,
        in language: Language.ID? = nil,
        autoAppliedSpellingConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Entry> {
        let entry: Entry
        let matches = db.entries(where: { $0.spelling == spelling })
        if let firstMatch = matches.first {
            switch autoAppliedSpellingConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .mergeWithFirstMatch:
                entry = firstMatch
            case .maintainDistinction:
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
    
    public mutating func attemptToAddNewTranslation(
        fromSpelling spelling: String,
        in language: Language.ID? = nil,
        forEntry translated: Entry.ID,
        autoAppliedSpellingConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Entry> {
        let translationLanguage = language ?? settings.defaultTranslationLanguage.id
        let result = attemptToAddNewEntry(fromSpelling: spelling, in: translationLanguage, autoAppliedSpellingConflictResolution: autoAppliedSpellingConflictResolution)
        if case .success(let translation) = result {
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
    
    public mutating func attemptToAddNewKeyword(
        title: String,
        toEntry referenced: Entry.ID,
        autoAppliedTitleConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Keyword> {
        let keyword: Keyword
        let matches = db.keywords(where: { $0.title == title })
        if let firstMatch = matches.first {
            switch autoAppliedTitleConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .mergeWithFirstMatch:
                keyword = firstMatch
            case .maintainDistinction:
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
    
    
    public mutating func attemptToAddNewNote(
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
    
    public mutating func attemptToAddNewNote(
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
    
    public mutating func attemptToAddNewUsage(
        content value: String,
        toEntry referenced: Entry.ID,
        autoAppliedValueConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Usage> {
        let usage: Usage
        let matches = db.usages(where: { $0.value == value })
        if let firstMatch = matches.first {
            switch autoAppliedValueConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .mergeWithFirstMatch:
                usage = firstMatch
            case .maintainDistinction:
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
    
    public mutating func attemptToAddNewEntry(
        fromSpelling spelling: String,
        in language: Language.ID? = nil,
        toEntryCollection collection: EntryCollection.ID,
        atOffset: Int? = nil,
        autoAppliedSpellingConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Entry> {
        let result = attemptToAddNewEntry(fromSpelling: spelling, in: language, autoAppliedSpellingConflictResolution: autoAppliedSpellingConflictResolution)
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
    
    public mutating func attemptToAddNewRoot(
        fromSpelling spelling: String,
        language: Language.ID? = nil,
        toEntry derived: Entry.ID,
        autoAppliedSpellingConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Entry> {
        let languageOfDerivedEntry = languages(.of(.entry(derived))).first?.id
        let result = attemptToAddNewEntry(fromSpelling: spelling, in: language ?? languageOfDerivedEntry, autoAppliedSpellingConflictResolution: autoAppliedSpellingConflictResolution)
        if case .success(let root) = result {
            addExisting(root: root.id, toEntry: derived)
        }
        return result
    }
    
    public mutating func addExisting(root: Entry.ID, toEntry entry: Entry.ID) {
        db.connect(root: root, toEntry: entry)
    }
    
    public mutating func attemptToAddNewSeeAlso(
        spelling: String,
        language: Language.ID? = nil,
        toEntry target: Entry.ID,
        autoAppliedSpellingConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Entry> {
        let languageOfTargetEntry = languages(.of(.entry(target))).first?.id
        let result = attemptToAddNewEntry(fromSpelling: spelling, in: language ?? languageOfTargetEntry, autoAppliedSpellingConflictResolution: autoAppliedSpellingConflictResolution)
        if case .success(let seeAlso) = result {
            addExisting(seeAlso: seeAlso.id, toEntry: target)
        }
        return result
    }
    
    public mutating func addExisting(seeAlso: Entry.ID, toEntry entry: Entry.ID) {
        db.connect(seeAlso: seeAlso, toEntry: entry)
    }
    
    
    
    
    
    
    
    
    public struct RetainedRelationships {
        public let entities: Set<Entity.ID>
    }
    
    public func entity(_ entity: Entity.ID, wouldBeOrphanIfRemovedFrom proposed: Entity.ID) -> Bool {
        var result = db.connectedEntities(for: entity)
        switch entity {
        case .entry, .usage:
            result.subtract(db.languages().map(\.id.entityID))
        default: break
        }
        result.subtract([proposed])
        return result.count == 0
    }
    
    private func retainedRelationships(for entity: Entity.ID) -> RetainedRelationships {
        return .init(entities: db.connectedEntities(for: entity))
    }
    
    @discardableResult
    public mutating func remove(translation: Entry.ID, fromEntry translated: Entry.ID) -> RetainedRelationships {
        db.disconnect(translation: translation, fromEntry: translated, bidirectional: true)
        return retainedRelationships(for: .entry(translation))
    }
    
    @discardableResult
    public mutating func remove(keyword: Keyword.ID, fromEntry entry: Entry.ID) -> RetainedRelationships {
        db.disconnect(keyword: keyword, fromEntry: entry)
        return retainedRelationships(for: .keyword(keyword))
    }
    
    @discardableResult
    public mutating func remove(note: Note.ID, fromEntry entry: Entry.ID) -> RetainedRelationships {
        db.disconnect(note: note, fromEntry: entry)
        return retainedRelationships(for: .note(note))
    }
    
    @discardableResult
    public mutating func remove(note: Note.ID, fromUsage usage: Usage.ID) -> RetainedRelationships {
        db.disconnect(note: note, fromUsage: usage)
        return retainedRelationships(for: .note(note))
    }
    
    @discardableResult
    public mutating func remove(usage: Usage.ID, fromEntry entry: Entry.ID) -> RetainedRelationships {
        db.disconnect(usage: usage, fromEntry: entry)
        return retainedRelationships(for: .usage(usage))
    }
    
    @discardableResult
    public mutating func remove(entry: Entry.ID, fromEntryCollection entryCollection: EntryCollection.ID) -> RetainedRelationships {
        db.disconnect(entry: entry, fromEntryCollection: entryCollection)
        return retainedRelationships(for: .entry(entry))
    }
    
    @discardableResult
    public mutating func remove(language: Language.ID, fromEntry entry: Entry.ID) -> RetainedRelationships {
        db.disconnect(language: language, fromEntry: entry)
        return retainedRelationships(for: .language(language))
    }
    
    @discardableResult
    public mutating func remove(language: Language.ID, fromUsage usage: Usage.ID) -> RetainedRelationships {
        db.disconnect(language: language, fromUsage: usage)
        return retainedRelationships(for: .language(language))
    }
    
    @discardableResult
    public mutating func remove(root: Entry.ID, fromEntry entry: Entry.ID) -> RetainedRelationships {
        db.disconnect(root: root, fromEntry: entry)
        return retainedRelationships(for: .entry(root))
    }
    
    @discardableResult
    public mutating func remove(seeAlso: Entry.ID, fromEntry entry: Entry.ID) -> RetainedRelationships {
        db.disconnect(seeAlso: seeAlso, fromEntry: entry)
        return retainedRelationships(for: .entry(seeAlso))
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

    
    
    
    
    
    
    
    // The following methods specify the field to update in the signature, because we expect these fields to generally be unique
    
    public mutating func attemptToUpdateEntrySpelling(
        of entry: Entry.ID,
        to newValue: String,
        autoAppliedSpellingConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Entry> {
        guard let existing = db[entry: entry] else { preconditionFailure() }
        var result: Entry
        let matches = db.entries(where: { $0.spelling == newValue })
        if let firstMatch = matches.first {
            switch autoAppliedSpellingConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .mergeWithFirstMatch:
                result = firstMatch
                db.merge(entry: existing.id, into: firstMatch.id)
            case .maintainDistinction:
                result = existing
            }
        } else {
            result = existing
        }
        result.spelling = newValue
        db.update(.entry(result))
        return .success(result)
    }

    public mutating func attemptToUpdateEntryCollectionTitle(
        of entryCollection: EntryCollection.ID,
        to newValue: String,
        autoAppliedTitleConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<EntryCollection> {
        guard let existing = db[entryCollection: entryCollection] else { preconditionFailure() }
        var result: EntryCollection
        let matches = db.entryCollections(where: { $0.title == newValue })
        if let firstMatch = matches.first {
            switch autoAppliedTitleConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .mergeWithFirstMatch:
                result = firstMatch
                db.merge(entryCollection: existing.id, into: firstMatch.id)
            case .maintainDistinction:
                result = existing
            }
        } else {
            result = existing
        }
        result.title = newValue
        db.update(.entryCollection(result))
        return .success(result)
    }

    public mutating func attemptToUpdateKeywordTitle(
        of keyword: Keyword.ID,
        to newValue: String,
        autoAppliedTitleConflictResolution: AutoConflictResolution? = nil
    ) -> ConflictsResult<Keyword> {
        guard let existing = db[keyword: keyword] else { preconditionFailure() }
        var result: Keyword
        let matches = db.keywords(where: { $0.title == newValue })
        if let firstMatch = matches.first {
            switch autoAppliedTitleConflictResolution {
            case .none:
                return .conflicts(matches)
            case .cancel:
                return .canceled
            case .mergeWithFirstMatch:
                result = firstMatch
                db.merge(keyword: existing.id, into: firstMatch.id)
            case .maintainDistinction:
                result = existing
            }
        } else {
            result = existing
        }
        result.title = newValue
        db.update(.keyword(result))
        return .success(result)
    }

    
    // The following methods do not specify the field, because we do not care if other entities have the same values

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


    
    public mutating func merge(entry incomingID: Entry.ID, into remainingID: Entry.ID) {
        db.merge(entry: incomingID, into: remainingID)
    }
    
    public mutating func merge(entryCollection incomingID: EntryCollection.ID, into remainingID: EntryCollection.ID) {
        db.merge(entryCollection: incomingID, into: remainingID)
    }
    
    public mutating func merge(keyword incomingID: Keyword.ID, into remainingID: Keyword.ID) {
        db.merge(keyword: incomingID, into: remainingID)
    }
    
    public mutating func merge(language incomingID: Language.ID, into remainingID: Language.ID) {
        db.merge(language: incomingID, into: remainingID)
    }
    
    
    
            
    public mutating func delete(_ entity: Entity.ID) {
        db.delete(entity)
    }


}
