
extension EntryDetailStore {
    
    static func log(action: Action) {
        switch action {
            
        case .spellingTapped: 
            print("spellingTapped")
        case .spellingTextCommitted:
            print("spellingTextCommitted")
        case .spellingFocusDropped:
            print("spellingFocusDropped")
        case .spellingEditButtonTapped:
            print("spellingEditButtonTapped")
        case .spellingRemoveEntireEntryButtonTapped:
            print("spellingRemoveEntireEntryButtonTapped")
        case .spellingLanguageChanged(let new):
            print("spelling language changed to \(new)")
            
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
            print("swiped and deleted translation at indexes: \(removed)")
        case .translationsMoved(let fromOffsets, let toOffset):
            print("moved \(fromOffsets.count) item(s) to \(toOffset)")
        case .addTranslationButtonTapped:
            print("tapped add translation button")
        case .editTranslationsButtonTapped:
            print("tapped edit translations button")
            
            
        case .translationDraftFocusDropped(let draft):
            print("translation draft focus dropped: \(draft.id)")
        case .translationDraftTextCommitted(let draft):
            print("translation draft committed: \(draft.id)")
        case .translationDraftSwipedAndDeleted(let removed):
            print("swiped and deleted translation drafts at indexes: \(removed)")

            
        case .exampleTapped(let example):
            print("tapped example: \(example.id)")
        case .exampleTextEditorTask: break
        case .exampleAddTranslationButtonTapped(let example, let language):
            print("tapped add \(language?.primaryLanguage ?? "") translation for example: \(example.id)")
        case .exampleFocusDropped(let example):
            print("example Focus Dropped: \(example.id)")
        case .exampleTextCommitted(let example):
            print("example Committed: \(example.id)")
        case .exampleRemoveButtonTapped(let example):
            print("example Remove Button Tapped: \(example.id)")
        case .exampleEditButtonTapped(let example):
            print("tapped edit example: \(example.id)")
        case .examplesMoved(fromOffsets: let fromOffsets, toOffset: let toOffset):
            print("moved \(fromOffsets.count) example(s) to \(toOffset)")
            
        case .exampleSwipedAndDeleted(let removed):
            print("swiped and deleted example at indexes: \(removed)")
        case .addExampleButtonTapped:
            print("tapped add example button")
        case .editExamplesButtonTapped:
            print("tapped edit examples button")

        
        case .exampleTranslationTextEditorTask: break
        case .exampleTranslationCellTapped(let translation):
            print("tapped example translation cell: \(translation.id)")
        case .exampleTranslationFocusDropped(let example):
            print("example Translation Focus Dropped: \(example.id)")
        case .exampleTranslationTextCommitted(let example):
            print("example Translation Text Committed: \(example.id)")
        case .exampleTranslationEditButtonTapped(let translation):
            print("tapped edit example translation cell: \(translation.id)")
        case .exampleTranslationRemoveButtonTapped(let translation):
            print("tapped remove example translation cell: \(translation.id)")
            
            
        case .exampleTranslationDraftFocusDropped(let draft):
            print("example draft translation Focus Dropped: \(draft.id)")
        case .exampleTranslationDraftTextCommitted(let draft):
            print("example draft translation Text Committed: \(draft.id)")
        case .exampleTranslationDraftRemoveButtonTapped(let draft):
            print("tapped remove example draft translation cell: \(draft.id)")
            
            
        case .noteCellTapped(let note):
            print("tapped note: \(note)")
        case .noteTextEditorTask: break
        case .noteFocusDropped(let note):
            print("note focus dropped: \(note.id)")
        case .noteTextCommitted(let note):
            print("note committed: \(note.id)")
        case .noteEditButtonTapped(let note):
            print("tapped edit note: \(note)")
        case .noteRemoveButtonTapped(let note):
            print("tapped remove note: \(note)")
        case .noteSwipedAndDeleted(let removed):
            print("swiped and deleted notes at indexes: \(removed)")
        case .addNoteButtonTapped:
            print("tapped add note button")
        case .editNotesButtonTapped:
            print("tapped edit notes button")
        case .notesMoved(fromOffsets: let fromOffsets, toOffset: let toOffset):
            print("moved \(fromOffsets.count) note(s) to \(toOffset)")
            
            
        case .noteDraftFocusDropped(let draft):
            print("note draft focus dropped: \(draft.id)")
        case .noteDraftTextCommitted(let draft):
            print("note draft committed: \(draft.id)")
        case .noteDraftSwipedAndDeleted(let indexSet):
            print("swiped and deleted note drafts at indexes: \(indexSet)")


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
            
            
        case .didBeginEditing:
            print("did begin editing")
        case .didEndEditing:
            print("did end editing")
        }
    }

}
