
import AppModel
import ComposableArchitecture
import XCTest

class AppModelTestCase: XCTestCase {
    
    override func invokeTest() {
        withDependencies {
            $0.uuid = .incrementing
            $0.date = .constant(.distantPast)
            $0.locale = .current
        } operation: {
            super.invokeTest()
        }
    }
    
}
