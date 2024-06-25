
extension EntryDetailStore {
    
    static func log(action: Action) {
        switch action {
        case .newSpellingCommitted(let value):
            print("committed the new spelling value: \(value)")
        case .pronunciationButtonTapped:
            print("tapped pronunciation button")
        case .pronunciationEditButtonTapped:
            print("tapped edit pronunciation")
        case .addToCollectionButtonTapped:
            print("tapped add to collection")
        case .editCollectionMembershipButtonTapped:
            print("tapped edit collection memberships")
        case .individualTagButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .individualTagEditButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .individualTagRemoveButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .addTagButtonTapped:
            print("tapped add tag button")
        case .editTagsButtonTapped:
            print("tapped edit tags button")
        case .translationTapped(let translation):
            print("tapped translation: \(translation)")
        case .translationEditButtonTapped(let translation):
            print("tapped edit translation: \(translation)")
        case .translationGoToDetailButtonTapped(let translation):
            print("tapped go to translation: \(translation)")
        case .translationRemoveButtonTapped(let translation):
            print("tapped remove translation: \(translation)")
        case .translationSwipedAndDeleted(let removed):
            print("deleted \(removed.value)")
        case .addTranslationButtonTapped:
            print("tapped add translation button")
        case .editTranslationsButtonTapped:
            print("tapped edit translations button")
        case .exampleTapped(let example):
            print("tapped example: \(example.id)")
        case .exampleEditButtonTapped(let example):
            print("tapped edit example: \(example.id)")
        case .exampleAddNewTranslationButtonTapped(let example):
            print("tapped add new translation to example: \(example.id)")
        case .exampleTranslationCellTapped(let translation):
            print("tapped example translation cell: \(translation.id)")
        case .exampleTranslationEditButtonTapped(let translation):
            print("tapped edit example translation cell: \(translation.id)")
        case .exampleTranslationRemoveButtonTapped(let translation):
            print("tapped remove example translation cell: \(translation.id)")
        case .exampleSwipedAndDeleted(let removed):
            print("deleted \(removed.value)")
        case .addExampleButtonTapped:
            print("tapped add example button")
        case .editExamplesButtonTapped:
            print("tapped edit examples button")
        case .noteCellTapped(let note):
            print("tapped note: \(note)")
        case .noteEditButtonTapped(let note):
            print("tapped edit note: \(note)")
        case .noteSwipedAndDeleted(let removed):
            print("deleted \(removed.value)")
        case .addNoteButtonTapped:
            print("tapped add note button")
        case .editNotesButtonTapped:
            print("tapped edit notes button")
        case .individualRelatedEntryCellTapped(let entry):
            print("\(entry.spelling) button tapped")
        case .individualRelatedEntryRemoveButtonTapped(let entry):
            print("\(entry.spelling) remove button tapped")
        case .addRelatedEntryButtonTapped:
            print("tapped add related word button")
        case .editRelatedEntriesButtonTapped:
            print("tapped edit related words button")
        case .addNewPhotoButtonTapped:
            print("tapped add new photo menu button")
        case .addNewPronunciationButtonTapped:
            print("tapped add new pronunciation menu button")
        }
    }

}
