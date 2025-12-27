//
//  Schema.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SQLiteData
import Foundation

@Table
package struct Entry: Codable, Hashable, Identifiable {
    package let id: UUID
    package var spelling: String
    package var language: String
    package var recorded: Date
}

@Table
package struct EntryText: StructuredQueriesSQLite.FTS5 {
    package let rowID: Int
    package let title: String
    package let notes: String
    package let tags: String
}

package extension Entry {
    @Selection
    struct Capsule {
        package var entry: Entry
        package var language: String
        package var spelling: String
    }
}

enum TranslationEntry: AliasName {}
enum TranslationSpelling: AliasName {}
enum TranslationLanguage: AliasName {}

package extension Entry {
    @Selection
    struct Row: Hashable, Identifiable {
        package var id: Entry.ID { entryID }
        package var entryID: Entry.ID
        package var languageName: String
        package var spelling: String
        @Column(as: [Entry.Keyword].JSONRepresentation.self)
        package var keywords: [Entry.Keyword] = []

//        static let withKeywordJoins = Entry
//            .group(by: \.id)
//            .leftJoin(Joins.EntryKeyword.all) { $0.id.eq($1.entry) }
//            .join(Entry.Keyword.all) { $1.keyword.eq($2.id) }
//
//        static let withTranslationJoins = withKeywordJoins
//            .leftJoin(Semantic.Synonym.all) { $0.id.eq($3.base) }
//            .join(Entry.as(TranslationEntry.self).all) { $3.synonym.eq($4.id) }
//
//        static let withDefinitionsJoins = withTranslationJoins
//            .leftJoin(Joins.EntryDefinition.all) { $0.id.eq($5.entry) }
//            .join(Entry.Definition.all) { $5.definition.eq($6.id) }
//
//        static let all = withKeywordJoins.select { entry, _, keyword in
//            Entry.Row.Columns.init(
//                entryID: entry.id,
//                languageName: entry.language,
//                spelling: entry.spelling,
//                keywords: keyword.jsonGroupArray()
//            )
//        }
    }
}

package extension Entry {
    @Table
    struct Definition: Codable, Hashable, Identifiable {
        package let id: UUID
        package var text: String
    }

    @Table
    struct Usage: Codable, Hashable, Identifiable {
        package let id: UUID
        package var text: String
    }

    @Table
    struct Keyword: Codable, Hashable, Identifiable {
        package let id: UUID
        package var text: String
        package var description: String
    }

    @Table
    struct Pronunciation: Codable, Hashable, Identifiable {
        package let id: UUID
        package var text: String
        package var audioURL: URL?
    }

    @Table
    struct Image: Codable, Hashable, Identifiable {
        package let id: UUID
        package var imageURL: URL
        package var remote: Bool
    }

    @Table
    struct Impression: Codable, Hashable, Identifiable {
        package let id: UUID
        package var mastery: Double
        package var mode: String
        package var recorded: Date
    }

    // MARK: Joins

    @Table
    struct Note: Codable, Hashable, Identifiable {
        package let id: UUID
        package var entry: Entry.ID
        package var text: String
        package var recorded: Date
    }

    enum Joins {}
}

package extension Entry.Joins {
    @Table
    struct EntryAdditionalSpelling: Codable, Hashable {
        package var entry: Entry.ID
        package var additionalSpelling: Entry.ID
        package var rank: Int
    }
    
    @Table
    struct EntryDefinition: Codable, Hashable {
        package var entry: Entry.ID
        package var definition: Entry.Definition.ID
    }
    
    @Table
    struct EntryUsage: Codable, Hashable {
        package var entry: Entry.ID
        package var usage: Entry.Usage.ID
    }
    
    @Table
    struct EntryKeyword: Codable, Hashable {
        package var entry: Entry.ID
        package var keyword: Entry.Keyword.ID
    }
    
    @Table
    struct EntryPronunciation: Codable, Hashable {
        package var entry: Entry.ID
        package var pronunciation: Entry.Pronunciation.ID
    }
    
    @Table
    struct EntryImage: Codable, Hashable {
        package var entry: Entry.ID
        package var image: Entry.Image.ID
    }
    
    @Table
    struct EntryImpression: Codable, Hashable {
        package var entry: Entry.ID
        package var impression: Entry.Impression.ID
    }
}

package enum Noun {}

package extension Noun {
    enum Number {}
}

package extension Noun.Number {
    @Table("singularNouns")
    struct Singular: Codable, Hashable {
        package var base: Entry.ID
        package var singular: Entry.ID
    }
    @Table("pluralNouns")
    struct Plural: Codable, Hashable {
        package var base: Entry.ID
        package var plural: Entry.ID
    }
}

package extension Noun {
    enum Gender {}
}

package extension Noun.Gender {
    @Table("masculineNouns")
    struct Masculine: Codable, Hashable {
        package var base: Entry.ID
        package var masculine: Entry.ID
    }
    @Table("feminineNouns")
    struct Feminine: Codable, Hashable {
        package var base: Entry.ID
        package var feminine: Entry.ID
    }
    @Table("neuterNouns")
    struct Neuter: Codable, Hashable {
        package var base: Entry.ID
        package var neuter: Entry.ID
    }
}

package extension Noun {
    enum Case {}
}

package extension Noun.Case {
    @Table // e.g., "he" (nominative) aka the 'Subjective' case
    struct Nominative: Codable, Hashable {
        package var base: Entry.ID
        package var nominative: Entry.ID
    }
    
    @Table // e.g., "him" (objective) aka 'Accusative' or 'direct object'
    struct Objective: Codable, Hashable {
        package var base: Entry.ID
        package var objective: Entry.ID
    }
    
    @Table // e.g., "his" (possessive) aka the 'Genitive' case
    struct Possessive: Codable, Hashable {
        package var base: Entry.ID
        package var possessive: Entry.ID
    }
    
    @Table // e.g., "John, please come here" (vocative) to address someone directly
    struct Vocative: Codable, Hashable {
        package var base: Entry.ID
        package var vocative: Entry.ID
    }
    
    @Table // e.g., "him" (dative) aka 'Indirect object' "Ben gave him a present"
    struct Dative: Codable, Hashable {
        package var base: Entry.ID
        package var dative: Entry.ID
    }
    
    @Table // e.g., "tree-ok" in "Ben went tree-ok" (if -ok were a fictional ablative suffix meaning "away from" so this read "Ben went away from the tree")
    struct Ablative: Codable, Hashable {
        package var base: Entry.ID
        package var ablative: Entry.ID
    }
    
    @Table // e.g., "pen" in "John wrote with a pen." the key word in English to look for is "with" as a way of describing how an action is performed
    struct Instrumental: Codable, Hashable {
        package var base: Entry.ID
        package var instrumental: Entry.ID
    }
    
    @Table // e.g., "restaurant" in "John went to the restaurant."
    struct Locative: Codable, Hashable {
        package var base: Entry.ID
        package var locative: Entry.ID
    }
}

package extension Noun {
    enum Size {}
}

package extension Noun.Size {
    @Table // e.g., "dog" → "doggie"
    struct Diminutive: Codable, Hashable {
        package var base: Entry.ID
        package var diminished: Entry.ID
    }
    
    @Table // e.g., "casa" → "casón" (Spanish, "house" → "big house")
    struct Augmentative: Codable, Hashable {
        package var base: Entry.ID
        package var augmented: Entry.ID
    }
}

package enum Etymology {}

package extension Etymology {
    @Table // "electric" → "electricity"
    struct Derivation: Codable, Hashable {
        package var base: Entry.ID
        package var derived: Entry.ID
    }

    @Table("loanWords") // "déjà vu" (borrowed from French)
    struct Loan: Codable, Hashable {
        package var entry: Entry.ID
        package var origin: String
    }

    @Table // "brother" (English) vs. "bruder" (German)
    struct Cognate: Codable, Hashable {
        package var base: Entry.ID
        package var cognate: Entry.ID
    }

    @Table("rootWords") // "scribe" as the root of "describe," "scribble"
    struct Root: Codable, Hashable {
        package var base: Entry.ID
        package var root: Entry.ID
    }
}

package enum Verb {
    package enum Person {}
}

package extension Verb.Person {
    @Table("firstPersons")
    struct First: Codable, Hashable {
        package var base: Entry.ID
        package var firstPerson: Entry.ID
    }
    @Table("secondPersons")
    struct Second: Codable, Hashable {
        package var base: Entry.ID
        package var secondPerson: Entry.ID
    }
    @Table("thirdPersons")
    struct Third: Codable, Hashable {
        package var base: Entry.ID
        package var thirdPerson: Entry.ID
    }
}

package extension Verb {
    enum Gender {}
}

package extension Verb.Gender {
    @Table("unknownGenderSubjectVerbs")
    struct Unknown: Codable, Hashable {
        package var base: Entry.ID
        package var unknown: Entry.ID
    }
    @Table("masculineSubjectVerbs")
    struct Masculine: Codable, Hashable {
        package var base: Entry.ID
        package var masculine: Entry.ID
    }
    @Table("feminineSubjectVerbs")
    struct Feminine: Codable, Hashable {
        package var base: Entry.ID
        package var feminine: Entry.ID
    }
    @Table("neuterSubjectVerbs")
    struct Neuter: Codable, Hashable {
        package var base: Entry.ID
        package var neuter: Entry.ID
    }
}

package extension Verb {
    enum Number {}
}

package extension Verb.Number {
    @Table("singularSubjectVerbs")
    struct Singular: Codable, Hashable {
        package var base: Entry.ID
        package var singular: Entry.ID
    }
    @Table("pluralSubjectVerbs")
    struct Plural: Codable, Hashable {
        package var base: Entry.ID
        package var plural: Entry.ID
    }
}

package extension Verb {
    enum Tense {}
}

package extension Verb.Tense {
    @Table("presentTenses") // e.g., "run" → "running"
    struct Present: Codable, Hashable {
        package var base: Entry.ID
        package var present: Entry.ID
        package var perfect: Bool
    }
    
    @Table("pastTenses") // e.g., "run" → "ran"
    struct Past: Codable, Hashable {
        package var base: Entry.ID
        package var past: Entry.ID
        package var perfect: Bool
    }
    
    @Table("futureTenses") // e.g., "run" → "will run"
    struct Future: Codable, Hashable {
        package var base: Entry.ID
        package var future: Entry.ID
        package var perfect: Bool
    }
}

package extension Verb {
    enum Aspect {}
}

package extension Verb.Aspect {
    @Table("simpleVerbs")
    struct Simple: Codable, Hashable {
        package var base: Entry.ID
        package var simple: Entry.ID
    }
    @Table("continuousVerbs")
    struct Continuous: Codable, Hashable {
        package var base: Entry.ID
        package var continuous: Entry.ID
    }
    @Table("perfectVerbs")
    struct Perfect: Codable, Hashable {
        package var base: Entry.ID
        package var perfect: Entry.ID
    }
}

package extension Verb {
    enum Mood {}
}

package extension Verb.Mood {
    @Table
    struct Indicative: Codable, Hashable {
        package var base: Entry.ID
        package var indicative: Entry.ID
    }
    @Table
    struct Imperative: Codable, Hashable {
        package var base: Entry.ID
        package var imperative: Entry.ID
    }
    @Table
    struct Subjunctive: Codable, Hashable {
        package var base: Entry.ID
        package var subjunctive: Entry.ID
    }
}

package extension Verb {
    enum Voice {}
}

package extension Verb.Voice {
    @Table("activeVoices")
    struct Active: Codable, Hashable {
        package var base: Entry.ID
        package var active: Entry.ID
    }
    @Table("passiveVoices")
    struct Passive: Codable, Hashable {
        package var base: Entry.ID
        package var passive: Entry.ID
    }
}

package enum Semantic {}

package extension Semantic {
    @Table // "big" ↔ "large"
    struct Synonym: Codable, Hashable {
        package var base: Entry.ID
        package var synonym: Entry.ID
    }
    @Table // "hot" ↔ "cold"
    struct Antonym: Codable, Hashable {
        package var base: Entry.ID
        package var antonym: Entry.ID
    }
    @Table // "dog" is a type of "animal"
    struct Hypernym: Codable, Hashable {
        package var base: Entry.ID
        package var hypernym: Entry.ID
    }
    @Table // "animal" includes "dog"
    struct Hyponym: Codable, Hashable {
        package var base: Entry.ID
        package var hyponym: Entry.ID
    }
    @Table // "wheel" is a part of "car"
    struct Meronym: Codable, Hashable {
        package var base: Entry.ID
        package var meronym: Entry.ID
    }
    @Table // "car" consists of "wheels"
    struct Holonym: Codable, Hashable {
        package var base: Entry.ID
        package var holonym: Entry.ID
    }
    @Table // "whisper" is a way to "talk"
    struct Troponym: Codable, Hashable {
        package var base: Entry.ID
        package var troponym: Entry.ID
    }
    @Table // Formal version of a word
    struct Formal: Codable, Hashable {
        package var base: Entry.ID
        package var formal: Entry.ID
    }
    @Table // Informal version of a word
    struct Informal: Codable, Hashable {
        package var base: Entry.ID
        package var informal: Entry.ID
    }
    @Table // Slang version of a word
    struct Slang: Codable, Hashable {
        package var base: Entry.ID
        package var slang: Entry.ID
    }
}

package enum Phonetic {}

package extension Phonetic {
    @Table // "knight" and "night"
    struct Homophone: Codable, Hashable {
        package var base: Entry.ID
        package var homophone: Entry.ID
    }
    @Table // "lead" (to guide) vs. "lead" (metal)
    struct Homograph: Codable, Hashable {
        package var base: Entry.ID
        package var homograph: Entry.ID
    }
    @Table // Words with same spelling & pronunciation, different meanings
    struct Homonym: Codable, Hashable {
        package var base: Entry.ID
        package var homonym: Entry.ID
    }
}

package enum Orthographic {}

package extension Orthographic {
    @Table // e.g., "color" (US) vs. "colour" (UK)
    struct AlternativeSpelling: Codable, Hashable {
        package var base: Entry.ID
        package var alternativeSpelling: Entry.ID
    }
    @Table // e.g., "Москва" → "Moskva" (Russian to Latin)
    struct Transliteration: Codable, Hashable {
        package var base: Entry.ID
        package var transliteration: Entry.ID
    }
}
