
import ComposableArchitecture
import AppModel
import SwiftUI

@main
struct ProjectQ: App {

    @MainActor
    static let store: StoreOf<Home> = .init(
        initialState: .init(),
        reducer: { 
            Home()
//                ._printChanges()
        }
    )
    
    var body: some Scene {
        WindowGroup {
            if isTesting {
                // NB: Don't run application in tests to avoid interference
                //     between the app and the test.
                EmptyView()
            } else {
                HomeStackView(store: Self.store)
            }
        }
    }
}
