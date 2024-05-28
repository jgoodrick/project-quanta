
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Usage: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var value: String = ""
    
    var metadata: Metadata = .init()
    
    struct Relationships: Equatable, Codable, Sendable {
        var note: Note.ID? = nil
        var uses: Set<Entry.ID> = []
    }
    
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Usage.ID { usage.id }
        public let usage: Shared<Usage>
        public let note: Note?
        public let uses: [Entry]
    }
}

