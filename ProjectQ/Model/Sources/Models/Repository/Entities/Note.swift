
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Note: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var value: String = ""
    var metadata: Metadata = .init()
    @CasePathable @dynamicMemberLookup
    enum Target: Equatable, Codable, Sendable {
        case entry(Entry.ID)
        case usage(Usage.ID)
    }
    struct Relationships: Equatable, Codable, Sendable {
        var target: Target?
        var isOrphan: Bool {
            target == nil
        }
    }
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Note.ID { note.id }
        public let note: Shared<Note>
        public let target: Target?
        public enum Target: Equatable, Sendable {
            case entry(Entry)
            case usage(Usage)
        }
    }
}
