
import ComposableArchitecture
import Foundation
import FeatureCore
import LayoutCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct EntryNotesEditor {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var editing: Note.ID?
        var textField: FloatingTextField.State = .init()
        
        @Presents var destination: Destination.State?
        
        var notes: [Note] {
            db.notes(forEntry: entryID)
        }
        
        mutating func commitTextField() -> EffectOf<EntryNotesEditor> {
            
            defer {
                editing = .none
                textField.reset()
            }
            
            let value = textField.text
            
            if let editing {
                
                guard !value.isEmpty else {
                    db.delete(.note(editing))
                    return .none
                }
                
                guard var note = db[note: editing] else {
                    assertionFailure()
                    return .none
                }
                
                note.value = value
                    
                db.update(.note(note))
                
            } else {
                guard !value.isEmpty else {
                    textField.reset()
                    return .none
                }
                    
                let newNote = db.createNewNote {
                    $0.value = value
                }
                
                db.connect(note: newNote.id, toEntry: entryID)
            }
            
            return .none
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case textField(FloatingTextField.Action)

        case addButtonTapped
        case doneButtonTapped
        case destructiveSwipeButtonTapped(Note)
        case moved(fromOffsets: IndexSet, toOffset: Int)
        case selected(Note)
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Scope(state: \.textField, action: \.textField) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
                
            case .addButtonTapped:

                state.textField.collapsed = false
                
                return .none
                
            case .doneButtonTapped:

                return state.commitTextField()
                
            case .textField(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped: 
                    return state.commitTextField()
                }
            case .textField: return .none

            case .destructiveSwipeButtonTapped(let note):

                state.db.delete(.note(note.id))

                return .none

            case .moved(let fromOffsets, let toOffset):

                state.db.moveNotes(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)

                return .none
                
            case .selected(let note):
                
                state.editing = note.id
                state.textField.text = note.value
                state.textField.collapsed = false
                
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension Note: TextEditableItem {}

struct EntryNotesEditorView: View {
    
    @Bindable var store: StoreOf<EntryNotesEditor>
    
    var body: some View {
        TextEditableItemsSection(
            title: "Notes",
            items: store.notes,
            onSelected: { store.send(.selected($0)) },
            onDeleted: { store.send(.destructiveSwipeButtonTapped($0)) },
            onMoved: { store.send(.moved(fromOffsets: $0, toOffset: $1)) },
            onMenuShortPressed: { store.send(.addButtonTapped) }
        )
    }
}

