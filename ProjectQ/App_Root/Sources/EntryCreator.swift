
import ComposableArchitecture
import SwiftUI

@Reducer
public struct EntryCreator {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.entries) var entries
        @Shared(.inputLocale) var inputLocale
        
        public var spelling: FloatingTextField.State = .init()
        
        @Presents var destination: Destination.State?
        
        mutating func addSpellingAsNewEntryAndPush() -> EffectOf<EntryCreator> {
            
            @Dependency(\.uuid) var uuid
            @Dependency(\.date.now) var now

            // create the new entry and add it to the repository
            let entry = Entry(
                id: uuid(),
                locale: inputLocale,
                added: now,
                lastModified: now,
                spelling: spelling.text
            )
            let sharedEntry = $entries.add(new: entry)
            
            return clearAndPushDetailFor(entry: sharedEntry)

        }
        
        /// simultaneously pushes the entry's detail page and clears the creator's state
        mutating func clearAndPushDetailFor(entry: Shared<Entry>) -> EffectOf<EntryCreator> {
            
            self = .init()

            destination = .entryDetail(EntryDetail.State.init(entry: entry))
            
            return .none

        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case confirmationDialog(ConfirmationDialogState<EntryCreator.ConfirmationDialog>)
        case entryDetail(EntryDetail)
    }

    public enum ConfirmationDialog: Equatable {
        case cancel
        case editExisting(Shared<Entry>)
        case addNew
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case spelling(FloatingTextField.Action)
        
        case delayBeforePushShouldStartCompleted(Shared<Entry>)
    }
        
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
                    
                    if let match = state.$entries.matching(spelling: state.spelling.text) {
                        
                        return state.clearAndPushDetailFor(entry: match)
                        
                    } else if !state.spelling.text.isEmpty {
                        
                        return state.addSpellingAsNewEntryAndPush()
                        
                    } else {
                        
                        state.spelling = .init()
                        
                        return .none
                        
                    }
                    
                }
            case .spelling: return .none
            case .destination(.presented(.confirmationDialog(.addNew))):
                
                return state.addSpellingAsNewEntryAndPush()

            case .destination(.presented(.confirmationDialog(.editExisting(let entry)))):
                
                return state.clearAndPushDetailFor(entry: entry)

            case .destination: return .none
                
            case .delayBeforePushShouldStartCompleted(let entry):
                
                state.destination = .entryDetail(EntryDetail.State.init(entry: entry))
                
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Shared<Entry>) -> Self where Action == EntryCreator.ConfirmationDialog {
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
