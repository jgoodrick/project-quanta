
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Keyword: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var title: String = ""
    
    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        title.merge(with: incoming.title)
        metadata.merge(with: incoming.metadata)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var matches: [Entry.ID] = []
        mutating func merge(with incoming: Self) {
            matches.merge(with: incoming.matches)
        }
    }
    
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<Keyword>
        public let matches: [Entry]
        
        public var id: Keyword.ID { shared.wrappedValue.id }
        public var title: String {
            get { shared.wrappedValue.title }
            set { shared.wrappedValue.title = newValue }
        }
        public var added: Date {
            get { shared.wrappedValue.metadata.added }
        }
        public var modified: Date {
            get { shared.wrappedValue.metadata.modified }
        }
    }
}
