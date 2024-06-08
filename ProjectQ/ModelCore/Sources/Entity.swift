
public enum Entity: Identifiable, Equatable, Codable, Sendable {
    case entry(Entry)
    case entryCollection(EntryCollection)
    case keyword(Keyword)
    case language(Language)
    case note(Note)
    case usage(Usage)
    public enum ID: Hashable, Equatable, Codable, Sendable {
        case entry(Entry.ID)
        case entryCollection(EntryCollection.ID)
        case keyword(Keyword.ID)
        case language(Language.ID)
        case note(Note.ID)
        case usage(Usage.ID)
    }
    public var id: ID {
        switch self {
        case .entry(let entity): return .entry(entity.id)
        case .entryCollection(let entity): return .entryCollection(entity.id)
        case .keyword(let entity): return .keyword(entity.id)
        case .language(let entity): return .language(entity.id)
        case .note(let entity): return .note(entity.id)
        case .usage(let entity): return .usage(entity.id)
        }
    }
    public enum Model: Hashable, Equatable, Codable, Sendable {
        case entry
        case entryCollection
        case keyword
        case language
        case note
        case usage
        case user
    }
    public var model: Model {
        switch self {
        case .entry: return .entry
        case .entryCollection: return .entryCollection
        case .keyword: return .keyword
        case .language: return .language
        case .note: return .note
        case .usage: return .usage
        }
    }
}
