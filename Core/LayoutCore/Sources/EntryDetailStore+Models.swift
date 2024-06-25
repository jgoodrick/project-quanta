
import Foundation
import StructuralModel

extension EntryDetailStore {
    
    struct Pronunciation {
        var audio: URL?
    }
    
    struct Tag: Identifiable {
        var id: Int { index }
        var index: Int
        var title: String
    }
    
    struct Example: Identifiable {
        var id: Int { index }
        var index: Int
        var value: String
        var translations: [ExampleTranslation] = []
    }
    
    struct Translation: Identifiable {
        var id: String { value }
        var value: String
        var language: Language
    }
    
    struct ExampleTranslation: Identifiable {
        var id: String { value }
        var exampleID: Example.ID
        var value: String
        var language: Language
    }
    
    struct IndexedNote: Identifiable {
        var id: Int { index }
        var index: Int
        var value: String
    }
    
    struct RelatedEntry: Identifiable {
        var id: Int { index }
        var index: Int
        var spelling: String
    }

}
