
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Note: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var value: String = ""
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
        metadata.merge(with: incoming.metadata)
    }

    enum Target: Equatable, Codable, Sendable {
        case entry(Entry.ID)
        case usage(Usage.ID)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var target: Target?
        mutating func merge(with incoming: Self) {
            target.merge(with: incoming.target)
        }
    }
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<Note>
        public let target: Target?
        public enum Target: Equatable, Sendable {
            case entry(Entry)
            case usage(Usage)
        }
        
        public var id: Note.ID { shared.wrappedValue.id }
        public var value: String {
            get { shared.wrappedValue.value }
            set { shared.wrappedValue.value = newValue }
        }
        public var added: Date {
            get { shared.wrappedValue.metadata.added }
        }
        public var modified: Date {
            get { shared.wrappedValue.metadata.modified }
        }
    }
}
