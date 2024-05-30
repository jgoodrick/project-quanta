
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct EntryCreator {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.db) var db
        @Shared(.settings) var settings
        public var spelling: FloatingTextField.State = {
            @Shared(.settings) var settings
            return .init(language: settings.focusedLanguage)
        }()
        
        @Presents public var destination: Destination.State?
        
        mutating func addAndPushNewEntry() -> EffectOf<EntryCreator> {
            
            let spelling = spelling.text
            let language = settings.focusedLanguage
            
            do {
                
                let newEntry = try $db.addNewEntry(language: language) {
                    $0.spelling = spelling
                }
                
                return resetSpellingAndPush(entry: newEntry.id)

            } catch {
                
                destination = .alert(.failedToAddNewEntry(
                    spelling: spelling,
                    language: language,
                    error: error
                ))

                return .none
                
            }

        }
        
        mutating func resetSpellingAndPush(entry: Entry.ID) -> EffectOf<EntryCreator> {
            
            spelling.reset()
            
            return .run { send in
                // add a little delay for the keyboard to finish dismissing
                @Dependency(\.continuousClock) var clock
                try await clock.sleep(for: .seconds(0.3))
                
                await send(.shouldPushDetail(of: entry))
            }

        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntryCreator.ConfirmationDialog>)
        case entryDetail(EntryDetail)
    }

    public enum ConfirmationDialog: Equatable {
        case cancel
        case editExisting(Entry.Expansion)
        case addNew
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case spelling(FloatingTextField.Action)
        case shouldPushDetail(of: Entry.ID)
    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Scope(state: \.spelling, action: \.spelling) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .shouldPushDetail(let id):
                
                state.destination = .entryDetail(.init(entry: id))
                
                return .none
                
            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    let spelling = state.spelling.text
                    
                    guard !spelling.isEmpty else {
                        state.spelling.reset()
                        return .none
                    }
                    
                    if let match = state.$db.firstEntry(where: \.spelling, is: spelling) {
                        
                        state.destination = .confirmationDialog(.addOrEditExisting(entry: match))

                        return .none

                    } else {
                        
                        return state.addAndPushNewEntry()
                        
                    }
                    
                }
            case .spelling: return .none
            case .destination(.presented(.confirmationDialog(.addNew))):
                
                return state.addAndPushNewEntry()

            case .destination(.presented(.confirmationDialog(.editExisting(let existing)))):
                                
                return state.resetSpellingAndPush(entry: existing.id)

            case .destination: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension AlertState {
    static func failedToAddNewEntry(spelling: String, language: Language, error: Error) -> Self where Action == Never {
        .init(
            title: {
                .init("Could not create new \(language.displayName) entry from spelling '\(spelling)'")
            },
            message: {
                .init("Error: \(error.localizedDescription)")
            }
        )
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Entry.Expansion) -> Self where Action == EntryCreator.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled '\(entry.spelling)' has already been added")
            },
            actions: {
                ButtonState<EntryCreator.ConfirmationDialog>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<EntryCreator.ConfirmationDialog>.init(
                    action: .addNew, label: { .init("Add New") }
                )
                ButtonState<EntryCreator.ConfirmationDialog>.init(
                    action: .editExisting(entry), label: { .init("Edit Existing") }
                )
            },
            message: {
                .init("Would you like to edit it, or add a new word with the same spelling?")
            }
        )
    }
}

public struct EntryCreatorView: View {
    
    @Bindable var store: StoreOf<EntryCreator>
    
    public var body: some View {
        VStack {
            
            Spacer()
                    
            FloatingTextFieldView(
                store: store.scope(state: \.spelling, action: \.spelling)
            )
            
        }
        .padding()
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
        .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) {
            EntryDetailView(store: $0)
        }
    }
}

#Preview { Preview }
private var Preview: some View {
    EntryCreatorView(store: .init(initialState: .init(), reducer: { EntryCreator() }))
}
