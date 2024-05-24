//
//import ComposableArchitecture
//import Foundation
//
//extension Entry {
//    public var identifiedTranslations: IdentifiedArrayOf<Shared<Entry>> {
//        @Shared(.entries) var entries
//        return translations.compactMap({ $entries[id: $0] }).reduce(into: [], { $0.append($1) })
//    }
//    public var topTranslation: Entry? {
//        @Shared(.entries) var entries
//        return translations.first.flatMap({ entries[id: $0] })
//    }
//}
