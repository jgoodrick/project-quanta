
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct User: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var name: String = ""

    var metadata: Metadata = .init()
    
    mutating func merge(with incoming: Self) {
        name.merge(with: incoming.name)
        metadata.merge(with: incoming.metadata)
    }

    struct Relationships: Equatable, Codable, Sendable, RelationshipSet {
        var languages: [Language.ID] = []
        mutating func merge(with incoming: Self) {
            languages.merge(with: incoming.languages)
        }
    }
    
    public struct Expansion: Identifiable, Equatable, Sendable {
        public var shared: Shared<User>
        public let languages: [Language]
        
        public var id: User.ID { shared.wrappedValue.id }
        public var name: String {
            get { shared.wrappedValue.name }
            set { shared.wrappedValue.name = newValue }
        }
        public var added: Date {
            get { shared.wrappedValue.metadata.added }
        }
        public var modified: Date {
            get { shared.wrappedValue.metadata.modified }
        }
    }
}
