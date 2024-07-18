
import ComposableArchitecture
import SwiftUI
import LayoutCore

@main
struct ProjectQ: App {
        
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

