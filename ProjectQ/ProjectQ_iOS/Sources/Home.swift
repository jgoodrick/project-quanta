
import AppModel
import ComposableArchitecture
import Foundation
import LayoutCore
import StructuralModel
import SwiftUI

@Reducer
struct Home {
    
    @ObservableState
    struct State: Equatable {
        
        var searchField: String = ""
        var toolbarText: String = ""
        var toolbarTextFieldIsFocused: Bool = false
        
        mutating func resetToolbarTextField() {
            toolbarText = ""
            toolbarTextFieldIsFocused = false
            print("resetting toolbar")
        }

        mutating func addAndPushNewEntry() -> EffectOf<Home> {
                
            switch model.addNewEntry(fromSpelling: toolbarText) {
            case .canceled: return .none
            case .conflicts(let conflictingEntries):
                
                guard let first = conflictingEntries.first else {
                    assertionFailure()
                    return .none
                }
                
                destination = .addEntryConflictChoices(.addOrEditExisting(entry: first))
                
                return .none
                
            case .success(let newEntry):
                
                return resetSpellingAndPush(
                    entry: newEntry.id,
                    translationsEditorFocused: true
                )
                
            }
            
        }

        mutating func resetSpellingAndPush(entry: Entry.ID, translationsEditorFocused: Bool) -> EffectOf<Home> {

            resetToolbarTextField()

            return .run { send in
                // add a little delay for the keyboard to finish dismissing
                @Dependency(\.continuousClock) var clock
                try await clock.sleep(for: .seconds(0.3))

                await send(.shouldPushDetail(of: entry, translationsEditorFocused: translationsEditorFocused))
            }

        }

        @Shared(.model) var model
        @Presents var destination: Destination.State?
        
        var displayedEntries: [Item] {
            model.entries(.all).map({
                Item(
                    entry: $0,
                    topTranslation: model.entries(.thatAre(.translations(of: $0.id))).first
                )
            })
        }
        
        struct Item: Identifiable, EntryListItem {
            let entry: Entry
            let topTranslation: Entry?
            var id: Entry.ID { entry.id }
            var title: String { entry.spelling }
            var subtitle: String? { topTranslation?.spelling }
        }
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case alert(AlertState<Never>)
        case deletionConfirmationChoices(ConfirmationDialogState<DeletionConfirmationChoice>)
        case addEntryConflictChoices(ConfirmationDialogState<AddEntryConflictChoice>)
        case entryDetail(EntryDetail)
        case settingsEditor(SettingsEditor)
    }
    
    public enum AddEntryConflictChoice: Equatable {
        case cancel
        case editExisting(Entry)
        case addNew
    }

    public enum DeletionConfirmationChoice: Equatable {
        case cancel
        case deletionConfirmed
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        
        case allSettingsMenuButtonTapped
        case selectedInputLanguage(Language)
        case shouldPushDetail(of: Entry.ID, translationsEditorFocused: Bool)
        
        case textInputCouldNotMatchLanguage(id: String)
        case toolbarTextFieldSaveButtonTapped
        case toolbarTextFieldSubmitted
        case tappedOutsideActiveToolbarTextField
                
        case searchFieldCommitted
        case searchingEnded
        case searchingStarted
        
        case entryTapped(Entry)
        case destructiveSwipeButtonTapped(Entry)
        case editSwipeButtonTapped(Entry)
        
    }
    
    var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
            case .searchFieldCommitted: return .none
            case .searchingEnded: return .none
            case .searchingStarted:
                
                state.resetToolbarTextField()
                
                return .none
                
            case .entryTapped(let entry):
                
                state.resetToolbarTextField()
                
                state.destination = .entryDetail(.init(
                    entry: entry.id,
                    translationsEditorFocused: false
                ))
                
                return .none
                
            case .destructiveSwipeButtonTapped(let entry):
                
                state.model.delete(.entry(entry.id))
                
                return .none
                
            case .editSwipeButtonTapped(let entry):
                
                state.resetToolbarTextField()
                
                state.destination = .entryDetail(.init(
                    entry: entry.id,
                    translationsEditorFocused: false
                ))

                return .none
                
            case .allSettingsMenuButtonTapped:

                state.resetToolbarTextField()
                
                state.destination = .settingsEditor(.init())
                
                return .none
                
            case .selectedInputLanguage(let selected):
                
                state.model.settings.defaultNewEntryLanguage = selected
                
                return .none
                
            case .shouldPushDetail(let entry, let translationsEditorFocused):
                
                state.destination = .entryDetail(
                    .init(
                        entry: entry,
                        translationsEditorFocused: translationsEditorFocused
                    )
                )
                
                return .none
             
            case .textInputCouldNotMatchLanguage(let id):
                
                // TODO: show an alert
                // - informs the user they need to go to Settings/General/Keyboard and add a keyboard for the given language. Persist user decision so it only shows up once
                
                print("Could not switch keyboard input to match: \(id)")
                
                return .none
                
            case .toolbarTextFieldSaveButtonTapped, .toolbarTextFieldSubmitted:
                
                guard !state.toolbarText.isEmpty else {
                    state.resetToolbarTextField()
                    return .none
                }
                
                return state.addAndPushNewEntry()
                
            case .tappedOutsideActiveToolbarTextField:
                
                state.resetToolbarTextField()
                
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

fileprivate extension String {
    var characters: Set<Character> {
        (unicodeScalars.map({Character($0)}) + lowercased() + uppercased()).reduce(into: [], { $0.insert($1) })
    }
    func characterMatches(from search: String) -> Set<Character> {
        self.characters.intersection(search.characters)
    }
}

extension ConfirmationDialogState {
    static func addOrEditExisting(entry: Entry) -> Self where Action == Home.AddEntryConflictChoice {
        .init(
            title: {
                .init("A word spelled '\(entry.spelling)' has already been added")
            },
            actions: {
                ButtonState<Home.AddEntryConflictChoice>.init(
                    action: .cancel, label: { .init("Cancel") }
                )
                ButtonState<Home.AddEntryConflictChoice>.init(
                    action: .addNew, label: { .init("Add New") }
                )
                ButtonState<Home.AddEntryConflictChoice>.init(
                    action: .editExisting(entry), label: { .init("Edit Existing") }
                )
            },
            message: {
                .init("Would you like to edit it, or add a new word with the same spelling?")
            }
        )
    }
}

struct HomeListView: View {
    
    @Bindable var store: StoreOf<Home>
            
    var body: some View {
        List {
            ForEach(store.displayedEntries) { item in
                Button {
                    store.send(.entryTapped(item.entry))
                } label: {
                    EntryListItemView(
                        item: item,
                        highlightedCharacters: item.entry.spelling.characterMatches(from: store.searchField)
                    )
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .contentShape(Rectangle())
                }
                .modifier(DeleteSwipeAction_tvOS_excluded {
                    store.send(.destructiveSwipeButtonTapped(item.entry))
                })
                .modifier(EditSwipeAction_tvOSexcluded {
                    store.send(.editSwipeButtonTapped(item.entry))
                })
            }
            .modifier(HideListRowSeparators())
        }
        .listStyle(.plain)
    }
}

struct HomeDestinationsModifier: ViewModifier {

    @Bindable var store: StoreOf<Home>

    func body(content: Content) -> some View {
        content
            .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) { store in
                EntryDetailView(store: store)
            }
            .navigationDestination(item: $store.scope(state: \.destination?.settingsEditor, action: \.destination.settingsEditor)) { store in
                SettingsEditorView(store: store)
            }
            .modifier(PresentsSettingsMenuInToolbar(store: store))
            .confirmationDialog($store.scope(state: \.destination?.addEntryConflictChoices, action: \.destination.addEntryConflictChoices))
            .confirmationDialog($store.scope(state: \.destination?.deletionConfirmationChoices, action: \.destination.deletionConfirmationChoices))
            .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

struct HomeStackRootView: View {
    
    @Bindable var store: StoreOf<Home>

    @Environment(\.isSearching) var isSearching

    var body: some View {
        Group {
            if store.displayedEntries.isEmpty {
                ContentUnavailableView("No Entries Yet", systemImage: "tray", description: Text("Select your language above or tap on the plus symbol below to add your first entry to this language!"))
            } else {
                HomeListView(
                    store: store
                )
            }
        }
        .modifier(
            ToolbarTextFieldInstaller(
                placeholder: "New Entry",
                language: store.model.settings.defaultNewEntryLanguage,
                text: $store.toolbarText,
                focused: $store.toolbarTextFieldIsFocused,
                installed: !isSearching,
                onLanguageUnavailable: { store.send(.textInputCouldNotMatchLanguage(id: $0)) },
                onSaveButtonTapped: { store.send(.toolbarTextFieldSaveButtonTapped) },
                onSubmit: { store.send(.toolbarTextFieldSubmitted) },
                tappedViewBehindActiveToolbarTextField: { store.send(.tappedOutsideActiveToolbarTextField) },
                autocapitalization: .none
            )
        )
        .navigationTitle(store.model.displayNameForDefaultNewEntryLanguage.capitalized)
        .onSubmit(of: .search) {
            store.send(.searchFieldCommitted)
        }
        .modifier(HomeDestinationsModifier(store: store))
        .onChange(of: isSearching, { old, new in
            if old, !new {
                store.send(.searchingEnded)
            } else if new, !old {
                store.send(.searchingStarted)
            }
        })
    }
}

struct PresentsSettingsMenuInToolbar: ViewModifier {
    
    init(store: StoreOf<Home>) {
        self.store = store
    }
    
    @Bindable var store: StoreOf<Home>
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Menu {
                        
                        Button(action: { store.send(.allSettingsMenuButtonTapped) }) {
                            Text("All Settings")
                        }
                        
                        ForEach(store.model.settings.languageSelectionList) { availableLanguage in
                            Button(action: {
                                store.send(.selectedInputLanguage(availableLanguage))
                            }) {
                                Label("availableLanguage.displayName(locale: .current)".capitalized, systemImage: "flag")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "globe")
                    }
                }
            }
    }
}

struct HomeStackView: View {
    
    @Bindable var store: StoreOf<Home>

    var body: some View {
        NavigationStack {
            HomeStackRootView(store: store)
                .searchable(text: $store.searchField)
        }
    }
}


#Preview { Preview }
private var Preview: some View {
    return HomeStackView(store: .init(initialState: .init(), reducer: { Home() }))
}
