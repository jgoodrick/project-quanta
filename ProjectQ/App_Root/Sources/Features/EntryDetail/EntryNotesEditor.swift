
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntryNotesEditor {
    
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var focusedNote: Note.ID?
        @Presents var destination: Destination.State?
        
        var notes: [Note.Expansion] {
            $db.notes(for: entryID)
        }
        
        mutating func addNewEmptyNote() -> EffectOf<EntryNotesEditor> {
            
            do {
                let newNote = try $db.addNewNote()
                
                db.connect(note: newNote.id, to: entryID)
                
                focusedNote = newNote.id
                
            } catch {
                
                destination = .alert(.failedToAddNewNote(error: error))
                
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
        
        case addButtonTapped
        case doneButtonTapped
        case destructiveSwipeButtonTapped(Note.Expansion)
        case moved(fromOffsets: IndexSet, toOffset: Int)
    }

    public var body: some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none

            case .addButtonTapped:

                return state.addNewEmptyNote()

            case .doneButtonTapped:
                
                state.focusedNote = nil
                
                return .none
                
            case .destructiveSwipeButtonTapped(let note):

                state.db.remove(note: note.id)

                return .none

            case .moved(let fromOffsets, let toOffset):

                state.db.moveNotes(on: state.entryID, fromOffsets: fromOffsets, toOffset: toOffset)

                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState {
    static func failedToAddNewNote(error: Error) -> Self where Action == Never {
        .init(
            title: {
                .init("Could not create new note")
            },
            message: {
                .init("Error: \(error.localizedDescription)")
            }
        )
    }
}

extension Note.Expansion: TextEditableItem {
    var boundValue: Binding<String> { bound.value }
}

struct EntryNotesEditorView: View {
    
    @SwiftUI.Bindable var store: StoreOf<EntryNotesEditor>
    
    @FocusState var focused: Note.ID?

    var body: some View {
        TextEditableItemsSection(
            title: "Notes",
            items: store.notes,
            focusedItem: $store.focusedNote,
            onDelete: { store.send(.destructiveSwipeButtonTapped($0)) },
            onMoved: { store.send(.moved(fromOffsets: $0, toOffset: $1)) },
            onMenuShortPressed: { store.send(.addButtonTapped) }
        )
        .environment(\.floatingTextField.autocapitalization, .sentences)
    }
}

