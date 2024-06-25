
import StructuralModel
import SwiftUI

@Observable
class EntryDetailStore {
    
    var spelling: String = ""
    var image: SplashImage?
    var tags: [Tag] = []
    var pronunciation: Pronunciation?
    var translations: [Translation] = []
    var examples: [Example] = []
    var notes: [IndexedNote] = []
    var relatedEntries: [RelatedEntry] = []
    var actionHandler: (Action) -> Void = { EntryDetailStore.log(action: $0) }
    
    func send(_ action: Action) { actionHandler(action) }

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
                    EntryDetailTagsSection(store: store)
                    
                    EntryDetailTranslationsSection(store: store)
                    
                    EntryDetailExamplesSection(store: store)
                    
                    EntryDetailNotesSection(store: store)
                    
                    EntryDetailRelatedEntriesSection(store: store)
                    
                    Spacer(minLength: 32)
                    
                    AddAdditionalContextButton(
                        onAddNewPhoto: {
                            store.send(.addNewPhotoButtonTapped)
                        },
                        onAddNewPronunciation: {
                            store.send(.addNewPronunciationButtonTapped)
                        }
                    )
                }
                .safeAreaPadding(.bottom, 64)
                .scrollIndicators(.hidden)
            }
        }
    }
}


#Preview("Empty") {
    EntryDetailView(store: .init())
}

#Preview("Populated") {
    EntryDetailView(store: .mock)
}
