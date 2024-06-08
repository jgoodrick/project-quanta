
import Foundation

public struct Entry: Identifiable, Equatable, Codable, Sendable {
    public init(id: UUID, spelling: String = "", alternateSpellings: [String] = []) {
        self.id = id
        self.spelling = spelling
        self.alternateSpellings = alternateSpellings
    }
    
    public let id: UUID
    public var spelling: String = ""
    public var alternateSpellings: [String] = []
}
