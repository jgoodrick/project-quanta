
import Foundation

public struct EntryCollection: Identifiable, Equatable, Codable, Sendable {
    public init(id: UUID, title: String = "", description: String = "") {
        self.id = id
        self.title = title
        self.description = description
    }
    
    public let id: UUID
    public var title: String = ""
    public var description: String = ""
}

