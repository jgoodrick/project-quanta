
import ComposableArchitecture
import EntryDetailFeature
import FeatureCore
import ModelCore
import RelationalCore
import SwiftUI

@Reducer
public struct EntryCreationEditor {
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        
        @Shared(.db) var db
        @Shared(.settings) var settings
        public var spelling: ToolbarTextField.State = .init()
        
        @Presents public var destination: Destination.State?
        
        public mutating func reset() {
            spelling.reset()
        }
        
        mutating func addAndPushNewEntry() -> EffectOf<EntryCreationEditor> {
            
            let spelling = spelling.text
            let language = settings.focusedLanguage
            
            let newEntry = db.createNewEntry(language: language) {
                $0.spelling = spelling
            }
            
            return resetSpellingAndPush(entry: newEntry.id, translationsEditorFocused: true)

        }
        
        mutating func resetSpellingAndPush(entry: Entry.ID, translationsEditorFocused: Bool) -> EffectOf<EntryCreationEditor> {
            
            spelling.reset()
            
            return .run { send in
                // add a little delay for the keyboard to finish dismissing
                @Dependency(\.continuousClock) var clock
                try await clock.sleep(for: .seconds(0.3))
                
                await send(.shouldPushDetail(of: entry, translationsEditorFocused: translationsEditorFocused))
            }

        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<EntryCreationEditor.ConfirmationDialog>)
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
        case spelling(ToolbarTextField.Action)
        case shouldPushDetail(of: Entry.ID, translationsEditorFocused: Bool)
    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Scope(state: \.spelling, action: \.spelling) {
            ToolbarTextField()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .shouldPushDetail(let id, let translationsEditorFocused):
                
                state.destination = .entryDetail(.init(
                    entry: id,
                    translationsEditorFocused: translationsEditorFocused
                ))
                
                return .none
                
            case .spelling(.delegate(let delegatedAction)):
                switch delegatedAction {
                case .fieldCommitted, .saveEntryButtonTapped:
                    
                    let spelling = state.spelling.text
                    
                    guard !spelling.isEmpty else {
                        state.spelling.reset()
                        return .none
                    }
                    
                    if let match = state.db.firstEntry(where: { $0.spelling == spelling }) {

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
                                
                return state.resetSpellingAndPush(entry: existing.id, translationsEditorFocused: false)

            case .destination: return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Entry) -> Self where Action == EntryCreationEditor.ConfirmationDialog {
        .init(
            title: {
                .init("A word spelled '\(entry.spelling)' has already been added")
            },
            actions: {
                ButtonState<EntryCreationEditor.ConfirmationDialog>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<EntryCreationEditor.ConfirmationDialog>.init(
                    action: .addNew, label: { .init("Add New") }
                )
                ButtonState<EntryCreationEditor.ConfirmationDialog>.init(
                    action: .editExisting(entry), label: { .init("Edit Existing") }
                )
            },
            message: {
                .init("Would you like to edit it, or add a new word with the same spelling?")
            }
        )
    }
}

public struct EntryCreationEditorInstaller: ViewModifier {
    
    @Bindable var store: StoreOf<EntryCreationEditor>
    
    @Environment(\.isSearching) var isSearching
    
    public func body(content: Content) -> some View {
        content
            #if os(iOS)
            .safeAreaInset(edge: .bottom) {
                if !isSearching {
                    ToolbarTextFieldView(
                        store: store.scope(state: \.spelling, action: \.spelling),
                        placeholder: "New Entry"
                    )
                    .padding()
                    .padding()
                }
            }
            #endif
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
            .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
            .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) {
                EntryDetailView(store: $0)
            }
    }
}

#Preview { Preview }
private var Preview: some View {
    Color.red.modifier(
        EntryCreationEditorInstaller(store: .init(initialState: .init(), reducer: { EntryCreationEditor() }))
    )
}
