
import Foundation

struct Metadata: Hashable, Codable, Sendable {
    init(now: Date) {
        self.added = now
        self.modified = now
    }
    
    var added: Date
    var modified: Date
}

extension Metadata: Mergeable {
    mutating func merge(with incoming: Metadata) {
        added = min(added, incoming.added)
        modified = max(modified, incoming.modified)
    }
}

struct Tracked<Value> {
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
    var id: Value.ID { value.id }
}
extension Tracked {
    init(value: Value, now: Date) {
        self.init(value: value, metadata: .init(now: now))
    }
}
