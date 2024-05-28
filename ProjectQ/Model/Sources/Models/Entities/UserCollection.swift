
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct UserCollection: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    var title: String
    var metadata: Metadata = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var entries: [Entry.ID] = []
    }
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: UserCollection.ID { userCollection.id }
        public let userCollection: Shared<UserCollection>
        public let entries: [Entry]
    }
}

