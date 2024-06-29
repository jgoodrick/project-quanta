
extension EntryDetailStore {
    func reduce(action: Action) {
                
        switch action {
        case .spellingTapped: 
            state.editMode = .active
            state.focused = .spelling
        case .spellingLanguageChanged(let new):
            state.entry.language = new
        case .spellingTextCommitted, .spellingFocusDropped:
            break // TODO - save the draft value to the model (this should update the spelling's 'value' property)
        case .spellingEditButtonTapped:
            state.editMode = .active
        case .spellingRemoveEntireEntryButtonTapped: 
            break // TODO - display confirmation dialog confirming the user really wants to completely delete this entry

            
        case .imageAddButtonTapped: break
        case .imageEditButtonTapped:
            state.editMode = .active
        case .imageRemoveButtonTapped:
            state.image = nil
        
            
        case .pronunciationPlayButtonTapped: break
        case .pronunciationAddButtonTapped: break
        case .pronunciationEditButtonTapped: 
            state.editMode = .active
        case .pronunciationRemoveButtonTapped:
            state.pronunciation = nil
        
            
        case .individualTagButtonTapped(_):
            break // TODO: navigate to the tag detail view
        case .individualTagEditButtonTapped(_):
            state.editMode = .active
        case .individualTagRemoveButtonTapped(let tag):
            state.tags.removeAll(where: { $0.id == tag.id })
        case .addTagButtonTapped: 
            break // TODO - show some kind of fuzzy picker/creator
        case .editTagsButtonTapped: break
        
            
        case .translationTapped(_), .translationGoToDetailButtonTapped(_):
            break // TODO - navigate to the translation's detail view
        case .translationEditButtonTapped(_):
            state.editMode = .active
        case .translationRemoveButtonTapped(let translation):
            state.translations.removeAll(where: { $0.id == translation.id })
        case .translationSwipedAndDeleted(let indexSet):
            for index in indexSet { state.translations.remove(at: index) }
        case .translationsMoved(let fromOffsets, let toOffset): 
            state.translations.move(fromOffsets: fromOffsets, toOffset: toOffset)
            // TODO - forward this move to the model
        case .addTranslationButtonTapped: 
            let newID = uuid()
            let language = currentLanguage()
            state.translationDrafts.append(.init(id: newID, language: language, additionalLanguages: []))
            state.editMode = .active
            state.focused = .translationDraft(newID)
            
        case .editTranslationsButtonTapped:
            state.editMode = .active
        
            
        case .translationDraftFocusDropped(let draft), .translationDraftTextCommitted(let draft):
            state.translationDrafts.removeAll(where: { $0.id == draft.id })
            if !draft.draft.isEmpty {
                state.translations.append(.init(id: draft.id, language: draft.language, value: draft.draft))
                // TODO - save the draft value to the model (this should update the translation's 'value' property)
            }
        case .translationDraftSwipedAndDeleted(let indexSet):
            for index in indexSet { state.translationDrafts.remove(at: index) }
            

        case .exampleTapped(let example):
            state.editMode = .active
            state.focused = .example(example.id)
        case .exampleTextEditorTask(let example):
            if example.value != example.draft {
                if let index = state.examples.firstIndex(where: { $0.id == example.id }) {
                    state.examples[index].draft = state.examples[index].value
                }
            }
        case .exampleAddTranslationButtonTapped(let example, let language):
            if let language {
                if let index = state.examples.firstIndex(where: { $0.id == example.id }) {
                    state.examples[index].draftTranslations[language.id] = .init(id: .init(example: example.id, language: language.id))
                }
            } else {
                print("inform the user there are no more languages configured and direct them to settings to add more languages")
            }
        case .exampleFocusDropped(let example), .exampleTextCommitted(let example):
            if example.draft.isEmpty {
                // TODO - consider checking with the user here via confirmation dialog instead of deleting right away
                state.examples.removeAll(where: { $0.id == example.id })
                // TODO - send the removal request (for deletion) to the model
            } else if let index = state.examples.firstIndex(where: { $0.id == example.id }) {
                state.examples[index].value = example.draft
                // TODO - save the draft value to the model
            }
        case .exampleRemoveButtonTapped(let example):
            state.examples.removeAll(where: { $0.id == example.id })
        case .exampleEditButtonTapped(let example): 
            state.editMode = .active
            state.focused = .example(example.id)
        case .examplesMoved(let fromOffsets, let toOffset):
            state.examples.move(fromOffsets: fromOffsets, toOffset: toOffset)
            // TODO - forward this move to the model
        case .exampleSwipedAndDeleted(let indexSet):
            for index in indexSet { state.examples.remove(at: index) }
            // TODO - forward this removal to the model
        case .addExampleButtonTapped: 
            let newID = uuid()
            state.exampleDrafts.append(.init(id: newID, language: state.entry.language))
            state.editMode = .active
            state.focused = .exampleDraft(newID)
            
        case .editExamplesButtonTapped:
            state.editMode = .active

            
            
        case .exampleTranslationCellTapped(let exampleTranslation): 
            state.editMode = .active
            state.focused = .exampleTranslation(exampleTranslation.id)
        case .exampleTranslationTextEditorTask(let exampleTranslation):
            if
                exampleTranslation.value != exampleTranslation.draft,
                let examplesIndex = state.examples.firstIndex(where: { $0.id == exampleTranslation.id.example }),
                var copy = state.examples[examplesIndex].translations[exampleTranslation.id.language] {
                
                copy.draft = copy.value
                state.examples[examplesIndex].translations[exampleTranslation.id.language] = copy
                
            }
        case .exampleTranslationFocusDropped(let exampleTranslation), .exampleTranslationTextCommitted(let exampleTranslation):
            if
                let examplesIndex = state.examples.firstIndex(where: { $0.id == exampleTranslation.id.example }),
                var copy = state.examples[examplesIndex].translations[exampleTranslation.id.language] {

                if exampleTranslation.draft.isEmpty {
                    // TODO - consider checking with the user here via confirmation dialog instead of deleting right away
                    state.examples[examplesIndex].translations[exampleTranslation.id.language] = nil
                    // TODO - send the removal request (for deletion) to the model
                } else {
                    
                    copy.value = exampleTranslation.draft
                    state.examples[examplesIndex].translations[exampleTranslation.id.language] = copy
                    // TODO - save the draft value to the model
                }

            }
        case .exampleTranslationEditButtonTapped(let translation):
            state.editMode = .active
            state.focused = .exampleTranslation(translation.id)
        case .exampleTranslationRemoveButtonTapped(let translation):
            if let examplesIndex = state.examples.firstIndex(where: { $0.id == translation.id.example }) {
                state.examples[examplesIndex].translations[translation.id.language] = nil
                // TODO - remove the value from the model as well
            }
        
        case .exampleTranslationDraftFocusDropped(let exampleTranslation), .exampleTranslationDraftTextCommitted(let exampleTranslation):
            if
                let examplesIndex = state.examples.firstIndex(where: { $0.id == exampleTranslation.id.example }),
                let draft = state.examples[examplesIndex].draftTranslations[exampleTranslation.id.language] {

                state.examples[examplesIndex].draftTranslations[exampleTranslation.id.language] = nil
                
                if !exampleTranslation.draft.isEmpty {
                    
                    let committed = ExampleTranslation.init(id: draft.id, value: draft.draft)
                    state.examples[examplesIndex].translations[exampleTranslation.id.language] = committed
                    // TODO - save the draft value to the model
                    
                } else {
                    // TODO - consider checking with the user here via confirmation dialog instead of deleting right away
                    // TODO - send the removal request (for deletion) to the model
                }

            }
        case .exampleTranslationDraftRemoveButtonTapped(let exampleTranslationDraft):
            if let examplesIndex = state.examples.firstIndex(where: { $0.id == exampleTranslationDraft.id.example }) {
                state.examples[examplesIndex].draftTranslations[exampleTranslationDraft.id.language] = nil
            }
            
        case .noteCellTapped(let note):
            state.editMode = .active
            state.focused = .note(note.id)
        case .noteEditButtonTapped(let note):
            state.editMode = .active
            state.focused = .note(note.id)
        case .noteRemoveButtonTapped(let note):
            state.notes.removeAll(where: { $0.id == note.id })
            // TODO - forward this removal to the model
        case .noteSwipedAndDeleted(let indexSet):
            for index in indexSet { state.notes.remove(at: index) }
        case .notesMoved(let fromOffsets, let toOffset): 
            state.notes.move(fromOffsets: fromOffsets, toOffset: toOffset)
            // TODO - forward this move to the model
        case .addNoteButtonTapped: 
            let newID = uuid()
            state.noteDrafts.append(.init(id: newID))
            state.editMode = .active
            state.focused = .noteDraft(newID)
            
        case .editNotesButtonTapped:
            state.editMode = .active
        case .noteTextEditorTask(let note):
            if note.value != note.draft {
                if let index = state.notes.firstIndex(where: { $0.id == note.id }) {
                    state.notes[index].draft = state.notes[index].value
                }
            }
        case .noteFocusDropped(let note), .noteTextCommitted(let note):
            if note.draft.isEmpty {
                // TODO - consider checking with the user here via confirmation dialog instead of deleting right away
                state.notes.removeAll(where: { $0.id == note.id })
                // TODO - send the removal request (for deletion) to the model
            } else if let index = state.notes.firstIndex(where: { $0.id == note.id }) {
                state.notes[index].value = note.draft
                // TODO - save the draft value to the model
            }
            
        case .noteDraftFocusDropped(let note), .noteDraftTextCommitted(let note):
            state.noteDrafts.removeAll(where: { $0.id == note.id })
            if !note.draft.isEmpty {
                state.notes.append(.init(id: note.id, value: note.draft))
                // TODO - save the draft value to the model
            }
        case .noteDraftSwipedAndDeleted(let indexSet):
            for index in indexSet { state.noteDrafts.remove(at: index) }

            
        case .individualCollectionButtonTapped(_):
            break // TODO - navigate to the entry collection detail view
        case .individualCollectionEditButtonTapped(_):
            state.editMode = .active
        case .individualCollectionRemoveButtonTapped(let entryCollection):
            state.collectionsMembership.removeAll(where: { $0.id == entryCollection.id })
        case .addToCollectionButtonTapped: 
            break // TODO - show some kind of fuzzy picker/creator (same as for tags)
        case .editEntryCollectionsMembershipButtonTapped:
            state.editMode = .active
        
            
        case .individualRelatedEntryCellTapped(_):
            break // TODO - navigate to the related entry's own detail view
        case .individualRelatedEntryRemoveButtonTapped(let relatedEntry):
            state.relatedEntries.removeAll(where: { $0.id == relatedEntry.id })
        case .addRelatedEntryButtonTapped:
            break // TODO - show some kind of fuzzy picker/creator (same as for tags)
        case .editRelatedEntriesButtonTapped:
            state.editMode = .active
            
            
            
        case .didBeginEditing: break
        case .didEndEditing:
            reduce(action: .spellingTextCommitted)
            // TODO - clear out any empty (draft) or invalid states
        }
    }
}

fileprivate extension Array where Element: Identifiable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element.ID: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0.id) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
