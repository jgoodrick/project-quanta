
import Foundation

public struct TaggedID<Tag>: Equatable, Hashable, Sendable, Codable, CustomStringConvertible, RawRepresentable {
    
    public var rawValue: UUID
    
    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }
    
    public static func tagged(_ rawValue: UUID) -> Self {
        Self.init(rawValue: rawValue)
    }
    
    public static func mock(_ mock: Int) -> Self {
        Self.init(rawValue: .mock(mock))
    }
    
    public var description: String {
        return self.rawValue.last(4)
    }

    public init(from decoder: Decoder) throws {
        do {
            self.init(rawValue: try decoder.singleValueContainer().decode(UUID.self))
        } catch {
            self.init(rawValue: try .init(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.singleValueContainer()
            try container.encode(self.rawValue)
        } catch {
            try self.rawValue.encode(to: encoder)
        }
    }
    
    public var uuidString: String { rawValue.uuidString }

    public func ported<V>() -> TaggedID<V> {
        .init(rawValue: self.rawValue)
    }
    
}

public extension TaggedID {
    func last(_ count: Int) -> String { "\(rawValue.last(count))" }
}

public extension UUID {
    func last(_ count: Int) -> String { "\(uuidString.suffix(count))" }
}

extension UUID {
    public static func mock(_ intValue: Int) -> Self {
        self.init(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", intValue))")!
    }
}
