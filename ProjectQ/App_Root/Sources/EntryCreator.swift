
import ComposableArchitecture
import SwiftData
import SwiftUI

@Reducer
public struct EntryCreator {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.focusedLanguage) var focusedLanguage
        public var spelling: FloatingTextField.State = .init()
        
        @Presents public var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
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
        
        case foundMatchForCurrentSpelling(Entry)
        case successfullyInserted(entry: Entry)
    }
        
    @Dependency(\.actorContext) var actorContext

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
                        state.spelling = .init()
                        return .none
                    }
                    
                    return .run { [state] send in

                        let context = try actorContext()
                        
                        let matches = try await context.fetch(FetchDescriptor<Entry>(predicate: #Predicate { $0.spelling == spelling }))

                        if let match = matches.first {

                            await send(.foundMatchForCurrentSpelling(match))

                        } else {

                            let newEntry = try await context.insertNewEntry(
                                spelling: spelling,
                                for: state.focusedLanguage
                            )

                            await send(.successfullyInserted(entry: newEntry))

                        }
                    }
                }
                    
            case .spelling: return .none
            case .destination(.presented(.confirmationDialog(.addNew))):
                
                let spelling = state.spelling.text

                guard !spelling.isEmpty else {
                    return .none
                }

                return .run { [state] send in
                                        
                    let context = try actorContext()
                    
                    let newEntry = try await context.insertNewEntry(
                        spelling: state.spelling.text,
                        for: state.focusedLanguage
                    )

                    await send(.successfullyInserted(entry: newEntry))
                }

            case .destination(.presented(.confirmationDialog(.editExisting(let entry)))):
                
                // simultaneously push the entry's detail page and clear the child state
                
                state.spelling = .init()
                
                state.destination = .entryDetail(EntryDetail.State.init(entry: entry))
                
                return .none

            case .destination: return .none
                
            case .foundMatchForCurrentSpelling(let entry):
                
                state.destination = .confirmationDialog(.addOrEditExisting(entry: entry))
                
                return .none
                
            case .successfullyInserted(let entry):

                state.destination = .entryDetail(EntryDetail.State.init(entry: entry))

                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Entry) -> Self where Action == EntryCreator.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled \"\(entry.spelling)\" has already been added")
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
            .environment(\.language, store.focusedLanguage)
            
        }
        .padding()
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
