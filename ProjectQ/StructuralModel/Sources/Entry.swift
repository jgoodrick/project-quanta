
import Foundation

public struct Entry: Identifiable, Equatable, Codable, Sendable {
    public init(id: ID, spelling: String = "", alternateSpellings: [String] = []) {
        self.id = id
        self.spelling = spelling
        self.alternateSpellings = alternateSpellings
    }
    
    public let id: TaggedID<Self>
    public var spelling: String = ""
    public var alternateSpellings: [String] = []
}
