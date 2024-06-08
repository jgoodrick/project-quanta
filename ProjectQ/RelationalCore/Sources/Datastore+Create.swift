
import Foundation
import ModelCore

extension Database {
    
    public mutating func create(_ entity: Entity, now: Date) {
        precondition(!contains(entity.id))
        switch entity {
        case .entry(let entry):
            stored.entries[entry.id] = .init(value: entry, now: now)
        case .language(let language):
            stored.languages[language.id] = .init(value: language, now: now)
        case .keyword(let keyword):
            stored.keywords[keyword.id] = .init(value: keyword, now: now)
        case .note(let note):
            stored.notes[note.id] = .init(value: note, now: now)
        case .usage(let usage):
            stored.usages[usage.id] = .init(value: usage, now: now)
        case .entryCollection(let entryCollection):
            stored.entryCollections[entryCollection.id] = .init(value: entryCollection, now: now)
        }
    }
    
}
