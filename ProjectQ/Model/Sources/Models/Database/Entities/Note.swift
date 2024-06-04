
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Note: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var value: String = ""
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
        metadata.merge(with: incoming.metadata)
    }

    public enum Target: Hashable, Codable, Sendable {
        case entry(Entry.ID)
        case usage(Usage.ID)
    }
    
    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var targets: Set<Target> = []
        mutating func merge(with incoming: Self) {
            targets.merge(with: incoming.targets)
        }
    }
    public struct Expansion: Identifiable, Equatable, Sendable {
        @Shared public var shared: Note
        public let targets: Set<Target>
        
        public var id: Note.ID { shared.id }
        public var value: String {
            get { shared.value }
            set { shared.value = newValue }
        }
        public var added: Date {
            get { shared.metadata.added }
        }
        public var modified: Date {
            get { shared.metadata.modified }
        }
        public var bound: Binding<Note> {
            .init(
                get: { shared },
                set: { shared = $0}
            )
        }
    }
}
