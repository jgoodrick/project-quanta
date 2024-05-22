
import ComposableArchitecture
import SwiftUI
import App_Root

@main
struct ProjectQApp: App {
    
    static let store: StoreOf<Home> = .init(
        initialState: .init(),
        reducer: { 
            Home()
                ._printChanges()
        }
    )
    
    var body: some Scene {
        WindowGroup {
            HomeStackView(store: Self.store)
        }
    }
}

