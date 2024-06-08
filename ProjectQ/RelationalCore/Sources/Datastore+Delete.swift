
import ModelCore

extension Database {
        
    public mutating func delete(_ entity: Entity.ID) {
        precondition(contains(entity))
        relationships.removeAllReferences(to: entity)
        switch entity {
        case .entry(let entry):
            stored.entries[entry] = nil
        case .language(let language):
            stored.languages[language] = nil
        case .keyword(let keyword):
            stored.keywords[keyword] = nil
        case .note(let note):
            stored.notes[note] = nil
        case .usage(let usage):
            stored.usages[usage] = nil
        case .entryCollection(let entryCollection):
            stored.entryCollections[entryCollection] = nil
        }
    }
    
}

extension Dictionary {
    mutating func mutateAll(with closure: (inout Value) -> Void) {
        keys.forEach { closure(&self[$0]!) }
    }
}

extension Database.Relationships {
    mutating func removeAllReferences(to entity: Entity.ID) {
        switch entity {
        case .entry(let entryID):
            entries[entryID] = nil
            entries.mutateAll {
                $0.roots.removeAll(where: { $0 == entryID })
                $0.derived.remove(entryID)
                $0.translations.removeAll(where: { $0 == entryID })
                $0.backTranslations.remove(entryID)
                $0.seeAlso.removeAll(where: { $0 == entryID })
            }
            keywords.mutateAll {
                $0.matches.removeAll(where: { $0 == entryID })
            }
            languages.mutateAll {
                $0.entries.remove(entryID)
            }
            notes.mutateAll {
                $0.targets.remove(.entry(entryID))
            }
            usages.mutateAll {
                $0.uses.remove(entryID)
            }
            entryCollections.mutateAll {
                $0.entries.removeAll(where: { $0 == entryID })
            }
        case .entryCollection(let entryCollectionID):
            entryCollections[entryCollectionID] = nil
            entries.mutateAll {
                $0.entryCollections.remove(entryCollectionID)
            }
        case .keyword(let keywordID):
            keywords[keywordID] = nil
            entries.mutateAll {
                $0.keywords.remove(keywordID)
            }
        case .language(let languageID):
            languages[languageID] = nil
            entries.mutateAll {
                $0.languages.removeAll(where: { $0 == languageID })
            }
        case .note(let noteID):
            notes[noteID] = nil
            entries.mutateAll {
                $0.notes.removeAll(where: { $0 == noteID })
            }
            usages.mutateAll {
                $0.notes.removeAll(where: { $0 == noteID })
            }
        case .usage(let usageID):
            usages[usageID] = nil
            entries.mutateAll {
                $0.usages.removeAll(where: { $0 == usageID })
            }
        }
    }
}

