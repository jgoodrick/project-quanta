
import ComposableArchitecture
import AppModel
import SwiftUI
import LayoutCore

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
    
    @State private var destinationIsShowing: Bool = true
    var body: some Scene {
        WindowGroup {
            if isTesting {
                // NB: Don't run application in tests to avoid interference
                //     between the app and the test.
                EmptyView()
            } else {
                HomeStackView(store: Self.store)
            }
//            HomeStackView(store: Self.store)
            NavigationStack {
                Text("Root").navigationDestination(isPresented: $destinationIsShowing) {
                    NewEntryDetailView()
                    .toolbar { EditButton() }
                }
            }

        }
    }
}
