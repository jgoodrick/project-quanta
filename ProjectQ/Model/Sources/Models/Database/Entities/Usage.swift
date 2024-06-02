
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Usage: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var value: String = ""
    
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
        metadata.merge(with: incoming.metadata)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var note: Note.ID? = nil
        var uses: Set<Entry.ID> = []
        mutating func merge(with incoming: Self) {
            note.merge(with: incoming.note)
            uses.merge(with: incoming.uses)
        }
    }
    
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<Usage>
        public let note: Note?
        public let uses: [Entry]
        
        public var id: Usage.ID { shared.wrappedValue.id }
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

