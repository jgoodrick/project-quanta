
import Foundation

public struct Keyword: Identifiable, Equatable, Codable, Sendable {
    public init(id: ID, title: String = "") {
        self.id = id
        self.title = title
    }
    
    public let id: TaggedID<Self>
    public var title: String = ""
}
