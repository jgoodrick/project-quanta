
extension EntryDetailStore {
    func reduce(action: Action) {
                
        switch action {
        case .spellingTapped: break
        case .spellingTextCommitted: break
        case .spellingFocusDropped: break
        case .spellingEditButtonTapped: 
            self.editMode = .active
        case .spellingRemoveButtonTapped: break

            
        case .imageAddButtonTapped: break
        case .imageEditButtonTapped: break
        case .imageRemoveButtonTapped: 
            self.image = nil
        
            
        case .pronunciationPlayButtonTapped: break
        case .pronunciationAddButtonTapped: break
        case .pronunciationEditButtonTapped: break
        case .pronunciationRemoveButtonTapped: 
            self.pronunciation = nil
        
            
        case .individualTagButtonTapped(let tag): break
        case .individualTagEditButtonTapped(let tag): break
        case .individualTagRemoveButtonTapped(let tag): 
            self.tags.removeAll(where: { $0.id == tag.id })
        case .addTagButtonTapped: break
        case .editTagsButtonTapped: break
        
            
        case .translationTapped(_): break
        case .translationFocusDropped(_): break
        case .translationTextCommitted(_): break
        case .translationEditButtonTapped(_): break
        case .translationGoToDetailButtonTapped(_): break
        case .translationRemoveButtonTapped(let translation):
            self.translations.removeAll(where: { $0.id == translation.id })
        case .translationSwipedAndDeleted(let indexSet):
            for index in indexSet { self.translations.remove(at: index) }
        case .translationsMoved(let fromOffsets, let toOffset): break
        case .addTranslationButtonTapped: break
        case .editTranslationsButtonTapped: break
        
            
        case .exampleTapped(let example): break
        case .exampleFocusDropped(_): break
        case .exampleTextCommitted(_): break
        case .exampleRemoveButtonTapped(let example):
            self.examples.removeAll(where: { $0.id == example.id })
        case .exampleEditButtonTapped(let example): break
        case .examplesMoved(let fromOffsets, let toOffset): break
        case .exampleAddNewTranslationButtonTapped(let example): break
        case .exampleTranslationCellTapped(let exampleTranslation): break
        case .exampleTranslationFocusDropped(_): break
        case .exampleTranslationTextCommitted(_): break
        case .exampleTranslationEditButtonTapped(let exampleTranslation): break
        case .exampleTranslationRemoveButtonTapped(let exampleTranslation):
            if let index = self.examples.firstIndex(where: { $0.id == exampleTranslation.exampleID }) {
                self.examples[index].translations.removeAll(where: { $0.id == exampleTranslation.id })
            }
        case .exampleTranslationsMoved(let fromOffsets, let toOffset): break
        case .exampleSwipedAndDeleted(let indexSet):
            for index in indexSet { self.examples.remove(at: index) }
        case .addExampleButtonTapped: break
        case .editExamplesButtonTapped: break
        
            
        case .noteCellTapped(let indexedNote): break
        case .noteEditButtonTapped(let indexedNote): break
        case .noteSwipedAndDeleted(let indexSet): 
            for index in indexSet { self.notes.remove(at: index) }
        case .notesMoved(let fromOffsets, let toOffset): break
        case .addNoteButtonTapped: break
        case .editNotesButtonTapped: break
        
            
        case .individualCollectionButtonTapped(let entryCollection): break
        case .individualCollectionEditButtonTapped(let entryCollection): break
        case .individualCollectionRemoveButtonTapped(let entryCollection): 
            self.collectionsMembership.removeAll(where: { $0.id == entryCollection.id })
        case .addToCollectionButtonTapped: break
        case .editEntryCollectionsMembershipButtonTapped: break
        
            
        case .individualRelatedEntryCellTapped(let relatedEntry): break
        case .individualRelatedEntryRemoveButtonTapped(let relatedEntry): 
            self.relatedEntries.removeAll(where: { $0.id == relatedEntry.id })
        case .addRelatedEntryButtonTapped: break
        case .editRelatedEntriesButtonTapped: break
            
            
        }
    }
}
