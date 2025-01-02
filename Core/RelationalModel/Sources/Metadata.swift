
import Foundation

struct Metadata: Hashable, Codable, Sendable {
    init(now: Date) {
        self.created = now
        self.modified = now
    }
    
    var created: Date
    var modified: Date
}

extension Metadata: Mergeable {
    mutating func merge(with incoming: Metadata) {
        created = min(created, incoming.created)
        modified = max(modified, incoming.modified)
    }
}

public struct Tracked<Value> {
    var value: Value
    var metadata: Metadata
}

extension Tracked: Mergeable where Value: Mergeable {
    mutating func merge(with incoming: Self) {
        value.merge(with: incoming.value)
        metadata.merge(with: incoming.metadata)
    }
}

extension Tracked: Equatable where Value: Equatable {}
extension Tracked: Encodable where Value: Encodable {}
extension Tracked: Decodable where Value: Decodable {}
extension Tracked: Sendable where Value: Sendable {}
extension Tracked: Hashable where Value: Hashable {}
extension Tracked: Identifiable where Value: Identifiable {
    public var id: Value.ID { value.id }
    public var modified: Date { metadata.modified }
    public var created: Date { metadata.created }
}
extension Tracked {
    init(value: Value, now: Date) {
        self.init(value: value, metadata: .init(now: now))
    }
}
