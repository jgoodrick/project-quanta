////
////  Entities.swift
////  ProjectQDB
////
////  Created by Goodrick,Joseph on 2/24/25.
////
//
//import Foundation
//import StructuredQueriesGRDBCore
//import StructuredQueriesSQLite
//
//extension DB {
//    @Table
//    struct Entry {
//        let id: Int64
//        let createdAt: Date
//    }
//    @Table
//    struct Language {
//        let id: Int64
//        var name: String = ""
//        /// The bcp47 code that can be used to adjust the keyboard
//        var keyboardID: String?
//    }
//    @Table
//    struct Spelling {
//        let id: Int64
//        var text: String = ""
//    }
//    @Table
//    struct Definition {
//        let id: Int64
//        var text: String
//    }
//    @Table
//    struct Usage {
//        let id: Int64
//        var text: String = ""
//    }
//    @Table
//    struct Keyword {
//        let id: Int64
//        var text: String
//        var description: String = ""
//    }
//    @Table
//    struct Pronunciation {
//        let id: Int64
//        var text: String = ""
//        var audioURL: URL?
//    }
//    @Table
//    struct Image {
//        let id: Int64
//        var remote: Bool
//        var imageURL: URL
//    }
//    @Table
//    struct Impression {
//        let id: Int64
//        var mastery: Double
//        var type: String
//        var datetime: Date
//    }
//
//    // MARK: With foreign keys
//    @Table
//    struct Note {
//        let id: Int64
//        var entryID: Int64
//        var text: String = ""
//    }
//
//    // MARK: Relationship Joins
//    @Table
//    struct MorphologicalRelationship {
//        var lhsEntryID: Int64
//        var rhsEntryID: Int64
//        var lhsIsA: Relationship
//        enum Relationship: String, Codable, Hashable, CaseIterable {
//            case conjugation  // e.g., "run" → "ran"
//            case declension   // e.g., "mouse" → "mice"
//            case pluralization // e.g., "book" → "books"
//            case genderChange // e.g., "actor" → "actress"
//            case caseChange // e.g., "him" (accusative) vs. "he" (nominative)
//            case diminutive // e.g., "dog" → "doggie"
//            case augmentative // e.g., "casa" → "casón" (Spanish, "house" → "big house")
//        }
//    }
//    @Table
//    struct EtymologicalRelationship {
//        var lhsEntryID: Int64
//        var rhsEntryID: Int64
//        var lhsIsA: Relationship
//        enum Relationship: String, Codable, Hashable, CaseIterable {
//            case derived   // "electric" → "electricity"
//            case borrowed  // "déjà vu" (borrowed from French)
//            case cognate   // "brother" (English) vs. "bruder" (German)
//            case root      // "scribe" as the root of "describe," "scribble"
//        }
//    }
//    @Table
//    struct SemanticRelationship {
//        var lhsEntryID: Int64
//        var rhsEntryID: Int64
//        var kind: Relationship
//        enum Relationship: String, Codable, Hashable, CaseIterable {
//            case synonym   // "big" ↔ "large"
//            case antonym   // "hot" ↔ "cold"
//            case hypernym  // "dog" is a type of "animal"
//            case hyponym   // "animal" includes "dog"
//            case meronym   // "wheel" is a part of "car"
//            case holonym   // "car" consists of "wheels"
//            case troponym  // "whisper" is a way to "talk"
//            case registerVariant // Formal vs. informal versions of the same word
//        }
//    }
//    @Table
//    struct PhoneticRelationship {
//        var lhsEntryID: Int64
//        var rhsEntryID: Int64
//        var kind: Relationship
//        enum Relationship: String, Codable, Hashable, CaseIterable {
//            case homophone   // "knight" and "night"
//            case homograph   // "lead" (to guide) vs. "lead" (metal)
//            case homonym     // Words with same spelling & pronunciation, different meanings
//        }
//    }
//    @Table
//    struct OrthographicRelationship {
//        var lhsEntryID: Int64
//        var rhsEntryID: Int64
//        var kind: Relationship
//        enum Relationship: String, Codable, Hashable, CaseIterable {
//            case alternativeSpelling // e.g., "color" (US) vs. "colour" (UK)
//            case transliteration // e.g., "Москва" → "Moskva" (Russian to Latin)
//        }
//    }
//    @Table
//    struct EntryLanguage {
//        var entryID: Int64
//        var languageID: Int64
//    }
//    @Table
//    struct EntrySpelling {
//        var entryID: Int64
//        var spellingID: Int64
//    }
//    @Table
//    struct EntryDefinition {
//        var entryID: Int64
//        var definitionID: Int64
//    }
//    @Table
//    struct EntryUsage {
//        var entryID: Int64
//        var usageID: Int64
//    }
//    @Table
//    struct EntryKeyword {
//        var entryID: Int64
//        var keywordID: Int64
//    }
//    @Table
//    struct EntryPronunciation {
//        var entryID: Int64
//        var pronunciationID: Int64
//    }
//    @Table
//    struct EntryImage {
//        var entryID: Int64
//        var imageID: Int64
//    }
//    @Table
//    struct EntryImpression {
//        var entryID: Int64
//        var impressionID: Int64
//    }
//}
