
import Foundation

public struct Metadata: Hashable, Codable, Sendable {
    init(now: Date) {
        self.added = now
        self.modified = now
    }
    
    public var added: Date
    public var modified: Date
}

extension Metadata: Mergeable {
    public mutating func merge(with incoming: Metadata) {
        added = min(added, incoming.added)
        modified = max(modified, incoming.modified)
    }
}

@dynamicMemberLookup
public struct Tracked<Value> {
    public var value: Value
    public var metadata: Metadata
    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
      self.value[keyPath: keyPath]
    }
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
}
extension Tracked {
    public init(value: Value, now: Date) {
        self.init(value: value, metadata: .init(now: now))
    }
}
