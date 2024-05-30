
@testable import App_Root
import ComposableArchitecture
import XCTest

final class Home_Tests: XCTestCase {
    
    let showSkippedAssertions: Bool = false
    
    @MainActor
    func test_task() async throws {
        
        let store = TestStore(initialState: Home.State()) {
            Home()
        }
        
        store.exhaustivity = .off(showSkippedAssertions: showSkippedAssertions)

    }
    
}

