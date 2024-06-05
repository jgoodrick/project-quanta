
import ComposableArchitecture
import Foundation
import Model
import SwiftUI

@Reducer
public struct EntrySpellingEditor {
    
    @ObservableState
    public struct State: Equatable {
        
        init(entryID: Shared<Entry.ID>) {
            self._entryID = entryID
            self.textField = .init(matching: .entry(entryID.wrappedValue))
        }
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        @Shared var entryID: Entry.ID
        var textField: FloatingTextField.State
        
        @Presents var destination: Destination.State?
        
        mutating func submitCurrentFieldValueAsUpdatedSpelling() -> EffectOf<EntrySpellingEditor> {
            
            defer {
                textField.reset()
            }
            
            let text = textField.text

            guard !text.isEmpty else {
                return .none
            }

            if let match = $db.firstEntry(where: \.spelling, is: text) {

                destination = .confirmationDialog(.addOrMergeWithExisting(entry: match))

            } else {
                                
                db.updateEntry(\.spelling, on: entryID, to: text)

            }
            
            return .none

        }

    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntrySpellingEditor.ConfirmationDialog>)
    }
    
    public enum ConfirmationDialog: Equatable {
        case cancel
        case mergeWithExistingSpellingMatch(Entry.Expansion)
        case updateSpellingWithoutMerging
    }

    public enum Action {
        case destination(PresentationAction<Destination.Action>)
        case textField(FloatingTextField.Action)
        
        case editSpellingButtonTapped
    }

    public var body: some ReducerOf<Self> {
        
        Scope(state: \.textField, action: \.textField) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .editSpellingButtonTapped:

                state.textField.text = state.$db[entry: state.entryID]?.spelling ?? ""
                state.textField.collapsed = false

                return .none

            case .textField(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    return state.submitCurrentFieldValueAsUpdatedSpelling()
                }
            case .textField: return .none

            case .destination(.presented(.confirmationDialog(.updateSpellingWithoutMerging))):

                state.db.updateEntry(\.spelling, on: state.entryID, to: state.textField.text)

                return .none

            case .destination(.presented(.confirmationDialog(.mergeWithExistingSpellingMatch(let existing)))):

                let preMergeID = state.entryID
                
                state.entryID = existing.id
                
                state.db.merge(entry: preMergeID, into: existing.id)

                return .none

            case .destination(.presented(.confirmationDialog(.cancel))):

                state.textField.reset()

                return .none

            case .destination: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrMergeWithExisting(entry: Entry.Expansion) -> Self where Action == EntrySpellingEditor.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled \"\(entry.spelling)\" already exists")
            },
            actions: {
                ButtonState<Action>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Action>.init(
                    action: .updateSpellingWithoutMerging, label: { .init("Keep separate") }
                )
                ButtonState<Action>.init(
                    action: .mergeWithExistingSpellingMatch(entry), label: { .init("Merge") }
                )
            },
            message: {
                .init("Would you like to merge with it, or keep this as a separate word with the same spelling?")
            }
        )
    }
}

struct EntrySpellingEditorViewModifier: ViewModifier {
    
    let store: StoreOf<EntrySpellingEditor>
    let placeholder: String
        
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Button("Edit") {
                        store.send(.editSpellingButtonTapped)
                    }
                }
            }
            .modifier(
                FloatingTextFieldInset(
                    store: store.scope(state: \.textField, action: \.textField),
                    placeholder: placeholder
                )
            )
    }
}

