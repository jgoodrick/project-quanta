
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Language: Identifiable, Equatable, Codable, Sendable {
    public let id: ID
    public enum ID: Identifiable, Hashable, Codable, Sendable {
        public var id: String { string }
        public var string: String {
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
        var isOrphan: Bool {
            entries.isEmpty &&
            usages.isEmpty
        }
    }
    
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Language.ID { language.id }
        public let language: Shared<Language>
        public let entries: [Entry]
        public let usages: [Usage]
    }
    
    // Convenience
    
    public var bcp47: String? {
        switch id {
        case .bcp47(let value): return value
        }
    }
    
    public var displayName: String {
        @Dependency(\.locale) var locale
        return customLocalizedTitles[locale.identifier] ?? locale.localizedString(forIdentifier: id.string) ?? id.string
    }
    
    public static var ukrainian: Language {
        .init(id: .bcp47("uk_UA"))
    }
    public static var english: Language {
        .init(id: .bcp47("en_US"))
    }
}
