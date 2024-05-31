
import ComposableArchitecture
import Model
import SwiftUI

@Reducer
public struct AppRoot {
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public init() {
            @Shared(.db) var db
            db.seedWithLanguagesFromSystem()
        }
        
        var home: Home.State = .init()
    }
    
    public enum Action {
        case home(Home.Action)
    }
    
    public var body: some Reducer<State, Action> {
                
        Scope(state: \.home, action: \.home) {
            Home()
        }
        
        Reduce<State, Action> { state, action in
            switch action {
            case .home: return .none
            }
        }
    }
}

public struct AppRootView: View {
    
    public init(store: StoreOf<AppRoot>) {
        self.store = store
    }
    
    let store: StoreOf<AppRoot>
            
    public var body: some View {
        HomeStackView(store: store.scope(state: \.home, action: \.home))
    }
}

#Preview { Preview }
private var Preview: some View {
    return AppRootView(store: .init(initialState: .init(), reducer: { AppRoot() }))
}
