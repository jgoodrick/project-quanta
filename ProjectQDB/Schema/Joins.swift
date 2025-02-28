//
//  Joins.swift
//  ProjectQDB
//
//  Created by Goodrick,Joseph on 2/24/25.
//

extension DB {
    struct Morphological: RelationalJoin {
        typealias Left = Entry
        typealias Right = Entry
        var lhsEntryID: Int64
        var rhsEntryID: Int64
        var lhsIsA: Relationship
        enum Relationship: String, Codable, Hashable, CaseIterable {
            case conjugation  // e.g., "run" → "ran"
            case declension   // e.g., "mouse" → "mice"
            case pluralization // e.g., "book" → "books"
            case genderChange // e.g., "actor" → "actress"
            case caseChange // e.g., "him" (accusative) vs. "he" (nominative)
            case diminutive // e.g., "dog" → "doggie"
            case augmentative // e.g., "casa" → "casón" (Spanish, "house" → "big house")
        }
    }

    struct Etymological: RelationalJoin {
        typealias Left = Entry
        typealias Right = Entry
        var lhsEntryID: Int64
        var rhsEntryID: Int64
        var lhsIsA: Relationship
        enum Relationship: String, Codable, Hashable, CaseIterable {
            case derived   // "electric" → "electricity"
            case borrowed  // "déjà vu" (borrowed from French)
            case cognate   // "brother" (English) vs. "bruder" (German)
            case root      // "scribe" as the root of "describe," "scribble"
        }
    }

    struct Semantic: RelationalJoin {
        typealias Left = Entry
        typealias Right = Entry
        var lhsEntryID: Int64
        var rhsEntryID: Int64
        var kind: Relationship
        enum Relationship: String, Codable, Hashable, CaseIterable {
            case synonym   // "big" ↔ "large"
            case antonym   // "hot" ↔ "cold"
            case hypernym  // "dog" is a type of "animal"
            case hyponym   // "animal" includes "dog"
            case meronym   // "wheel" is a part of "car"
            case holonym   // "car" consists of "wheels"
            case troponym  // "whisper" is a way to "talk"
            case registerVariant // Formal vs. informal versions of the same word
        }
    }

    struct Phonetic: RelationalJoin {
        typealias Left = Entry
        typealias Right = Entry
        var lhsEntryID: Int64
        var rhsEntryID: Int64
        var kind: Relationship
        enum Relationship: String, Codable, Hashable, CaseIterable {
            case homophone   // "knight" and "night"
            case homograph   // "lead" (to guide) vs. "lead" (metal)
            case homonym     // Words with same spelling & pronunciation, different meanings
        }
    }

    struct Orthographic: RelationalJoin {
        typealias Left = Entry
        typealias Right = Entry
        var lhsEntryID: Int64
        var rhsEntryID: Int64
        var kind: Relationship
        enum Relationship: String, Codable, Hashable, CaseIterable {
            case alternativeSpelling // e.g., "color" (US) vs. "colour" (UK)
            case transliteration // e.g., "Москва" → "Moskva" (Russian to Latin)
        }
    }

    struct EntryLanguage: Join {
        typealias Left = Entry
        typealias Right = Language
        var entryID: Int64
        var languageID: Int64
    }

    struct EntrySpelling: Join {
        typealias Left = Entry
        typealias Right = Spelling
        var entryID: Int64
        var spellingID: Int64
    }

    struct EntryDefinition: Join {
        typealias Left = Entry
        typealias Right = Definition
        var entryID: Int64
        var definitionID: Int64
    }

    struct EntryUsage: Join {
        typealias Left = Entry
        typealias Right = Usage
        var entryID: Int64
        var usageID: Int64
    }

    struct EntryKeyword: Join {
        typealias Left = Entry
        typealias Right = Keyword
        var entryID: Int64
        var keywordID: Int64
    }

    struct EntryPronunciation: Join {
        typealias Left = Entry
        typealias Right = Pronunciation
        var entryID: Int64
        var pronunciationID: Int64
    }

    struct EntryImage: Join {
        typealias Left = Entry
        typealias Right = Image
        var entryID: Int64
        var imageID: Int64
    }

    struct EntryImpression: Join {
        typealias Left = Entry
        typealias Right = Impression
        var entryID: Int64
        var impressionID: Int64
    }
}
