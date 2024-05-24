//
//import ComposableArchitecture
//import Foundation
//import SwiftUI
//import SwiftData
//
//
//@ObservableState
//public struct Entry: Identifiable, Equatable, Codable, Sendable {
//        
//    public let id: UUID
//    public var locale: Locale
//    public var added: Date
//    public var lastModified: Date
//    public var spelling: String
//    
//    public var translations: [UUID] = []
//    public var examples: [String] = []
//    public var notes: [String] = []
//
//    // meta
//    
//
////    public var lastReviewed: Date? = .none
////    public var collections: Set<String> = []
////    public var priority: Int = 0
////    public var archived: Bool = false
////    
////    // tags
////    public var function: Set<Function> = []
////    public var gender: Set<Gender> = []
////    public var number: Set<Number> = []
////    
////    // noun tags
////    public var linguisticCase: Set<LinguisticCase> = []
////    
////    // verb tags
////    public var tense: Set<Tense> = []
////    public var person: Set<Person> = []
////    public var voice: Set<Voice> = []
////    public var aspect: Set<Aspect> = []
////    public var transivity: Set<Transivity> = []
////    public var mood: Set<Mood> = []
//    
//    // additional tags
////    public var alternateSpellings: Set<String> = []
////    public var custom: Set<String> = []
//    
//    // additional info
////    public var root: UUID? = .none
////    public var accentIndices: Set<Int>? = .none
////    public var highlightedRanges: [ClosedRange<Int>: String] = [:] // value is hex code color
////    public var audioFile: URL? = .none
////    public var related: [UUID] = [] // array instead of set due to user determined priority
//    
//    static func mock(id: Int, locale: Locale = .current, spelling: String, added: Date = .now, lastModified: Date = .now) -> Self {
//        .init(id: .init(id), locale: locale, added: added, lastModified: lastModified, spelling: spelling)
//    }
//}
//
