
import ComposableArchitecture
import SwiftUI

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Locale>> {
    public static var inputLocale: Self { PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "inputLocale")), Locale.autoupdatingCurrent) }
}

extension PersistenceKey where Self == PersistenceKeyDefault<FileStorageKey<Array<Locale>>> {
    public static var inputLocales: Self {
        PersistenceKeyDefault(.fileStorage(.documentsDirectory.appending(component: "inputLocales.json")), {
            @Shared(.entries) var entries
            let existing = entries.sortedLocaleCounts.map(\.locale)
            return existing.isEmpty ? [.autoupdatingCurrent] : existing
        }())
    }
}

@Reducer
public struct SettingsMenu {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        @Presents var destination: Destination.State?
        @Shared(.inputLocales) var inputLocales
        @Shared(.inputLocale) var inputLocale: Locale
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case settings(Settings)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        
        case allSettingsMenuButtonTapped
        case selectedInputLocale(Locale)
    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
                
        Reduce<State, Action> { state, action in
            switch action {
            case .binding, .destination: return .none
            case .allSettingsMenuButtonTapped:
                
                state.destination = .settings(.init())
                
                return .none
                
            case .selectedInputLocale(let selected):
                
                state.inputLocale = selected
                
                return .none
                
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct PresentsSettingsMenuInToolbar: ViewModifier {
    
    @Bindable var store: StoreOf<SettingsMenu>
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem {
                    Menu {
                        
                        Button(action: { store.send(.allSettingsMenuButtonTapped) }) {
                            Text("All Settings")
                        }
                        
                        ForEach(store.inputLocales) { inputLocale in
                            Button(action: {
                                store.send(.selectedInputLocale(inputLocale))
                            }) {
                                Label(inputLocale.displayName().capitalized, systemImage: "flag")
                            }
                        }
                        
                    } label: {
                        Image(systemName: "globe")
                    }
                }
            }
            .navigationDestination(item: $store.scope(state: \.destination?.settings, action: \.destination.settings)) { store in
                SettingsView(store: store)
            }
    }
}

#Preview { Preview }
private var Preview: some View {
    NavigationStack {
        Color.clear
            .modifier(PresentsSettingsMenuInToolbar(store: .init(initialState: .init(), reducer: { SettingsMenu() })))
    }
}
