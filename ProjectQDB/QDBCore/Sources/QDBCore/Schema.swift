//
//  Schema.swift
//  QDBCore
//
//  Created by Goodrick,Joseph on 5/26/25.
//

import Dependencies
import StructuredQueriesGRDB
import Foundation

enum DB {
    enum Language {
        @Table("languageKeyboards")
        struct Keyboard: Codable, Hashable, Identifiable {
            var id: String
            enum BuiltIn: String, CaseIterable, Codable, Hashable, Identifiable {
                case en_US
                case es_US
                case uk_UA

                var id: String { rawValue }
            }
        }

        @Table("languageNames")
        struct Name: Codable, Hashable, Identifiable {
            var id: String { code }
            var code: String
            var text: String
            enum BuiltIn: String, CaseIterable, Codable, Hashable, Identifiable {
                case en
                case es
                case uk

                var id: String { code }
                var code: String { rawValue }
                var text: String {
                    switch self {
                    case .en: "English"
                    case .es: "Spanish"
                    case .uk: "Ukrainian"
                    }
                }
            }
        }

        @Table("languageRegions")
        struct Region: Codable, Hashable, Identifiable {
            var id: String { code }
            var code: String
            var text: String
            enum BuiltIn: String, CaseIterable, Codable, Hashable, Identifiable {
                case US
                case UK
                case UA

                var id: String { code }
                var code: String { rawValue }
                var text: String {
                    switch self {
                    case .US: "United States"
                    case .UK: "United Kingdom"
                    case .UA: "Ukraine"
                    }
                }
            }
        }

        @Table("languageScripts")
        struct Script: Codable, Hashable, Identifiable {
            var id: String { code }
            var code: String
            var text: String
            enum BuiltIn: String, CaseIterable, Codable, Hashable, Identifiable {
                case Cyrl
                case Latn

                var id: String { code }
                var code: String { rawValue }
                var text: String {
                    switch self {
                    case .Cyrl: "Cyrillic"
                    case .Latn: "Latin"
                    }
                }
            }
        }
    }

    @Table
    struct Entry: Codable, Hashable, Identifiable {
        let id: Int
        let spelling: Spelling.ID
        let language: DB.Language.Name.ID
        var recorded: Date
    }
}

extension DB.Entry {
    @Table
    struct Spelling: Codable, Hashable, Identifiable {
        let id: Int
        var text: String
    }

    @Table
    struct Definition: Codable, Hashable, Identifiable {
        let id: Int
        var text: String
    }

    @Table
    struct Usage: Codable, Hashable, Identifiable {
        let id: Int
        var text: String
    }

    @Table
    struct Keyword: Codable, Hashable, Identifiable {
        let id: Int
        var text: String
        var description: String
    }

    @Table
    struct Pronunciation: Codable, Hashable, Identifiable {
        let id: Int
        var text: String
        var audioURL: URL?
    }

    @Table
    struct Image: Codable, Hashable, Identifiable {
        let id: Int
        var imageURL: URL
        var remote: Bool
    }

    @Table
    struct Impression: Codable, Hashable, Identifiable {
        let id: Int
        var mastery: Double
        var mode: String
        var recorded: Date
    }

    // MARK: Joins

    @Table
    struct Note: Codable, Hashable, Identifiable {
        let id: Int
        var entry: DB.Entry.ID
        var text: String
        var recorded: Date
    }

    enum Joins {
        @Table
        struct EntryLanguage: Codable, Hashable {
            var entry: DB.Entry.ID
            var language: DB.Language.Name.ID
        }

        @Table
        struct EntryRegion: Codable, Hashable {
            var entry: DB.Entry.ID
            var region: DB.Language.Region.ID
        }

        @Table
        struct EntryScript: Codable, Hashable {
            var entry: DB.Entry.ID
            var script: DB.Language.Script.ID
        }

        @Table
        struct EntrySpelling: Codable, Hashable {
            var entry: DB.Entry.ID
            var spelling: DB.Entry.Spelling.ID
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
            var origin: DB.Language.Name.ID
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
