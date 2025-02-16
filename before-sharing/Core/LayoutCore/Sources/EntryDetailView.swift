
import StructuralModel
import SwiftUI
import Combine

@MainActor
@Observable
@dynamicMemberLookup
class EntryDetailStore {
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<State, T>) -> T {
        get { state[keyPath: keyPath] }
        set { state[keyPath: keyPath] = newValue }
    }
    
    init(
        state: State,
        onAction: @escaping (Action) -> Void,
        uuidGenerator: @escaping () -> UUID = UUID.init,
        currentLanguage: @escaping () -> Language = { (try? Language.init(bcp47: Locale.current.identifier)) ?? .english }
    ) {
        self.state = state
        self.onAction = onAction
        self.uuid = uuidGenerator
        self.currentLanguage = currentLanguage
    }
            
    struct State {
        var entry: Entry
        var image: SplashImage?
        var tags: [Tag]
        var pronunciation: Pronunciation?
        var collectionsMembership: [EntryCollection]
        var translations: [Translation]
        var translationDrafts: [TranslationDraft]
        var examples: [Example]
        var exampleDrafts: [ExampleDraft]
        var notes: [Note]
        var noteDrafts: [NoteDraft]
        var relatedEntries: [RelatedEntry]
        var editMode: EditMode = .inactive
        var focused: FocusedField?
        enum FocusedField: Hashable {
            case spelling
            case translation(Translation.ID)
            case translationDraft(TranslationDraft.ID)
            case example(Example.ID)
            case exampleDraft(ExampleDraft.ID)
            case exampleTranslation(ExampleTranslation.ID)
            case exampleTranslationDraft(ExampleTranslationDraft.ID)
            case note(Note.ID)
            case noteDraft(NoteDraft.ID)
        }
    }
    
    var state: State
    var uuid: () -> UUID
    var currentLanguage: () -> Language
        
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
        case spellingRemoveEntireEntryButtonTapped
        case spellingLanguageChanged(to: Language)

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
        case translationSwipedAndDeleted(indexSet: IndexSet)
        case translationsMoved(fromOffsets: IndexSet, toOffset: Int)
        case addTranslationButtonTapped
        case editTranslationsButtonTapped

        case translationDraftFocusDropped(TranslationDraft)
        case translationDraftTextCommitted(TranslationDraft)
        case translationDraftSwipedAndDeleted(indexSet: IndexSet)

        case exampleTapped(Example)
        case exampleTextEditorTask(Example)
        case exampleFocusDropped(Example)
        case exampleTextCommitted(Example)
        case exampleAddTranslationButtonTapped(example: Example, language: Language?)
        case exampleRemoveButtonTapped(Example)
        case exampleEditButtonTapped(Example)
        case examplesMoved(fromOffsets: IndexSet, toOffset: Int)
        case exampleSwipedAndDeleted(indexSet: IndexSet)
        case addExampleButtonTapped
        case editExamplesButtonTapped

        case exampleTranslationCellTapped(ExampleTranslation)
        case exampleTranslationTextEditorTask(ExampleTranslation)
        case exampleTranslationFocusDropped(ExampleTranslation)
        case exampleTranslationTextCommitted(ExampleTranslation)
        case exampleTranslationEditButtonTapped(ExampleTranslation)
        case exampleTranslationRemoveButtonTapped(ExampleTranslation)
        
        case exampleTranslationDraftFocusDropped(ExampleTranslationDraft)
        case exampleTranslationDraftTextCommitted(ExampleTranslationDraft)
        case exampleTranslationDraftRemoveButtonTapped(ExampleTranslationDraft)
        
        case noteCellTapped(Note)
        case noteTextEditorTask(Note)
        case noteFocusDropped(Note)
        case noteTextCommitted(Note)
        case noteEditButtonTapped(Note)
        case noteRemoveButtonTapped(Note)
        case noteSwipedAndDeleted(indexSet: IndexSet)
        case notesMoved(fromOffsets: IndexSet, toOffset: Int)
        case addNoteButtonTapped
        case editNotesButtonTapped
        
        case noteDraftFocusDropped(NoteDraft)
        case noteDraftTextCommitted(NoteDraft)
        case noteDraftSwipedAndDeleted(indexSet: IndexSet)

        case individualCollectionButtonTapped(EntryCollection)
        case individualCollectionEditButtonTapped(EntryCollection)
        case individualCollectionRemoveButtonTapped(EntryCollection)
        case addToCollectionButtonTapped
        case editEntryCollectionsMembershipButtonTapped
        
        case individualRelatedEntryCellTapped(RelatedEntry)
        case individualRelatedEntryRemoveButtonTapped(RelatedEntry)
        case addRelatedEntryButtonTapped
        case editRelatedEntriesButtonTapped
        
        case didBeginEditing
        case didEndEditing
    }

}

public struct NewEntryDetailView: View {
    internal init(store: EntryDetailStore) {
        self.store = store
    }
    
    public init() {
        self.store = .mockAll(
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
        )
    }
        
    @Bindable var store: EntryDetailStore
    
    @Environment(\.editMode) private var editMode
    
    public var body: some View {
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
        .modifier(OnEditModeChanged(onBegan: { store.send(.didBeginEditing) }, onEnded: { store.send(.didEndEditing) }))
    }
}

public struct AppAccentColor: EnvironmentKey, Sendable {
    public static let defaultValue: Color = .indigo
}

extension EnvironmentValues {
    var appAccentColor: Color {
        get { self[AppAccentColor.self] }
        set { self[AppAccentColor.self] = newValue }
    }
}


public struct NewEntryDetailViewStyle: EnvironmentKey, Sendable {
    public static let defaultValue: NewEntryDetailViewStyle = .init()
    public var buttonTextAlignment: HorizontalAlignment = .leading
    public var primarySectionColors: PrimarySectionColors = .uniform(AppAccentColor.defaultValue)
    public struct PrimarySectionColors: Sendable {
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
    var entryDetail: NewEntryDetailViewStyle {
        get { self[NewEntryDetailViewStyle.self] }
        set { self[NewEntryDetailViewStyle.self] = newValue }
    }
}

#Preview("Empty") {
    NewEntryDetailView(store: .mockEmpty)
}

#Preview("Populated") {
    NavigationStack {
        Text("Root").navigationDestination(isPresented: .constant(true)) {
            NewEntryDetailView(store: .mockAll(
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
