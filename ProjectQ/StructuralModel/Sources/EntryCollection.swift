
import Foundation

public struct EntryCollection: Identifiable, Equatable, Codable, Sendable {
    public init(id: ID, title: String = "", description: String = "") {
        self.id = id
        self.title = title
        self.description = description
    }
    
    public let id: TaggedID<Self>
    public var title: String = ""
    public var description: String = ""
}

extension TaggedID<EntryCollection> {
    public var entityID: Entity.ID {
        .entryCollection(self)
    }
}

