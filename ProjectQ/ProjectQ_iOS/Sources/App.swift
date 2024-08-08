
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
    
    @State private var destinationIsShowing: Bool = false
    var body: some Scene {
        WindowGroup {
//            HomeStackView(store: Self.store)
            NavigationStack {
                Button("Root") {
                    $destinationIsShowing.wrappedValue = true
                }.navigationDestination(isPresented: $destinationIsShowing) {
                    NewEntryDetailView()
                    .toolbar { EditButton() }
                }
            }

        }
    }
}

