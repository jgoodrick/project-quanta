//
//  Schema.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import SharingGRDB
import Foundation

public enum DB {
    @Table
    struct Entry: Codable, Hashable, Identifiable {
        let id: UUID
        var spelling: String
        var language: String
        var recorded: Date
    }

    @Table @Selection
    struct EntryText: StructuredQueriesSQLite.FTS5 {
        let rowID: Int
        let title: String
        let notes: String
        let tags: String
    }
}

extension DB.Entry {
    @Selection
    struct Capsule {
        var entry: DB.Entry
        var language: String
        var spelling: String
    }
}

enum TranslationEntry: AliasName {}
enum TranslationSpelling: AliasName {}
enum TranslationLanguage: AliasName {}

extension DB.Entry {
    @Selection
    struct Row: Hashable, Identifiable {
        var id: DB.Entry.ID { entryID }
        var entryID: DB.Entry.ID
        var languageName: String
        var spelling: String
        @Column(as: [DB.Entry.Keyword].JSONRepresentation.self)
        var keywords: [DB.Entry.Keyword] = []

        static let withKeywordJoins = DB.Entry
            .group(by: \.id)
            .leftJoin(Joins.EntryKeyword.all) { $0.id.eq($1.entry) }
            .join(DB.Entry.Keyword.all) { $1.keyword.eq($2.id) }

        static let withTranslationJoins = withKeywordJoins
            .leftJoin(DB.Semantic.Synonym.all) { $0.id.eq($3.base) }
            .join(DB.Entry.as(TranslationEntry.self).all) { $3.synonym.eq($4.id) }

        static let withDefinitionsJoins = withTranslationJoins
            .leftJoin(Joins.EntryDefinition.all) { $0.id.eq($5.entry) }
            .join(DB.Entry.Definition.all) { $5.definition.eq($6.id) }

        static let all = withKeywordJoins.select { entry, _, keyword in
            DB.Entry.Row.Columns.init(
                entryID: entry.id,
                languageName: entry.language,
                spelling: entry.spelling,
                keywords: keyword.jsonGroupArray()
            )
        }
    }
}

extension DB.Entry {
    @Table
    struct Definition: Codable, Hashable, Identifiable {
        let id: UUID
        var text: String
    }

    @Table
    struct Usage: Codable, Hashable, Identifiable {
        let id: UUID
        var text: String
    }

    @Table
    struct Keyword: Codable, Hashable, Identifiable {
        let id: UUID
        var text: String
        var description: String
    }

    @Table
    struct Pronunciation: Codable, Hashable, Identifiable {
        let id: UUID
        var text: String
        var audioURL: URL?
    }

    @Table
    struct Image: Codable, Hashable, Identifiable {
        let id: UUID
        var imageURL: URL
        var remote: Bool
    }

    @Table
    struct Impression: Codable, Hashable, Identifiable {
        let id: UUID
        var mastery: Double
        var mode: String
        var recorded: Date
    }

    // MARK: Joins

    @Table
    struct Note: Codable, Hashable, Identifiable {
        let id: UUID
        var entry: DB.Entry.ID
        var text: String
        var recorded: Date
    }

    enum Joins {
        @Table
        struct EntryAdditionalSpelling: Codable, Hashable {
            var entry: DB.Entry.ID
            var additionalSpelling: DB.Entry.ID
            var rank: Int
        }

        @Table
        struct EntryDefinition: Codable, Hashable {
            var entry: DB.Entry.ID
            var definition: DB.Entry.Definition.ID
        }

        @Table
        struct EntryUsage: Codable, Hashable {
            var entry: DB.Entry.ID
            var usage: DB.Entry.Usage.ID
        }

        @Table
        struct EntryKeyword: Codable, Hashable {
            var entry: DB.Entry.ID
            var keyword: DB.Entry.Keyword.ID
        }

        @Table
        struct EntryPronunciation: Codable, Hashable {
            var entry: DB.Entry.ID
            var pronunciation: DB.Entry.Pronunciation.ID
        }

        @Table
        struct EntryImage: Codable, Hashable {
            var entry: DB.Entry.ID
            var image: DB.Entry.Image.ID
        }

        @Table
        struct EntryImpression: Codable, Hashable {
            var entry: DB.Entry.ID
            var impression: DB.Entry.Impression.ID
        }
    }
}

extension DB {
    enum Noun {
        enum Number {
            @Table("singularNouns")
            struct Singular: Codable, Hashable {
                var base: DB.Entry.ID
                var singular: DB.Entry.ID
            }
            @Table("pluralNouns")
            struct Plural: Codable, Hashable {
                var base: DB.Entry.ID
                var plural: DB.Entry.ID
            }
        }

        enum Gender {
            @Table("masculineNouns")
            struct Masculine: Codable, Hashable {
                var base: DB.Entry.ID
                var masculine: DB.Entry.ID
            }
            @Table("feminineNouns")
            struct Feminine: Codable, Hashable {
                var base: DB.Entry.ID
                var feminine: DB.Entry.ID
            }
            @Table("neuterNouns")
            struct Neuter: Codable, Hashable {
                var base: DB.Entry.ID
                var neuter: DB.Entry.ID
            }
        }

        enum Case {
            @Table // e.g., "he" (nominative) aka the 'Subjective' case
            struct Nominative: Codable, Hashable {
                var base: DB.Entry.ID
                var nominative: DB.Entry.ID
            }

            @Table // e.g., "him" (objective) aka 'Accusative' or 'direct object'
            struct Objective: Codable, Hashable {
                var base: DB.Entry.ID
                var objective: DB.Entry.ID
            }

            @Table // e.g., "his" (possessive) aka the 'Genitive' case
            struct Possessive: Codable, Hashable {
                var base: DB.Entry.ID
                var possessive: DB.Entry.ID
            }

            @Table // e.g., "John, please come here" (vocative) to address someone directly
            struct Vocative: Codable, Hashable {
                var base: DB.Entry.ID
                var vocative: DB.Entry.ID
            }

            @Table // e.g., "him" (dative) aka 'Indirect object' "Ben gave him a present"
            struct Dative: Codable, Hashable {
                var base: DB.Entry.ID
                var dative: DB.Entry.ID
            }

            @Table // e.g., "tree-ok" in "Ben went tree-ok" (if -ok were a fictional ablative suffix meaning "away from" so this read "Ben went away from the tree")
            struct Ablative: Codable, Hashable {
                var base: DB.Entry.ID
                var ablative: DB.Entry.ID
            }

            @Table // e.g., "pen" in "John wrote with a pen." the key word in English to look for is "with" as a way of describing how an action is performed
            struct Instrumental: Codable, Hashable {
                var base: DB.Entry.ID
                var instrumental: DB.Entry.ID
            }

            @Table // e.g., "restaurant" in "John went to the restaurant."
            struct Locative: Codable, Hashable {
                var base: DB.Entry.ID
                var locative: DB.Entry.ID
            }
        }

        enum Size {
            @Table // e.g., "dog" → "doggie"
            struct Diminutive: Codable, Hashable {
                var base: DB.Entry.ID
                var diminished: DB.Entry.ID
            }

            @Table // e.g., "casa" → "casón" (Spanish, "house" → "big house")
            struct Augmentative: Codable, Hashable {
                var base: DB.Entry.ID
                var augmented: DB.Entry.ID
            }
        }
    }

    enum Etymology {
        @Table // "electric" → "electricity"
        struct Derivation: Codable, Hashable {
            var base: DB.Entry.ID
            var derived: DB.Entry.ID
        }

        @Table("loanWords") // "déjà vu" (borrowed from French)
        struct Loan: Codable, Hashable {
            var entry: DB.Entry.ID
            var origin: String
        }

        @Table // "brother" (English) vs. "bruder" (German)
        struct Cognate: Codable, Hashable {
            var base: DB.Entry.ID
            var cognate: DB.Entry.ID
        }

        @Table("rootWords") // "scribe" as the root of "describe," "scribble"
        struct Root: Codable, Hashable {
            var base: DB.Entry.ID
            var root: DB.Entry.ID
        }
    }

    enum Verb {
        enum Person {
            @Table("firstPersons")
            struct First: Codable, Hashable {
                var base: DB.Entry.ID
                var firstPerson: DB.Entry.ID
            }
            @Table("secondPersons")
            struct Second: Codable, Hashable {
                var base: DB.Entry.ID
                var secondPerson: DB.Entry.ID
            }
            @Table("thirdPersons")
            struct Third: Codable, Hashable {
                var base: DB.Entry.ID
                var thirdPerson: DB.Entry.ID
            }
        }

        enum Gender {
            @Table("unknownGenderSubjectVerbs")
            struct Unknown: Codable, Hashable {
                var base: DB.Entry.ID
                var unknown: DB.Entry.ID
            }
            @Table("masculineSubjectVerbs")
            struct Masculine: Codable, Hashable {
                var base: DB.Entry.ID
                var masculine: DB.Entry.ID
            }
            @Table("feminineSubjectVerbs")
            struct Feminine: Codable, Hashable {
                var base: DB.Entry.ID
                var feminine: DB.Entry.ID
            }
            @Table("neuterSubjectVerbs")
            struct Neuter: Codable, Hashable {
                var base: DB.Entry.ID
                var neuter: DB.Entry.ID
            }
        }

        enum Number {
            @Table("singularSubjectVerbs")
            struct Singular: Codable, Hashable {
                var base: DB.Entry.ID
                var singular: DB.Entry.ID
            }
            @Table("pluralSubjectVerbs")
            struct Plural: Codable, Hashable {
                var base: DB.Entry.ID
                var plural: DB.Entry.ID
            }
        }

        enum Tense {
            @Table("presentTenses") // e.g., "run" → "running"
            struct Present: Codable, Hashable {
                var base: DB.Entry.ID
                var present: DB.Entry.ID
                var perfect: Bool
            }

            @Table("pastTenses") // e.g., "run" → "ran"
            struct Past: Codable, Hashable {
                var base: DB.Entry.ID
                var past: DB.Entry.ID
                var perfect: Bool
            }

            @Table("futureTenses") // e.g., "run" → "will run"
            struct Future: Codable, Hashable {
                var base: DB.Entry.ID
                var future: DB.Entry.ID
                var perfect: Bool
            }
        }

        enum Aspect {
            @Table("simpleVerbs")
            struct Simple: Codable, Hashable {
                var base: DB.Entry.ID
                var simple: DB.Entry.ID
            }
            @Table("continuousVerbs")
            struct Continuous: Codable, Hashable {
                var base: DB.Entry.ID
                var continuous: DB.Entry.ID
            }
            @Table("perfectVerbs")
            struct Perfect: Codable, Hashable {
                var base: DB.Entry.ID
                var perfect: DB.Entry.ID
            }
        }

        enum Mood {
            @Table
            struct Indicative: Codable, Hashable {
                var base: DB.Entry.ID
                var indicative: DB.Entry.ID
            }
            @Table
            struct Imperative: Codable, Hashable {
                var base: DB.Entry.ID
                var imperative: DB.Entry.ID
            }
            @Table
            struct Subjunctive: Codable, Hashable {
                var base: DB.Entry.ID
                var subjunctive: DB.Entry.ID
            }
        }

        enum Voice {
            @Table("activeVoices")
            struct Active: Codable, Hashable {
                var base: DB.Entry.ID
                var active: DB.Entry.ID
            }
            @Table("passiveVoices")
            struct Passive: Codable, Hashable {
                var base: DB.Entry.ID
                var passive: DB.Entry.ID
            }
        }
    }

    enum Semantic {
        @Table // "big" ↔ "large"
        struct Synonym: Codable, Hashable {
            var base: DB.Entry.ID
            var synonym: DB.Entry.ID
        }
        @Table // "hot" ↔ "cold"
        struct Antonym: Codable, Hashable {
            var base: DB.Entry.ID
            var antonym: DB.Entry.ID
        }
        @Table // "dog" is a type of "animal"
        struct Hypernym: Codable, Hashable {
            var base: DB.Entry.ID
            var hypernym: DB.Entry.ID
        }
        @Table // "animal" includes "dog"
        struct Hyponym: Codable, Hashable {
            var base: DB.Entry.ID
            var hyponym: DB.Entry.ID
        }
        @Table // "wheel" is a part of "car"
        struct Meronym: Codable, Hashable {
            var base: DB.Entry.ID
            var meronym: DB.Entry.ID
        }
        @Table // "car" consists of "wheels"
        struct Holonym: Codable, Hashable {
            var base: DB.Entry.ID
            var holonym: DB.Entry.ID
        }
        @Table // "whisper" is a way to "talk"
        struct Troponym: Codable, Hashable {
            var base: DB.Entry.ID
            var troponym: DB.Entry.ID
        }
        @Table // Formal version of a word
        struct Formal: Codable, Hashable {
            var base: DB.Entry.ID
            var formal: DB.Entry.ID
        }
        @Table // Informal version of a word
        struct Informal: Codable, Hashable {
            var base: DB.Entry.ID
            var informal: DB.Entry.ID
        }
        @Table // Slang version of a word
        struct Slang: Codable, Hashable {
            var base: DB.Entry.ID
            var slang: DB.Entry.ID
        }
    }

    enum Phonetic {
        @Table // "knight" and "night"
        struct Homophone: Codable, Hashable {
            var base: DB.Entry.ID
            var homophone: DB.Entry.ID
        }
        @Table // "lead" (to guide) vs. "lead" (metal)
        struct Homograph: Codable, Hashable {
            var base: DB.Entry.ID
            var homograph: DB.Entry.ID
        }
        @Table // Words with same spelling & pronunciation, different meanings
        struct Homonym: Codable, Hashable {
            var base: DB.Entry.ID
            var homonym: DB.Entry.ID
        }
    }

    enum Orthographic {
        @Table // e.g., "color" (US) vs. "colour" (UK)
        struct AlternativeSpelling: Codable, Hashable {
            var base: DB.Entry.ID
            var alternativeSpelling: DB.Entry.ID
        }
        @Table // e.g., "Москва" → "Moskva" (Russian to Latin)
        struct Transliteration: Codable, Hashable {
            var base: DB.Entry.ID
            var transliteration: DB.Entry.ID
        }
    }
}
