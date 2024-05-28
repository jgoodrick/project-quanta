
import App_Root
import ComposableArchitecture
import SwiftUI

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

