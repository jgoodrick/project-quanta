
import App_Root
import ComposableArchitecture
import SwiftData
import SwiftUI

@main
struct ProjectQApp: App {
    
    let container: ModelContainer
    
    static let store: StoreOf<Home> = .init(
        initialState: .init(),
        reducer: { 
            Home()
                ._printChanges()
        }
    )
    
    init() {
        @Dependency(\.modelContainer) var modelContainer
        self.container = modelContainer
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    var body: some Scene {
        WindowGroup {
            HomeStackView(store: Self.store)
        }
        .modelContainer(container)
    }
}

