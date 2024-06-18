
import RelationalModel
import StructuralModel

/**
 AppModel.Queries
 These enumerations define the relationships that can be queried by the client app, and aid in discoverability
 They also provide a stable api that will ideally not change, even if the underlying database changes
 */
extension AppModel {
    
    public enum EntriesFilter: Hashable {
        case all
        case thatAre(EntryAspect)
        public enum EntryAspect: Hashable {
            case roots(of: Entry.ID)
            case derived(from: Entry.ID)
            case translations(of: Entry.ID)
            case backTranslations(of: Entry.ID)
            case seeAlsos(of: Entry.ID)
        }
        case of(RelatedEntity)
        public enum RelatedEntity: Hashable {
            case language(Language.ID)
            case keyword(Keyword.ID)
            case note(Note.ID)
            case usage(Usage.ID)
            case entryCollection(EntryCollection.ID)
        }
    }
    public func entries(_ filter: EntriesFilter, sortedBy sort: SortField<Entry> = .modified, reversed: Bool = false, limit: Int? = nil) -> [Entry] {
        let base = switch filter {
        case .all: db.entries(sortedBy: sort)
        case .thatAre(let relatedEntry):
            switch relatedEntry {
            case .roots(let derived): db.roots(forEntry: derived, sortedBy: sort)
            case .derived(let root): db.derived(forEntry: root, sortedBy: sort)
            case .translations(let translated): db.translations(forEntry: translated, sortedBy: sort)
            case .backTranslations(let backTranslated): db.backTranslations(forEntry: backTranslated, sortedBy: sort)
            case .seeAlsos(let related): db.seeAlso(forEntry: related, sortedBy: sort)
            }
        case .of(let relatedEntity):
            switch relatedEntity {
            case .keyword(let id): db.entries(matchingKeyword: id, sortedBy: sort)
            case .language(let id): db.entries(forLanguage: id, sortedBy: sort)
            case .note(let id): db.entries(targetedByNote: id, sortedBy: sort)
            case .usage(let id): db.entries(inUsage: id, sortedBy: sort)
            case .entryCollection(let id): db.entries(inCollection: id, sortedBy: sort)
            }
        }
        return base.limited(limit: limit ?? config.defaultLimit, reversed: reversed)
    }

    public enum EntryCollectionsFilter: Hashable {
        case all
        case thatContain(RelatedEntity)
        public enum RelatedEntity: Hashable {
            case entry(Entry.ID)
            case language(Language.ID)
        }
    }
    public func entryCollections(_ filter: EntryCollectionsFilter, sortedBy sort: SortField<EntryCollection> = .modified, reversed: Bool = false, limit: Int? = nil) -> [EntryCollection] {
        let base = switch filter {
        case .all: db.entryCollections(sortedBy: sort)
        case .thatContain(let relatedEntity):
            switch relatedEntity {
            case .entry(let id): db.entryCollections(forEntry: id, sortedBy: sort)
            case .language(let id): db.entryCollections(includingLanguage: id, sortedBy: sort)
            }
        }
        return base.limited(limit: limit ?? config.defaultLimit, reversed: reversed)
    }

    public enum KeywordsFilter: Hashable {
        case all
        case of(RelatedEntity)
        public enum RelatedEntity: Hashable {
            case entry(Entry.ID)
        }
    }
    public func keywords(_ filter: KeywordsFilter, sortedBy sort: SortField<Keyword> = .modified, reversed: Bool = false, limit: Int? = nil) -> [Keyword] {
        let base = switch filter {
        case .all: db.keywords(sortedBy: sort)
        case .of(let relatedEntity):
            switch relatedEntity {
            case .entry(let id): db.keywords(forEntry: id, sortedBy: sort)
            }
        }
        return base.limited(limit: limit ?? config.defaultLimit, reversed: reversed)
    }

    public enum LanguagesFilter: Hashable {
        case all
        case of(RelatedEntity)
        public enum RelatedEntity: Hashable {
            case entry(Entry.ID)
            case usage(Usage.ID)
        }
    }
    public func languages(_ filter: LanguagesFilter, sortedBy sort: SortField<Language> = .modified, reversed: Bool = false, limit: Int? = nil) -> [Language] {
        let base = switch filter {
        case .all: db.languages(sortedBy: sort)
        case .of(let relatedEntity):
            switch relatedEntity {
            case .entry(let id): db.languages(forEntry: id, sortedBy: sort)
            case .usage(let id): db.languages(forUsage: id, sortedBy: sort)
            }
        }
        return base.limited(limit: limit ?? config.defaultLimit, reversed: reversed)
    }

    public enum NotesFilter: Hashable {
        case all
        case of(RelatedEntity)
        public enum RelatedEntity: Hashable {
            case entry(Entry.ID)
            case usage(Usage.ID)
        }
    }
    public func notes(_ filter: NotesFilter, sortedBy sort: SortField<Note> = .modified, reversed: Bool = false, limit: Int? = nil) -> [Note] {
        let base = switch filter {
        case .all: db.notes(sortedBy: sort)
        case .of(let relatedEntity):
            switch relatedEntity {
            case .entry(let id): db.notes(forEntry: id, sortedBy: sort)
            case .usage(let id): db.notes(forUsage: id, sortedBy: sort)
            }
        }
        return base.limited(limit: limit ?? config.defaultLimit, reversed: reversed)
    }

    public enum UsagesFilter: Hashable {
        case all
        case of(RelatedEntity)
        public enum RelatedEntity: Hashable {
            case language(Language.ID)
            case entry(Entry.ID)
        }
    }
    public func usages(_ filter: UsagesFilter, sortedBy sort: SortField<Usage> = .modified, reversed: Bool = false, limit: Int? = nil) -> [Usage] {
        let base = switch filter {
        case .all: db.usages(sortedBy: sort)
        case .of(let relatedEntity):
            switch relatedEntity {
            case .language(let id): db.usages(forLanguage: id, sortedBy: sort)
            case .entry(let id): db.usages(forEntry: id, sortedBy: sort)
            }
        }
        return base.limited(limit: limit ?? config.defaultLimit, reversed: reversed)
    }

}
