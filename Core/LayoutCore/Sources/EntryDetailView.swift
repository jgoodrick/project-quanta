
import StructuralModel
import SwiftUI

@Observable
class EntryDetailStore {
    
    init(spelling: String = "") {
        self.spelling = spelling
        self.draftSpelling = spelling
    }
    
    var spelling: String { didSet { draftSpelling = spelling } }
    var draftSpelling: String
    var image: SplashImage?
    var tags: [Tag] = []
    var pronunciation: Pronunciation?
    var collectionsMembership: [EntryCollection] = []
    var translations: [Translation] = []
    var examples: [Example] = []
    var notes: [IndexedNote] = []
    var relatedEntries: [RelatedEntry] = []
    var onAction: (Action) -> Void = { EntryDetailStore.log(action: $0) }
    var editMode: EditMode = .inactive {
        willSet {
            if spellingFocused, editMode == .active {
                spellingFocused = false
                if spelling != draftSpelling {
                    send(.newSpellingCommitted(value: draftSpelling))
                }
            }
        }
    }
    var spellingFocused: Bool = false
    
    func send(_ action: Action) {
        if case .spellingTapped = action { } else {
            spellingFocused = false
        }
        onAction(action)
    }

    enum Action {
        case spellingTapped
        case newSpellingCommitted(value: String)
        
        case imageAddButtonTapped
        case imageEditButtonTapped
        case imageRemoveButtonTapped
        
        case pronunciationPlayButtonTapped
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

    var populatedContextSections: [ContextSection] {
        ContextSection.allCases.filter {
            switch $0 {
            case .tags:
                !tags.isEmpty
            case .translations:
                !translations.isEmpty
            case .examples:
                !examples.isEmpty
            case .notes:
                !notes.isEmpty
            case .collections:
                !collectionsMembership.isEmpty
            case .relatedEntries:
                !relatedEntries.isEmpty
            }
        }
    }

    var unpopulatedContextSections: [ContextSection] {
        ContextSection.unpopulatedSuggestions.filter {
            switch $0 {
            case .tags:
                tags.isEmpty
            case .translations:
                translations.isEmpty
            case .examples:
                examples.isEmpty
            case .notes:
                notes.isEmpty
            case .collections:
                collectionsMembership.isEmpty
            case .relatedEntries:
                relatedEntries.isEmpty
            }
        }
    }
    
    var unpopulatedAdditionalContext: [AdditionalContext] {
        AdditionalContext.allCases.filter {
            switch $0 {
            case .pronunciation:
                pronunciation == nil
            case .image:
                image == nil
            }
        }
    }
}

struct EntryDetailPopulatedSection: View {
    @State var store: EntryDetailStore
    var body: some View {
        ForEach(store.populatedContextSections) {
            switch $0 {
            case .tags:
                EntryDetailTagsSection(store: store)
            case .translations:
                EntryDetailTranslationsSection(store: store)
            case .examples:
                EntryDetailExamplesSection(store: store)
            case .notes:
                EntryDetailNotesSection(store: store)
            case .collections:
                EntryDetailCollectionsMembershipSection(store: store)
            case .relatedEntries:
                EntryDetailRelatedEntriesSection(store: store)
            }
        }
    }
}

struct EntryDetailUnpopulatedSection: View {
    @State var store: EntryDetailStore
    var body: some View {
        ForEach(store.unpopulatedContextSections) {
            switch $0 {
            case .tags:
                AddFirstTagButton(store: store)
            case .translations:
                AddFirstTranslationsButton(store: store)
            case .examples:
                AddFirstExamplesButton(store: store)
            case .notes:
                AddFirstNotesButton(store: store)
            case .collections:
                AddFirstCollectionMembershipButton(store: store)
            case .relatedEntries:
                AddFirstRelatedEntriesButton(store: store)
            }
        }
    }
}

struct EntryDetailUnpopulatedAdditionalContext: View {
    @State var store: EntryDetailStore
    var body: some View {
        ForEach(store.unpopulatedAdditionalContext) {
            switch $0 {
            case .pronunciation:
                PronunciationButton(store: store)
            case .image:
                SplashImageButton(store: store)
            }
        }
    }
}

struct EntryDetailView: View {
    
    @State var store: EntryDetailStore
    
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
                    
                    EntryDetailPopulatedSection(store: store)

                    Spacer()
                    
                    if editMode.isNotEditing {
                        LazyVGrid(columns: [.init(), .init()]) {
                            EntryDetailUnpopulatedSection(store: store)
                            EntryDetailUnpopulatedAdditionalContext(store: store)
                        }
                        .environment(\.roundedTwoToneButton.verticalPadding, 32)
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
    public var buttonTextAlignment: HorizontalAlignment = .leading
    public var primarySectionColors: PrimarySectionColors = .uniform(AppAccentColor.defaultValue)
    public struct PrimarySectionColors {
        public static func uniform(_ color: Color) -> Self {
            Self.init(
                additionalContext: color,
                image: color,
                pronunciation: color,
                tags: color,
                translation: color,
                examples: color,
                notes: color,
                collections: color,
                relatedWords: color,
                languageTag: color
            )
        }
        
        public var additionalContext: Color
        public var image: Color
        public var pronunciation: Color
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
    NavigationStack {
        Text("Root").navigationDestination(isPresented: .constant(true)) {
            EntryDetailView(store: .mockAll(
//                image: .systemName("star.circle"),
//                pronunciation: .init(),
                except: [
                    .examples,
                    .notes,
                    .translations,
                    .relatedEntries,
                    .tags,
                    .collections,
                ]
            ))
            .toolbar { EditButton() }
        }
    }
}
