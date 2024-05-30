
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Metadata: Equatable, Codable, Sendable, Mergeable {
    init() {
        @Dependency(\.date) var date
        let now = date.now
        self.added = now
        self.modified = now
    }
    
    fileprivate(set) var added: Date
    var modified: Date
    
    mutating func updateModified() {
        @Dependency(\.date) var date
        modified = date.now
    }
    mutating func merge(with incoming: Metadata) {
        let previous = self
        added = min(added, incoming.added)
        modified = max(modified, incoming.modified)
        if self != previous {
            updateModified()
        }
    }
}
