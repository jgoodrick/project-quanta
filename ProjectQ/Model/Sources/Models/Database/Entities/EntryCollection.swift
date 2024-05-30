
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct EntryCollection: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var title: String = ""
    var description: String = ""
    
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        title.merge(with: incoming.title)
        description.merge(with: incoming.description)
        metadata.merge(with: incoming.metadata)
    }
    

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var entries: [Entry.ID] = []
        mutating func merge(with incoming: Self) {
            entries.merge(with: incoming.entries)
        }
    }
    
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<EntryCollection>
        public let entries: [Entry]
        
        public var id: EntryCollection.ID { shared.wrappedValue.id }
        public var title: String {
            get { shared.wrappedValue.title }
            set { shared.wrappedValue.title = newValue }
        }
        public var description: String {
            get { shared.wrappedValue.description }
            set { shared.wrappedValue.description = newValue }
        }
        public var added: Date {
            get { shared.wrappedValue.metadata.added }
        }
        public var modified: Date {
            get { shared.wrappedValue.metadata.modified }
        }
    }
}

