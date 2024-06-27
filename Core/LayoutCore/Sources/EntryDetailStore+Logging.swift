
extension EntryDetailStore {
    
    static func log(action: Action) {
        switch action {
        case .draftSpellingCommitted:
            print("committed the draft spelling value")
        case .imageAddButtonTapped:
            print("tapped add new image button")
        case .imageEditButtonTapped:
            print("tapped edit image button")
        case .imageRemoveButtonTapped:
            print("tapped remove image button")
        case .pronunciationPlayButtonTapped:
            print("tapped play pronunciation button")
        case .pronunciationAddButtonTapped:
            print("tapped add new pronunciation button")
        case .pronunciationEditButtonTapped:
            print("tapped edit pronunciation button")
        case .pronunciationRemoveButtonTapped:
            print("tapped remove pronunciation button")
        case .individualTagButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .individualTagEditButtonTapped(let tag):
            print("\(tag.title) tag edit button tapped")
        case .individualTagRemoveButtonTapped(let tag):
            print("\(tag.title) tag remove button tapped")
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
            print("swiped and deleted \(removed.value)")
        case .translationsMoved(let fromOffsets, let toOffset):
            print("moved \(fromOffsets.count) item(s) to \(toOffset)")
        case .addTranslationButtonTapped:
            print("tapped add translation button")
        case .editTranslationsButtonTapped:
            print("tapped edit translations button")
        case .exampleTapped(let example):
            print("tapped example: \(example.id)")
        case .exampleEditButtonTapped(let example):
            print("tapped edit example: \(example.id)")
        case .examplesMoved(fromOffsets: let fromOffsets, toOffset: let toOffset):
            print("moved \(fromOffsets.count) example(s) to \(toOffset)")
        case .exampleAddNewTranslationButtonTapped(let example):
            print("tapped add new translation to example: \(example.id)")
        case .exampleTranslationCellTapped(let translation):
            print("tapped example translation cell: \(translation.id)")
        case .exampleTranslationEditButtonTapped(let translation):
            print("tapped edit example translation cell: \(translation.id)")
        case .exampleTranslationRemoveButtonTapped(let translation):
            print("tapped remove example translation cell: \(translation.id)")
        case .exampleSwipedAndDeleted(let removed):
            print("swiped and deleted \(removed.value)")
        case .exampleTranslationsMoved(fromOffsets: let fromOffsets, toOffset: let toOffset):
            print("moved \(fromOffsets.count) translation(s) to \(toOffset)")
        case .addExampleButtonTapped:
            print("tapped add example button")
        case .editExamplesButtonTapped:
            print("tapped edit examples button")
        case .noteCellTapped(let note):
            print("tapped note: \(note)")
        case .noteEditButtonTapped(let note):
            print("tapped edit note: \(note)")
        case .noteSwipedAndDeleted(let removed):
            print("swiped and deleted \(removed.value)")
        case .addNoteButtonTapped:
            print("tapped add note button")
        case .editNotesButtonTapped:
            print("tapped edit notes button")
        case .notesMoved(fromOffsets: let fromOffsets, toOffset: let toOffset):
            print("moved \(fromOffsets.count) note(s) to \(toOffset)")
        case .individualCollectionButtonTapped(let collection):
            print("\(collection.title) collection button tapped")
        case .individualCollectionEditButtonTapped(let collection):
            print("\(collection.title) collection edit button tapped")
        case .individualCollectionRemoveButtonTapped(let collection):
            print("\(collection.title) collection remove button tapped")
        case .addToCollectionButtonTapped:
            print("tapped add collection button")
        case .editEntryCollectionsMembershipButtonTapped:
            print("tapped edit collections button")
        case .individualRelatedEntryCellTapped(let entry):
            print("\(entry.spelling) related entry button tapped")
        case .individualRelatedEntryRemoveButtonTapped(let entry):
            print("\(entry.spelling) related entry remove button tapped")
        case .addRelatedEntryButtonTapped:
            print("tapped add related word button")
        case .editRelatedEntriesButtonTapped:
            print("tapped edit related words button")
        }
    }

}
