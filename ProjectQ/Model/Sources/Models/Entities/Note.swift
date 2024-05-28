
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Note: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var value: String = ""
    var metadata: Metadata = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var entry: Entry.ID?
    }
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Note.ID { note.id }
        public let note: Shared<Note>
        public let entry: Entry?
    }
}
