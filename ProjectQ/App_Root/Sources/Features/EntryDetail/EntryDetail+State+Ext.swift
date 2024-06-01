
import ComposableArchitecture
import Model

extension EntryDetail.State {
    
    var translations: [Entry.Expansion] {
        $db.translations(for: entryID)
    }

    var languageName: String {
        $db[entry: entryID]?.language?.displayName ?? "Not Set"
    }

    var entry: Entry? {
        db[entry: entryID]
    }

    mutating func submitCurrentFieldValueAsUpdatedSpelling() -> EffectOf<EntryDetail> {
        
        defer {
            self.spelling.reset()
        }
        
        let spelling = spelling.text

        guard !spelling.isEmpty else {
            return .none
        }

        if let match = $db.firstEntry(where: \.spelling, is: spelling) {

            destination = .confirmationDialog(.addOrMergeWithExisting(entry: match))

        } else {

            db.updateEntry(\.spelling, on: entryID, to: spelling)

        }
        
        return .none

    }
    
    mutating func submitCurrentFieldValueAsTranslation() -> EffectOf<EntryDetail> {
        
        defer {
            translation.reset()
        }

        let translationSpelling = translation.text
        
        guard !translationSpelling.isEmpty else {
            return .none
        }
        
        let matches = $db.entries(where: \.spelling, is: translationSpelling)
        
        if let first = matches.first {
            
            if matches.count > 1 {
                
                // what if there are more than one words in the repo that match the spelling of the translation the user just typed in? (Because the user previously decided to create a separate word with the same spelling instead of merging or editing the existing one). We will need to handle this with a confirmation dialog, as we have done previously.
                // TODO: handle more than one match
                
                destination = .alert(.init(title: { .init("There was more than one entry that matched that translation's spelling. This is not currently supported.")}))
                
            } else {
                
                db.connect(translation: first.id, to: entryID)

            }

        } else {
            
            do {
                
                let translationSpelling = translation.text
                let translationLanguage = translation.language
                
                let newEntry = try $db.addNewEntry(language: translationLanguage) {
                    $0.spelling = translationSpelling
                }
                
                db.connect(translation: newEntry.id, to: entryID)
                
            } catch {
                
                destination = .alert(.init(title: { .init("Failed to add a new translation: \(error.localizedDescription)") }))
                
            }
            
        }
                                        
        return .none

    }

}
