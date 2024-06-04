
extension Dictionary {
    mutating func mutateAll(with closure: (inout Value) -> Void) {
        keys.forEach { closure(&self[$0]!) }
    }
}

extension Database.Relationships {
    mutating func removeAllReferences(toEntry entryID: Entry.ID) {
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
    }
    mutating func removeAllReferences(toKeyword keywordID: Keyword.ID) {
        keywords[keywordID] = nil
        entries.mutateAll {
            $0.keywords.remove(keywordID)
        }
    }
    mutating func removeAllReferences(toLanguage languageID: Language.ID) {
        languages[languageID] = nil
        entries.mutateAll {
            $0.languages.removeAll(where: { $0 == languageID })
        }
    }
    mutating func removeAllReferences(toNote noteID: Note.ID) {
        notes[noteID] = nil
        entries.mutateAll {
            $0.notes.removeAll(where: { $0 == noteID })
        }
        usages.mutateAll {
            $0.notes.removeAll(where: { $0 == noteID })
        }
    }
    mutating func removeAllReferences(toUsage usageID: Usage.ID) {
        usages[usageID] = nil
        entries.mutateAll {
            $0.usages.removeAll(where: { $0 == usageID })
        }
    }
    mutating func removeAllReferences(toEntryCollection entryCollectionID: EntryCollection.ID) {
        entryCollections[entryCollectionID] = nil
        entries.mutateAll {
            $0.entryCollections.remove(entryCollectionID)
        }
    }
}
