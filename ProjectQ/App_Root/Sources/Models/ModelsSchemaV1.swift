
import SwiftUI
import SwiftData

public enum ModelsSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    public static var models: [any PersistentModel.Type] {
        [
            Entry.self,
            Translation.self,
            Usage.self,
            Language.self,
            Keyword.self,
            Note.self,
        ]
    }
    
    @Model
    public final class Entry {
        public var added: Date
        public var modified: Date
        public var spelling: String
        public var language: Language
        
        @Relationship(inverse: \Translation.from)
        public var translations: [Translation] = []
        
        @Relationship(inverse: \Usage.included)
        public var usages: [Usage] = []
        
        @Relationship(inverse: \Keyword.matches)
        public var keywords: [Keyword] = []
        
        @Relationship(deleteRule: .cascade)
        public var note: Note? = nil

        public init(added: Date, modified: Date, language: Language, spelling: String) {
            self.added = added
            self.modified = modified
            self.language = language
            self.spelling = spelling
        }
    }

    @Model
    public final class Translation {
        public let from: Entry
        public let to: Entry
        public var added: Date
        public var modified: Date
        
        @Relationship(deleteRule: .cascade)
        public var note: Note? = nil
        
        public init(from: Entry, to: Entry, added: Date, modified: Date) {
            self.from = from
            self.to = to
            self.added = added
            self.modified = modified
        }
    }

    @Model
    public final class Usage {
        public var added: Date
        public var modified: Date
        public var value: String
        
        @Relationship(deleteRule: .cascade)
        public var note: Note? = nil
        
        public var included: [Entry] = []
        
        public init(added: Date, modified: Date, included: [Entry], value: String) {
            self.added = added
            self.modified = modified
            self.included = included
            self.value = value
        }
    }
    
    @Model
    public final class Language {
        fileprivate var definitionID: String
        fileprivate var customLocalizedTitles: [String: String]? = nil
        
        // I am storing this as a String and a [String: String] until SwiftData predicates can handle enums
        public var definition: Definition {
            get {
                if let customLocalizedTitles {
                    .custom(.init(identifier: definitionID, localizedTitles: customLocalizedTitles))
                } else {
                    .bcp47(definitionID)
                }
            }
            set {
                self.definitionID = newValue.id
                self.customLocalizedTitles = newValue.customLocalizedTitles
            }
        }
        
        @Relationship(inverse: \Entry.language)
        public var entries: [Entry] = []
        public var usages: [Usage] = []
        
        public enum Definition: Identifiable, Equatable, Hashable, Codable, Sendable {
            case bcp47(String)
            case custom(Custom)
            public var id: String {
                switch self {
                case .bcp47(let bcp47): bcp47
                case .custom(let custom): custom.identifier
                }
            }
            fileprivate var customLocalizedTitles: [String: String]? {
                switch self {
                case .bcp47: nil
                case .custom(let custom): custom.localizedTitles
                }
            }
        }
        public struct Custom: Equatable, Hashable, Codable, Sendable {
            public var identifier: String
            public var localizedTitles: [String: String]
        }
        init(definitionID: String, customLocalizedTitles: [String : String]?) {
            self.definitionID = definitionID
            self.customLocalizedTitles = customLocalizedTitles
        }
        public convenience init(definition: Definition) {
            self.init(
                definitionID: definition.id,
                customLocalizedTitles: definition.customLocalizedTitles
            )
        }
    }
    
    @Model
    public final class Keyword {
        public var title: String
        public var matches: [Entry] = []
        
        public init(title: String) {
            self.title = title
        }
    }
    
    @Model
    public final class Note {
        public var added: Date
        public var modified: Date
        public var value: String

        public init(added: Date, modified: Date, value: String) {
            self.added = added
            self.modified = modified
            self.value = value
        }
    }
    
    
    // NOTE: If you add a type here, remember to both create the typealias and add it to the model schema
    
}
