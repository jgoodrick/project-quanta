
import StructuralModel
import SwiftUI
import Combine

@Observable
@dynamicMemberLookup
class EntryDetailStore {
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
        set { state[keyPath: keyPath] = newValue }
    }
    
    init(state: State, onAction: @escaping (Action) -> Void) {
        self.state = state
        self.onAction = onAction
    }
            
    struct State {
        var entry: Entry
        var image: SplashImage?
        var tags: [Tag]
        var pronunciation: Pronunciation?
        var collectionsMembership: [EntryCollection]
        var translations: [Translation]
        var examples: [Example]
        var notes: [IndexedNote]
        var relatedEntries: [RelatedEntry]
        var editMode: EditMode = .inactive
        var focused: FocusedField?
        enum FocusedField: Hashable {
            case spelling
            case translation(Translation.ID)
            case example(Example.ID)
        }
    }
    
    var state: State
        
    // Actions
    var onAction: (Action) throws -> Void

    func send(_ action: Action) {
        let beforeReducerRuns = state
        reduce(action: action)
        do {
            try onAction(action)
        } catch {
            print("EntryDetailStore.onAction Error: \(error.localizedDescription)")
            state = beforeReducerRuns
        }
    }
    
    enum Action {
        
        case spellingTapped
        case spellingTextCommitted
        case spellingFocusDropped
        case spellingEditButtonTapped
        case spellingRemoveButtonTapped

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
        case translationFocusDropped(Translation)
        case translationTextCommitted(Translation)
        case translationEditButtonTapped(Translation)
        case translationGoToDetailButtonTapped(Translation)
        case translationRemoveButtonTapped(Translation)
        case translationSwipedAndDeleted(indexSet: IndexSet)
        case translationsMoved(fromOffsets: IndexSet, toOffset: Int)
        case addTranslationButtonTapped
        case editTranslationsButtonTapped
        
        case exampleTapped(Example)
        case exampleFocusDropped(Example)
        case exampleTextCommitted(Example)
        case exampleRemoveButtonTapped(Example)
        case exampleEditButtonTapped(Example)
        case examplesMoved(fromOffsets: IndexSet, toOffset: Int)
        case exampleAddNewTranslationButtonTapped(Example)
        case exampleTranslationCellTapped(ExampleTranslation)
        case exampleTranslationFocusDropped(ExampleTranslation)
        case exampleTranslationTextCommitted(ExampleTranslation)
        case exampleTranslationEditButtonTapped(ExampleTranslation)
        case exampleTranslationRemoveButtonTapped(ExampleTranslation)
        case exampleTranslationsMoved(fromOffsets: IndexSet, toOffset: Int)
        case exampleSwipedAndDeleted(indexSet: IndexSet)
        case addExampleButtonTapped
        case editExamplesButtonTapped
        
        case noteCellTapped(IndexedNote)
        case noteEditButtonTapped(IndexedNote)
        case noteSwipedAndDeleted(indexSet: IndexSet)
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
        
    @Bindable var store: EntryDetailStore
    
    @Environment(\.editMode) private var editMode
    
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
    EntryDetailView(store: .mockEmpty)
}

#Preview("Populated") {
    NavigationStack {
        Text("Root").navigationDestination(isPresented: .constant(true)) {
            EntryDetailView(store: .mockAll(
                image: .systemName("star.circle"),
                pronunciation: .init(),
                except: [
//                    .examples,
//                    .notes,
//                    .translations,
//                    .relatedEntries,
//                    .tags,
//                    .collections,
                ]
            ))
            .toolbar { EditButton() }
        }
    }
}
