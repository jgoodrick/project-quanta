
import Foundation

public struct Keyword: Identifiable, Equatable, Codable, Sendable {
    public init(id: UUID, title: String = "") {
        self.id = id
        self.title = title
    }
    
    public let id: UUID
    public var title: String = ""
}
