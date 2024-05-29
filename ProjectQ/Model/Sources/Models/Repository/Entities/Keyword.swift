
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Keyword: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var title: String = ""
    var metadata: Metadata = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var matches: [Entry.ID] = []
        var isOrphan: Bool {
            matches.isEmpty
        }
    }
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Keyword.ID { keyword.id }
        public let keyword: Shared<Keyword>
        public let matches: [Entry]
    }
}
