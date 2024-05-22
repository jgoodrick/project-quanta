
@testable import App_Root
import ComposableArchitecture
import XCTest

final class AppRoot_Tests: XCTestCase {
    
    let showSkippedAssertions: Bool = false
    
    @MainActor
    func test_task() async throws {
        
        let store = TestStore(initialState: AppRoot.State()) {
            AppRoot()
        }
        
        store.exhaustivity = .off(showSkippedAssertions: showSkippedAssertions)

        await store.send(\.task)

    }
    
}

