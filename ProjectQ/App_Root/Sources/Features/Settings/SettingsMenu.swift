
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct SettingsMenu {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {}
        @Shared(.settings) var settings
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case settings(Settings)
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        
        case allSettingsMenuButtonTapped
        case selectedInputLanguage(Language)
    }
    
    public var body: some Reducer<State, Action> {
        
        BindingReducer()
                
        Reduce<State, Action> { state, action in
            switch action {
            case .binding, .destination: return .none
            case .allSettingsMenuButtonTapped:
                
//                state.destination = .settings(.init())
                
                return .none
                
            case .selectedInputLanguage(let selected):
                
//                state.focusedLanguage = selected
                
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
                        
                        ForEach(store.settings.languageSelectionList) { availableLanguage in
                            Button(action: {
                                store.send(.selectedInputLanguage(availableLanguage))
                            }) {
                                Label(availableLanguage.displayName.capitalized, systemImage: "flag")
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
