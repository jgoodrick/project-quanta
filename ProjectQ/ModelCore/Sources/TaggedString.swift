
public struct TaggedString<Tag>: Equatable, Hashable, Sendable, Codable, CustomStringConvertible, RawRepresentable, CodingKeyRepresentable, Comparable {
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
      return lhs.rawValue < rhs.rawValue
    }
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public static func tagged(_ rawValue: String) -> Self {
        Self.init(rawValue: rawValue)
    }
    
    public var description: String {
        return String(describing: self.rawValue)
    }

    public init(from decoder: Decoder) throws {
        do {
            self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
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
    
    public init?<T: CodingKey>(codingKey: T) {
        guard let rawValue = String(codingKey: codingKey)
        else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public var codingKey: CodingKey {
        self.rawValue.codingKey
    }
    
}
