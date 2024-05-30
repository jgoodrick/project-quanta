
extension Dictionary {
    mutating func mutateAll(with closure: (inout Value) -> Void) {
        keys.forEach { closure(&self[$0]!) }
    }
}

extension Database.Relationships {
    mutating func removeAllReferences(toEntry entryID: Entry.ID) {
        entries[entryID] = nil
        entries.mutateAll {
            if $0.root == entryID { $0.root = nil }
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
            if case .entry(entryID) = $0.target { $0.target = nil }
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
            if $0.language == languageID { $0.language = nil }
        }
    }
    mutating func removeAllReferences(toNote noteID: Note.ID) {
        notes[noteID] = nil
        entries.mutateAll {
            $0.notes.removeAll(where: { $0 == noteID })
        }
        usages.mutateAll {
            if $0.note == noteID { $0.note = nil }
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
