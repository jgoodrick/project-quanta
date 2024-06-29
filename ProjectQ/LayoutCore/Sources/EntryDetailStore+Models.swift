
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
    
    struct Entry: Identifiable, EditableValue {
        var id: UUID
        var language: Language.ID
        let spelling: String
        var value: String { spelling }
        var draft: String = ""
    }

    struct Pronunciation {
        var audio: URL?
    }
    
    struct EntryCollection: Identifiable {
        var id: UUID
        var title: String
    }
    
    struct Tag: Identifiable {
        var id: UUID
        var title: String
    }
    
    struct Translation: Identifiable, EditableValue {
        var id: Entry.ID
        var language: Language.ID
        let value: String
        var draft: String = ""
    }
    
    struct TranslationDraft: Identifiable {
        var id: Translation.ID
        var language: Language.ID
        var additionalLanguages: [Language.ID]
        var draft: String = ""
    }
    
    struct Example: Identifiable, EditableValue {
        var id: UUID
        var language: Language.ID
        var value: String
        var draft: String = ""
        var translations: [Language.ID: ExampleTranslation] = [:]
        var draftTranslations: [Language.ID: ExampleTranslationDraft] = [:]
    }
    
    struct ExampleDraft: Identifiable {
        var id: Example.ID
        var language: Language.ID
        var draft: String = ""
        var draftTranslations: [Language.ID: ExampleTranslationDraft] = [:]
    }
    
    struct ExampleTranslation: Identifiable, EditableValue {
        var id: ID
        struct ID: Hashable {
            var example: Example.ID
            var language: Language.ID
        }
        var value: String
        var draft: String = ""
    }
    
    struct ExampleTranslationDraft: Identifiable {
        var id: ExampleTranslation.ID
        var draft: String = ""
    }
    
    struct Note: Identifiable, EditableValue {
        var id: UUID
        var value: String
        var draft: String = ""
    }
    
    struct NoteDraft: Identifiable {
        var id: Note.ID
        var draft: String = ""
    }
    
    struct RelatedEntry: Identifiable {
        var id: UUID
        var spelling: String
    }
    
}

protocol EditableValue {
    var value: String { get }
    var draft: String { get set }
}
