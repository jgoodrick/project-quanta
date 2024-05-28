
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Language: Identifiable, Equatable, Codable, Sendable {
    public let id: ID
    public enum ID: Identifiable, Hashable, Codable, Sendable {
        public var id: String {
            switch self {
            case .bcp47(let code): return code
            }
        }
        case bcp47(String)
    }
    var customLocalizedTitles: [String: String] = [:]
    var metadata: Metadata = .init()
    struct Relationships: Equatable, Codable, Sendable {
        var entries: Set<Entry.ID> = []
        var usages: Set<Usage.ID> = []
    }
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Language.ID { language.id }
        public let language: Shared<Language>
        public let entries: [Entry]
        public let usages: [Usage]
    }
}
