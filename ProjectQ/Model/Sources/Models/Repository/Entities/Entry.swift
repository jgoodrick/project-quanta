
import ComposableArchitecture
import SwiftUI

@ObservableState
public struct Entry: Identifiable, Equatable, Codable, Sendable {
    public let id: UUID
    public var spelling: String = ""
    var alternateSpellings: [String] = []

//    var diagram: Diagram = .init()
//    struct Diagram: Equatable, Codable, Sendable {
//        var sections: [ClosedRange<Int>: Section] = [:]
//        struct Section: Equatable, Codable, Sendable {
//            var title: String = ""
//            var accentMark: String = ""
//            var colorHex: String = ""
//        }
//    }
//    var review: Review = .init()
//    struct Review: Equatable, Codable, Sendable {
//        var lastReviewed: Date = .distantPast
//        var confidenceLevel: Int = 0
//        var ommitted: Bool = false
//    }
    
    var metadata: Metadata = .init()
    
    struct Relationships: Equatable, Codable, Sendable {
        var language: Language.ID?
        var root: Entry.ID?
        var derived: Set<Entry.ID> = []
        var translations: [Entry.ID] = []
        var backTranslations: Set<Entry.ID> = []
        var seeAlso: [Entry.ID] = []
        var usages: [Usage.ID] = []
        var keywords: Set<Keyword.ID> = []
        var notes: [Note.ID] = []
        var userCollections: Set<UserCollection.ID> = []
//        var recordings: [Recording.ID] = []
        var isOrphan: Bool {
            root == nil &&
            derived.isEmpty &&
            translations.isEmpty &&
            backTranslations.isEmpty &&
            seeAlso.isEmpty &&
            usages.isEmpty &&
            keywords.isEmpty &&
            notes.isEmpty &&
            userCollections.isEmpty
        }
    }
    
    public struct Aggregate: Identifiable, Equatable, Sendable {
        public var id: Entry.ID { entry.id }
        public let entry: Shared<Entry>
        public let language: Language?
        public let root: Entry?
        public let derived: [Entry]
        public let translations: [Entry]
        public let backTranslations: [Entry]
        public let seeAlso: [Entry]
        public let usages: [Usage]
        public let keywords: [Keyword]
        public let notes: [Note]
        public let userCollections: [UserCollection]
//        var recordings: [Recording]
    }
}
