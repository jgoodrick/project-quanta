
import Foundation

public struct Note: Identifiable, Equatable, Codable, Sendable {
    public init(id: ID, value: String = "") {
        self.id = id
        self.value = value
    }
    
    public let id: TaggedID<Self>
    public var value: String = ""
}

extension TaggedID<Note> {
    public var entityID: Entity.ID {
        .note(self)
    }
}

