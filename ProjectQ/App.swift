
import ComposableArchitecture
import SwiftUI

@main
struct ProjectQ: App {
        
    static let store: StoreOf<Home> = .init(
        initialState: .init(),
        reducer: { 
            Home()
//                ._printChanges()
        }
    )
    
    var body: some Scene {
        WindowGroup {
            HomeStackView(store: Self.store)
        }
    }
}

