
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<InMemoryKey<String>> {
    public static var homeSearchField: Self { PersistenceKeyDefault(.inMemory("homeSearchField"), "") }
}

@Reducer
public struct Home {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        @Presents var destination: Destination.State?
        @Shared(.entries) var entries
        @Shared(.inputLocale) var inputLocale: Locale
        @Shared(.homeSearchField) var searchField: String
        var settingsMenu: SettingsMenu.State = .init()
        var entryCreator: EntryCreator.State = .init()
        var languageContextMenuIsShowing: Bool = false
        
        var displayed: [Entry] {
            entries
                .sorted(by: \.lastModified, reversed: true)
                .filter({
                    $0.locale == inputLocale
                })
                .filter({
                    searchField.isEmpty ? true : !$0.spelling.characterMatches(from: searchField).isEmpty
                })
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
            case .binding, .destination, .entryCreator: return .none
            case .searchFieldCommitted: return .none
            case .searchingEnded: return .none
            case .searchingStarted:
                
                state.entryCreator = .init()
                
                return .none
                
            case .entryTapped(let entry):
                
                guard let shared = state.$entries[id: entry.id] else { return .none }
                
                state.destination = .entryDetail(.init(entry: shared))
                
                return .none
                
            case .destructiveSwipeButtonTapped(let entry):
                
                state.entries.remove(entry: entry)
                
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
            ForEach(store.displayed) { entry in
                Button {
                    store.send(.entryTapped(entry))
                } label: {
                    HomeListItemView(
                        entry: entry,
                        highlightedCharacters: entry.spelling.characterMatches(from: store.searchField)
                    )
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .contentShape(Rectangle())
                }
                .swipeActions {
                    Button(
                        role: .destructive,
                        action: {
                            store.send(.destructiveSwipeButtonTapped(entry))
                        },
                        label: {
                            Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                        }
                    )
                    Button(
                        action: {
                            store.send(.editSwipeButtonTapped(entry))
                        },
                        label: {
                            Label(title: { Text("Edit") }, icon: { Image(systemName: "pencil") })
                        }
                    )
                    .tint(.yellow)
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationDestination(item: $store.scope(state: \.destination?.entryDetail, action: \.destination.entryDetail)) { store in
            EntryDetailView(store: store)
        }
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
        .modifier(PresentsSettingsMenuInToolbar(store: store.scope(state: \.settingsMenu, action: \.settingsMenu)))
    }
}

struct HomeRootView: View {
    
    @Bindable var store: StoreOf<Home>

    @Environment(\.isSearching) var isSearching

    var body: some View {
        HomeListView(
            store: store
        )
        .safeAreaInset(edge: .bottom) {
            if !isSearching {
                EntryCreatorView(store: store.scope(state: \.entryCreator, action: \.entryCreator))
            }
        }
        .navigationTitle(store.inputLocale.displayName().capitalized)
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
            HomeRootView(store: store)
                .searchable(text: $store.searchField)
        }
        .environment(\.locale, store.inputLocale)
    }
}


#Preview { Preview }
private var Preview: some View {
    @Shared(.entries) var entries = .mock()
    return HomeStackView(store: .init(initialState: .init(), reducer: { Home() }))
}
