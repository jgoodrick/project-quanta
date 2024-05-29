
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Metadata: Equatable, Codable, Sendable {
    init() {
        @Dependency(\.date) var date
        let now = date.now
        self.added = now
        self.modified = now
    }
    
    let added: Date
    var modified: Date
}
