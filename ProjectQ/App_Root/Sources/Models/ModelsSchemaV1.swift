
import SwiftUI
import SwiftData

public enum ModelsSchemaV1: VersionedSchema {
    public static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    public static var models: [any PersistentModel.Type] {
        [
            Entry.self,
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
        
        public var language: Language?
        
        public var translations: [Entry] = []
        
        @Relationship(inverse: \Entry.translations)
        public var backTranslations: [Entry] = []
                
        @Relationship(inverse: \Usage.uses)
        public var usages: [Usage] = []
        
        public var keywords: [Keyword] = []
        
        public var notes: [Note] = []

        public init(added: Date, modified: Date, spelling: String) {
            self.added = added
            self.modified = modified
            self.spelling = spelling
        }
    }

    @Model
    public final class Usage {
        public var added: Date
        public var modified: Date
        public var value: String
        
        @Relationship(deleteRule: .cascade)
        public var note: Note? = nil
        
        public var uses: [Entry] = []
        
        public init(added: Date, modified: Date, value: String) {
            self.added = added
            self.modified = modified
            self.value = value
        }
    }
    
    @Model
    public final class Language {
        public var definitionID: String
        public var customLocalizedTitles: [String: String]? = nil
        
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
        public init(title: String) {
            self.title = title
            self.matches = []
        }

        public var title: String
        
        @Relationship(inverse: \Entry.keywords)
        public var matches: [Entry] = []
        
    }
    
    @Model
    public final class Note {
        public var added: Date
        public var modified: Date
        public var value: String
        
        @Relationship(inverse: \Entry.notes)
        public var entry: Entry?

        public init(added: Date, modified: Date, value: String) {
            self.added = added
            self.modified = modified
            self.value = value
        }
    }
    
    
    // NOTE: If you add a type here, remember to both create the typealias and add it to the model schema
    
}
