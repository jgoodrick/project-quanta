
import ComposableArchitecture
import EntryDetailFeature
import FeatureCore
import LayoutCore
import ModelCore
import RelationalCore
import SettingsFeature
import SwiftUI

@Reducer
public struct Home {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        @Shared(.db) var db
        @Shared(.settings) var settings
        
        var searchField: String = ""
        var settingsMenu: SettingsMenu.State = .init()
        var entryCreator: EntryCreator.State = .init()
        var languageContextMenuIsShowing: Bool = false
        
        @Presents var destination: Destination.State?
        
        var displayedEntries: [Item] {
            db.entries(forLanguage: settings.focusedLanguage.id).map({
                Item(
                    entry: $0,
                    topTranslation: db.translations(forEntry: $0.id).first
                )
            })
        }
        
        struct Item: Identifiable, HomeListItem {
            let entry: Entry
            let topTranslation: Entry?
            var id: Entry.ID { entry.id }
            var title: String { entry.spelling }
            var subtitle: String? { topTranslation?.spelling }
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Never>)
        case confirmationDialog(ConfirmationDialogState<Home.Action.Dialog>)
        case entryDetail(EntryDetail)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case settingsMenu(SettingsMenu.Action)
        case entryCreator(EntryCreator.Action)
        case destination(PresentationAction<Destination.Action>)
                
        case searchFieldCommitted
        case searchingEnded
        case searchingStarted
                
        case entryTapped(Entry)
        case destructiveSwipeButtonTapped(Entry)
        case editSwipeButtonTapped(Entry)
        
        case dialog(Dialog)
        public enum Dialog {
            case deletionConfirmed
        }

    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
        
        Scope(state: \.settingsMenu, action: \.settingsMenu) {
            SettingsMenu()
        }
        
        Scope(state: \.entryCreator, action: \.entryCreator) {
            EntryCreator()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .binding: return .none
            case .destination: return .none
            case .entryCreator: return .none
            case .searchFieldCommitted: return .none
            case .searchingEnded: return .none
            case .searchingStarted:
                
                state.entryCreator = .init()
                
                return .none
                
            case .entryTapped(let entry):
                
                state.entryCreator = .init()
                
                state.destination = .entryDetail(.init(
                    entry: entry.id,
                    translationsEditorFocused: false
                ))
                
                return .none
                
            case .destructiveSwipeButtonTapped(let entry):
                
                state.db.delete(.entry(entry.id))
                
                return .none
                
            case .editSwipeButtonTapped(_): return .none
            case .dialog(_): return .none
            case .settingsMenu(.allSettingsMenuButtonTapped):
                
                state.entryCreator = .init()
                
                return .none
                
            case .settingsMenu: return .none
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

struct HomeListView: View {
    
    @Bindable var store: StoreOf<Home>
            
    public var body: some View {
        List {
            ForEach(store.displayedEntries) { item in
                Button {
                    store.send(.entryTapped(item.entry))
                } label: {
                    HomeListItemView(
                        item: item,
                        highlightedCharacters: item.entry.spelling.characterMatches(from: store.searchField)
                    )
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .contentShape(Rectangle())
                }
                #if !os(tvOS)
                .swipeActions {
                    Button(
                        role: .destructive,
                        action: {
                            store.send(.destructiveSwipeButtonTapped(item.entry))
                        },
                        label: {
                            Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                        }
                    )
                    Button(
                        action: {
                            store.send(.editSwipeButtonTapped(item.entry))
                        },
                        label: {
                            Label(title: { Text("Edit") }, icon: { Image(systemName: "pencil") })
                        }
                    )
                    .tint(.yellow)
                }
                #endif
            }
            #if !os(tvOS) && !os(watchOS)
            .listRowSeparator(.hidden)
            #endif
        }
        .listStyle(.plain)
        .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) { store in
            EntryDetailView(store: store)
        }
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
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
        .modifier(PresentsSettingsMenuInToolbar(store: store.scope(state: \.settingsMenu, action: \.settingsMenu)))
        .safeAreaInset(edge: .bottom) {
            if !isSearching {
                EntryCreatorView(store: store.scope(state: \.entryCreator, action: \.entryCreator))
            }
        }
        .navigationTitle(store.settings.focusedLanguage.displayName.capitalized)
        .onSubmit(of: .search) {
            store.send(.searchFieldCommitted)
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .onChange(of: isSearching, { old, new in
            if old, !new {
                store.send(.searchingEnded)
            } else if new, !old {
                store.send(.searchingStarted)
            }
        })
    }
}

public struct HomeStackView: View {
    
    public init(store: StoreOf<Home>) {
        self.store = store
    }
    
    @Bindable var store: StoreOf<Home>

    public var body: some View {
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
