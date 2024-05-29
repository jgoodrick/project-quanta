
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct EntryCreator {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.settings) var settings
        public var spelling: FloatingTextField.State = .init()
        
        @Presents public var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntryCreator.ConfirmationDialog>)
        case entryDetail(EntryDetail)
    }

    public enum ConfirmationDialog: Equatable {
        case cancel
        case editExisting(Entry)
        case addNew
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case spelling(FloatingTextField.Action)
    }
        
//    @Dependency(\.repository) var repository

    @MainActor
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Scope(state: \.spelling, action: \.spelling) {
            FloatingTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    let spelling = state.spelling.text
                    
                    guard !spelling.isEmpty else {
                        state.spelling.text = ""
                        state.spelling.collapsed = true
                        return .none
                    }
                    
                    let matches: [Entry]
                    
                    do {
                                                
//                        matches = try modelContainer.mainContext.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.spelling == spelling }))
//                        
//                        if let match = matches.first {
//                            
//                            state.destination = .confirmationDialog(.addOrEditExisting(entry: match))
//                            
//                        } else {
//                            
//                            let newEntry = try modelContainer.mainContext.insertNewEntry(
//                                spelling: spelling
//                            )
//                            
////                            newEntry.language = focusedLanguage
//                            
//                            state.destination = .entryDetail(EntryDetail.State.init(entry: newEntry))
//                            
//                        }
                        
                    } catch {
                        
                        state.destination = .alert(.init(title: { .init("Could not create new entry from spelling '\(spelling)' due to: \(error.localizedDescription)") }))
                        
                    }
                    
                    return .none
                    
                }
            case .spelling: return .none
            case .destination(.presented(.confirmationDialog(.addNew))):
                
                let spelling = state.spelling.text

                guard !spelling.isEmpty else {
                    return .none
                }
                
                do {
//                    let newEntry = try modelContainer.mainContext.insertNewEntry(
//                        spelling: state.spelling.text
//                    )
                    
//                  newEntry.language = focusedLanguage

//                    state.destination = .entryDetail(EntryDetail.State.init(entry: newEntry))
                    
                } catch {
                    
                    state.destination = .alert(.init(title: { .init("Could not add new entry with spelling '\(state.spelling.text)' due to: \(error.localizedDescription)")}))
                }
                    
                return .none

            case .destination(.presented(.confirmationDialog(.editExisting(let entry)))):
                
                // simultaneously push the entry's detail page and clear the child state
                
//                state.spelling.text = ""
//                state.spelling.collapsed = true
//
//                state.destination = .entryDetail(
//                    EntryDetail.State.init(
//                        entry: entry,
//                        languageSelectionList: state.languageSelectionList
//                    )
//                )
                
                return .none

            case .destination: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Entry) -> Self where Action == EntryCreator.ConfirmationDialog {
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
//            .environment(\.language, store.focusedLanguage)
            
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
