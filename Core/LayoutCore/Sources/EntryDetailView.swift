
import StructuralModel
import SwiftUI

@Observable
class EntryDetailStore {
    
    init(spelling: String = "") {
        self.spelling = spelling
    }
    
    var spelling: String = ""
    var image: SplashImage?
    var tags: [Tag] = []
    var pronunciation: Pronunciation?
    var translations: [Translation] = []
    var examples: [Example] = []
    var notes: [IndexedNote] = []
    var relatedEntries: [RelatedEntry] = []
    var onAction: (Action) -> Void = { EntryDetailStore.log(action: $0) }
    
    func send(_ action: Action) { onAction(action) }

    enum Action {
        case newSpellingCommitted(value: String)
        case pronunciationButtonTapped
        case pronunciationEditButtonTapped
        
        case addToCollectionButtonTapped
        case editCollectionMembershipButtonTapped
        
        case individualTagButtonTapped(Tag)
        case individualTagEditButtonTapped(Tag)
        case individualTagRemoveButtonTapped(Tag)
        case addTagButtonTapped
        case editTagsButtonTapped
        
        case translationTapped(Translation)
        case translationEditButtonTapped(Translation)
        case translationGoToDetailButtonTapped(Translation)
        case translationRemoveButtonTapped(Translation)
        case translationSwipedAndDeleted(Translation)
        case addTranslationButtonTapped
        case editTranslationsButtonTapped
        
        case exampleTapped(Example)
        case exampleEditButtonTapped(Example)
        case exampleAddNewTranslationButtonTapped(Example)
        case exampleTranslationCellTapped(ExampleTranslation)
        case exampleTranslationEditButtonTapped(ExampleTranslation)
        case exampleTranslationRemoveButtonTapped(ExampleTranslation)
        case exampleSwipedAndDeleted(Example)
        case addExampleButtonTapped
        case editExamplesButtonTapped
        
        case noteCellTapped(IndexedNote)
        case noteEditButtonTapped(IndexedNote)
        case noteSwipedAndDeleted(IndexedNote)
        case addNoteButtonTapped
        case editNotesButtonTapped
        
        case individualRelatedEntryCellTapped(RelatedEntry)
        case individualRelatedEntryRemoveButtonTapped(RelatedEntry)
        case addRelatedEntryButtonTapped
        case editRelatedEntriesButtonTapped
        
        case addNewPhotoButtonTapped
        case addNewPronunciationButtonTapped
    }

}

struct EntryDetailView: View {
    
    @State var store: EntryDetailStore
        
    var body: some View {
        VStack(spacing: 0) {
            store.image
                .frame(maxHeight: 100)
                .background {
                    Rectangle().fill(.black).ignoresSafeArea()
                }

            VStack {
                EntryDetailHeader(store: store)
                    .padding([.leading, .top, .trailing])
                
                PlainList {
                    
                    if !store.tags.isEmpty {
                        EntryDetailTagsSection(store: store)
                    }
                    
                    EntryDetailTranslationsSection(store: store)
                    
                    EntryDetailExamplesSection(store: store)

                    if store.tags.isEmpty {
                        EntryDetailTagsSection(store: store)
                    }

                    EntryDetailNotesSection(store: store)
                    
                    EntryDetailRelatedEntriesSection(store: store)
                        
                }
                .safeAreaPadding(.bottom, 64)
                .scrollIndicators(.hidden)
            }
        }
    }
}

public struct EntryDetailViewStyle: EnvironmentKey {
    public static var defaultValue: EntryDetailViewStyle = .init()
    public var primarySectionColors: PrimarySectionColors = .uniform(.indigo)
    public struct PrimarySectionColors {
        public static func uniform(_ color: Color) -> Self {
            Self.init(
                header: color,
                tags: color,
                translation: color,
                examples: color,
                notes: color,
                relatedWords: color,
                languageTag: color
            )
        }
        
        public var header: Color
        public var tags: Color
        public var translation: Color
        public var examples: Color
        public var notes: Color
        public var relatedWords: Color
        public var languageTag: Color
    }
}

extension EnvironmentValues {
    var entryDetail: EntryDetailViewStyle {
        get { self[EntryDetailViewStyle.self] }
        set { self[EntryDetailViewStyle.self] = newValue }
    }
}

#Preview("Empty") {
    EntryDetailView(store: .init(spelling: "escuela"))
}

#Preview("Populated") {
    EntryDetailView(store: .mock)
}
