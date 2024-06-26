
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
    var collectionsMembership: [EntryCollection] = []
    var translations: [Translation] = []
    var examples: [Example] = []
    var notes: [IndexedNote] = []
    var relatedEntries: [RelatedEntry] = []
    var onAction: (Action) -> Void = { EntryDetailStore.log(action: $0) }
    var editMode: EditMode = .inactive
    
    func send(_ action: Action) {
        onAction(action)
    }

    enum Action {
        case newSpellingCommitted(value: String)
        
        case imageAddButtonTapped
        case imageEditButtonTapped
        case imageRemoveButtonTapped
        
        case pronunciationAddButtonTapped
        case pronunciationEditButtonTapped
        case pronunciationRemoveButtonTapped
        
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
        case translationsMoved(fromOffsets: IndexSet, toOffset: Int)
        case addTranslationButtonTapped
        case editTranslationsButtonTapped
        
        case exampleTapped(Example)
        case exampleEditButtonTapped(Example)
        case examplesMoved(fromOffsets: IndexSet, toOffset: Int)
        case exampleAddNewTranslationButtonTapped(Example)
        case exampleTranslationCellTapped(ExampleTranslation)
        case exampleTranslationEditButtonTapped(ExampleTranslation)
        case exampleTranslationRemoveButtonTapped(ExampleTranslation)
        case exampleTranslationsMoved(fromOffsets: IndexSet, toOffset: Int)
        case exampleSwipedAndDeleted(Example)
        case addExampleButtonTapped
        case editExamplesButtonTapped
        
        case noteCellTapped(IndexedNote)
        case noteEditButtonTapped(IndexedNote)
        case noteSwipedAndDeleted(IndexedNote)
        case notesMoved(fromOffsets: IndexSet, toOffset: Int)
        case addNoteButtonTapped
        case editNotesButtonTapped
        
        case individualCollectionButtonTapped(EntryCollection)
        case individualCollectionEditButtonTapped(EntryCollection)
        case individualCollectionRemoveButtonTapped(EntryCollection)
        case addToCollectionButtonTapped
        case editEntryCollectionsMembershipButtonTapped
        
        case individualRelatedEntryCellTapped(RelatedEntry)
        case individualRelatedEntryRemoveButtonTapped(RelatedEntry)
        case addRelatedEntryButtonTapped
        case editRelatedEntriesButtonTapped
        
    }

}

struct EntryDetailView: View {
    
    @State var store: EntryDetailStore
    
    func section(context: EntryDetailStore.ContextSection) -> some View {
        Group {
            switch context {
            case .tags:
                if !store.tags.isEmpty { EntryDetailTagsSection(store: store) }
            case .translations:
                if !store.translations.isEmpty { EntryDetailTranslationsSection(store: store) }
            case .examples:
                if !store.examples.isEmpty { EntryDetailExamplesSection(store: store) }
            case .notes:
                if !store.notes.isEmpty { EntryDetailNotesSection(store: store) }
            case .collections:
                if !store.collectionsMembership.isEmpty { EntryDetailCollectionsMembershipSection(store: store) }
            case .relatedEntries:
                if !store.relatedEntries.isEmpty { EntryDetailRelatedEntriesSection(store: store) }
            }
        }
    }
    
    func addFirst(context: EntryDetailStore.ContextSection) -> some View {
        Group {
            switch context {
            case .tags:
                if store.tags.isEmpty { EntryDetailAddFirstTagButton(store: store) }
            case .translations:
                if store.translations.isEmpty { EntryDetailAddFirstTranslationsButton(store: store) }
            case .examples:
                if store.examples.isEmpty { EntryDetailAddFirstExamplesButton(store: store) }
            case .notes:
                if store.notes.isEmpty { EntryDetailAddFirstNotesButton(store: store) }
            case .collections:
                if store.collectionsMembership.isEmpty { EntryDetailAddFirstCollectionMembershipButton(store: store) }
            case .relatedEntries:
                if store.relatedEntries.isEmpty { EntryDetailAddFirstRelatedEntriesButton(store: store) }
            }
        }
    }
    
    @Environment(\.editMode) var editMode
    
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
                    
                    ForEach(EntryDetailStore.ContextSection.allCases) {
                        section(context: $0)
                    }

                    Spacer()
                    
                    LazyVGrid(columns: [.init(), .init()]) {
                        ForEach(EntryDetailStore.ContextSection.allCases) {
                            addFirst(context: $0)
                        }
                    }
                }
                .scrollIndicators(.hidden)

            }
            .safeAreaPadding(.bottom, 64)
        }
        .synchronize(optional: editMode, with: $store.editMode, fallback: .inactive)
    }
}

public struct AppAccentColor: EnvironmentKey {
    public static var defaultValue: Color = .indigo
}

extension EnvironmentValues {
    var appAccentColor: Color {
        get { self[AppAccentColor.self] }
        set { self[AppAccentColor.self] = newValue }
    }
}


public struct EntryDetailViewStyle: EnvironmentKey {
    public static var defaultValue: EntryDetailViewStyle = .init()
    public var horizontalListMaskStops: [Color] = {
        var result: [Color] = []
        (0..<6).forEach { _ in
            result.append(.black)
        }
        result.append(.clear)
        return result
    }()
    public var primarySectionColors: PrimarySectionColors = .uniform(AppAccentColor.defaultValue)
    public struct PrimarySectionColors {
        public static func uniform(_ color: Color) -> Self {
            Self.init(
                header: color,
                tags: color,
                translation: color,
                examples: color,
                notes: color,
                collections: color,
                relatedWords: color,
                languageTag: color
            )
        }
        
        public var header: Color
        public var tags: Color
        public var translation: Color
        public var examples: Color
        public var notes: Color
        public var collections: Color
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
//    NavigationStack {
//        Text("Root").navigationDestination(isPresented: .constant(true)) {
            EntryDetailView(store: .mockAll(
                image: .none,
                except: [
//                    .examples,
    //                .notes,
    //                .translations,
    //                .relatedEntries,
    //                .tags
//                    .collections,
                ]
            ))
            .toolbar { EditButton() }
//        }
//    }
}
