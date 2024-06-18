
import AppRoot
import ComposableArchitecture
import SwiftUI

@main
struct ProjectQApp: App {
        
    static let store: StoreOf<AppRoot> = .init(
        initialState: .init(),
        reducer: { 
            AppRoot()
//                ._printChanges()
        }
    )
    
    var body: some Scene {
        WindowGroup {
            AppRootView(store: Self.store)
        }
    }
}

