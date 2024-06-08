
import Foundation

public struct Usage: Identifiable, Equatable, Codable, Sendable {
    public init(id: UUID, value: String = "") {
        self.id = id
        self.value = value
    }
    
    public let id: UUID
    public var value: String = ""
}
