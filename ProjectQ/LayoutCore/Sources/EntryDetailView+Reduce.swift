
extension EntryDetailStore {
    func reduce(action: Action) {
        
        self.focused = .none

        print("set focused state to .none")
        
        switch action {
        case .draftSpellingCommitted: break
        
        case .imageAddButtonTapped: break
        case .imageEditButtonTapped: break
        case .imageRemoveButtonTapped: break
        
        case .pronunciationPlayButtonTapped: break
        case .pronunciationAddButtonTapped: break
        case .pronunciationEditButtonTapped: break
        case .pronunciationRemoveButtonTapped: break
        
        case .individualTagButtonTapped(let tag): break
        case .individualTagEditButtonTapped(let tag): break
        case .individualTagRemoveButtonTapped(let tag): break
        case .addTagButtonTapped: break
        case .editTagsButtonTapped: break
        
        case .translationTapped(let translation): break
        case .translationEditButtonTapped(let translation): break
        case .translationGoToDetailButtonTapped(let translation): break
        case .translationRemoveButtonTapped(let translation): break
        case .translationSwipedAndDeleted(let translation): break
        case .translationsMoved(let fromOffsets, let toOffset): break
        case .addTranslationButtonTapped: break
        case .editTranslationsButtonTapped: break
        
        case .exampleTapped(let example): break
        case .exampleEditButtonTapped(let example): break
        case .examplesMoved(let fromOffsets, let toOffset): break
        case .exampleAddNewTranslationButtonTapped(let example): break
        case .exampleTranslationCellTapped(let exampleTranslation): break
        case .exampleTranslationEditButtonTapped(let exampleTranslation): break
        case .exampleTranslationRemoveButtonTapped(let exampleTranslation): break
        case .exampleTranslationsMoved(let fromOffsets, let toOffset): break
        case .exampleSwipedAndDeleted(let example): break
        case .addExampleButtonTapped: break
        case .editExamplesButtonTapped: break
        
        case .noteCellTapped(let indexedNote): break
        case .noteEditButtonTapped(let indexedNote): break
        case .noteSwipedAndDeleted(let indexedNote): break
        case .notesMoved(let fromOffsets, let toOffset): break
        case .addNoteButtonTapped: break
        case .editNotesButtonTapped: break
        
        case .individualCollectionButtonTapped(let entryCollection): break
        case .individualCollectionEditButtonTapped(let entryCollection): break
        case .individualCollectionRemoveButtonTapped(let entryCollection): break
        case .addToCollectionButtonTapped: break
        case .editEntryCollectionsMembershipButtonTapped: break
        
        case .individualRelatedEntryCellTapped(let relatedEntry): break
        case .individualRelatedEntryRemoveButtonTapped(let relatedEntry): break
        case .addRelatedEntryButtonTapped: break
        case .editRelatedEntriesButtonTapped: break
        }
    }
}
