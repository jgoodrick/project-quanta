
import SwiftUI
import StructuralModel // Language

extension EntryDetailStore {
    
    enum ContextSection: CaseIterable, Identifiable {
        var id: Self { self }
        case tags
        case translations
        case examples
        case notes
        case collections
        case relatedEntries
        static var unpopulatedSuggestions: [Self] {
            [
                .translations,
                .examples,
                .tags,
                .notes,
                .collections,
                .relatedEntries,
            ]
        }
    }
    
    enum AdditionalContext: CaseIterable, Identifiable {
        var id: Self { self }
        case pronunciation
        case image
        static var unpopulatedSuggestions: [Self] {
            [
                .pronunciation,
                .image,
            ]
        }
    }
    
    enum SplashImage: View {
        case url(URL)
        case data(Data)
        case systemName(String)
        
        var body: some View {
            switch self {
            case .url(let url):
                AsyncImage(url: url)
            case .data(let data):
                UIImage(data: data).map(Image.init(uiImage:))?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .systemName(let name):
                Image(systemName: name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding(160)
                    .foregroundStyle(.white)
            }
        }
    }
    
    struct Entry {
        var id: UUID = .init()
        let spelling: String
        var draft: String = ""
        var language: Language
    }

    struct Pronunciation {
        var audio: URL?
    }
    
    struct EntryCollection: Identifiable {
        var id: UUID = .init()
        var title: String
    }
    
    struct Tag: Identifiable {
        var id: UUID = .init()
        var index: Int
        var title: String
    }
    
    struct Example: Identifiable {
        var id: UUID = .init()
        var index: Int
        var value: String
        var draft: String = ""
        var translations: [ExampleTranslation] = []
    }
    
    struct Translation: Identifiable {
        var id: UUID = .init()
        let value: String
        var draft: String = ""
        var language: Language
    }
    
    struct ExampleTranslation: Identifiable {
        var id: UUID = .init()
        var exampleID: Example.ID
        var value: String
        var draft: String = ""
        var language: Language
    }
    
    struct IndexedNote: Identifiable {
        var id: UUID = .init()
        var index: Int
        var value: String
        var draft: String = ""
    }
    
    struct RelatedEntry: Identifiable {
        var id: UUID = .init()
        var index: Int
        var spelling: String
    }

}
