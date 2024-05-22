
enum Ukrainian {
    enum Tag {
        case function(Function)
        case gender(Gender)
        case linguisticCase(LinguisticCase)
        case number(Number)
        case tense(Tense)
        case person(Person)
        case voice(Voice)
        case aspect(Aspect)
        case transivity(Transivity)
        case mood(Mood)
        public enum Function: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case noun
            case adjective
            case pronoun
            case numeral
            
            case verb
            case adverb
            
            case preposition
            
            case expression
        }
        
        public enum Gender: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case masculine
            case feminine
            case neuter
        }
        
        public enum LinguisticCase: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case nominative //who, what?
            case genitive //whose?
            case dative //to give to whom?
            case accusative //to search for whom?
            case instrumental //who/what to handle with?
            case locative //only with preposition -- location, not destination
            case vocative //direct speech when addressing someone ("Mother, ...")
        }
        
        public enum Number: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case allNumbers
            case allPlurals
            case fiveToTen
            case twoToFour
            case singular
            case zero
        }
        
        public enum Tense: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case present
            case future
            case past
        }
        
        public enum Person: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case first
            case second
            case third
        }
        
        public enum Voice: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case active
            case passive
        }
        
        public enum Aspect: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case perfective
            case imperfective
        }
        
        public enum Transivity: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case transitive
            case intransitive
        }
        
        public enum Mood: String, Codable, Sendable, Identifiable {
            public var id: String { rawValue }
            case indicative
            case subjunctive
            case imperative
        }
    }
}
