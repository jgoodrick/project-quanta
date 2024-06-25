
import StructuralModel
import SwiftUI

@Observable
class EntryDetailStore {
    var spelling: String = "кванти"
    var image: SplashImage? = .systemName("star.circle")
    var tags: [Tag] = [
        .init(index: 0, title: "noun"),
        .init(index: 1, title: "plural"),
        .init(index: 2, title: "masculine"),
    ]
    var pronunciation: Pronunciation?
    var translations: [Translation] = [
        .init(
            value: "quanta",
            language: .english
        ),
        .init(
            value: "cuantos",
            language: .spanish
        ),
    ]
    var examples: [Example] = [
        .init(
            index: 1,
            value: "Учені досліджували властивості квантів у рамках нової теорії фізики.",
            translations: [
                .init(
                    exampleID: 1,
                    value: "Scientists studied the properties of quanta within the framework of a new theory in physics.",
                    language: .english
                ),
                .init(
                    exampleID: 1,
                    value: "Los científicos investigaron las propiedades de los cuantos en el marco de una nueva teoría de la física.",
                    language: .spanish
                ),
            ]
        ),
        .init(
            index: 2,
            value: "Квантова механіка описує поведінку частинок на рівні квантів.",
            translations: [
                .init(
                    exampleID: 2,
                    value: "Quantum mechanics describes the behavior of particles at the level of quanta.",
                    language: .english
                ),
            ]
        ),
    ]
    
    var notes: [IndexedNote] = [
        .init(
            index: 1,
            value: "this word is really only used in physics contexts in Ukrainian"
        ),
    ]
    
    var relatedEntries: [RelatedEntry] = [
        .init(index: 0, spelling: "Квантова"),
        .init(index: 1, spelling: "квантів"),
        .init(index: 2, spelling: "Квантова"),
    ]
    
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
    
    func send(_ action: Action) {
        log(action)
    }
    
    private func log(_ action: Action) {
        switch action {
        case .newSpellingCommitted(let value):
            print("committed the new spelling value: \(value)")
        case .pronunciationButtonTapped:
            print("tapped pronunciation button")
        case .pronunciationEditButtonTapped:
            print("tapped edit pronunciation")
        case .addToCollectionButtonTapped:
            print("tapped add to collection")
        case .editCollectionMembershipButtonTapped:
            print("tapped edit collection memberships")
        case .individualTagButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .individualTagEditButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .individualTagRemoveButtonTapped(let tag):
            print("\(tag.title) tag button tapped")
        case .addTagButtonTapped:
            print("tapped add tag button")
        case .editTagsButtonTapped:
            print("tapped edit tags button")
        case .translationTapped(let translation):
            print("tapped translation: \(translation)")
        case .translationEditButtonTapped(let translation):
            print("tapped edit translation: \(translation)")
        case .translationGoToDetailButtonTapped(let translation):
            print("tapped go to translation: \(translation)")
        case .translationRemoveButtonTapped(let translation):
            print("tapped remove translation: \(translation)")
        case .translationSwipedAndDeleted(let removed):
            print("deleted \(removed.value)")
        case .addTranslationButtonTapped:
            print("tapped add translation button")
        case .editTranslationsButtonTapped:
            print("tapped edit translations button")
        case .exampleTapped(let example):
            print("tapped example: \(example.id)")
        case .exampleEditButtonTapped(let example):
            print("tapped edit example: \(example.id)")
        case .exampleAddNewTranslationButtonTapped(let example):
            print("tapped add new translation to example: \(example.id)")
        case .exampleTranslationCellTapped(let translation):
            print("tapped example translation cell: \(translation.id)")
        case .exampleTranslationEditButtonTapped(let translation):
            print("tapped edit example translation cell: \(translation.id)")
        case .exampleTranslationRemoveButtonTapped(let translation):
            print("tapped remove example translation cell: \(translation.id)")
        case .exampleSwipedAndDeleted(let removed):
            print("deleted \(removed.value)")
        case .addExampleButtonTapped:
            print("tapped add example button")
        case .editExamplesButtonTapped:
            print("tapped edit examples button")
        case .noteCellTapped(let note):
            print("tapped note: \(note)")
        case .noteEditButtonTapped(let note):
            print("tapped edit note: \(note)")
        case .noteSwipedAndDeleted(let removed):
            print("deleted \(removed.value)")
        case .addNoteButtonTapped:
            print("tapped add note button")
        case .editNotesButtonTapped:
            print("tapped edit notes button")
        case .individualRelatedEntryCellTapped(let entry):
            print("\(entry.spelling) button tapped")
        case .individualRelatedEntryRemoveButtonTapped(let entry):
            print("\(entry.spelling) remove button tapped")
        case .addRelatedEntryButtonTapped:
            print("tapped add related word button")
        case .editRelatedEntriesButtonTapped:
            print("tapped edit related words button")
        case .addNewPhotoButtonTapped:
            print("tapped add new photo menu button")
        case .addNewPronunciationButtonTapped:
            print("tapped add new pronunciation menu button")
        }
    }
    
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



struct EntryDetailContent: View {
    
    @State var store: EntryDetailStore
        
    var body: some View {
        VStack(spacing: 0) {
            store.image
                .frame(maxHeight: 100)
                .background {
                    Rectangle().fill(.black).ignoresSafeArea()
                }

            VStack {
                HStack {
                    
                    EntrySpellingField(spelling: store.spelling) {
                        store.send(.newSpellingCommitted(value: $0))
                    }
                    
                    PronunciationButton(pronunciation: store.pronunciation) {
                        store.send(.pronunciationButtonTapped)
                    } onLongPressMenuEditButtonTapped: {
                        store.send(.pronunciationEditButtonTapped)
                    }

                    Spacer()
                    
                    AddToCollectionButton {
                        store.send(.addToCollectionButtonTapped)
                    } onLongPressMenuEditButtonTapped: {
                        store.send(.editCollectionMembershipButtonTapped)
                    }
                    .foregroundStyle(.mint)
                    
                }
                .padding([.leading, .top, .trailing])
                
                PlainList {
                    Section {
                        HStack {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(store.tags) { tag in
                                        IndividualTagButton(tag: tag) {
                                            store.send(.individualTagButtonTapped(tag))
                                        } onLongPressMenuEditButtonTapped: {
                                            store.send(.individualTagEditButtonTapped(tag))
                                        } onLongPressMenuRemoveButtonTapped: {
                                            store.send(.individualTagRemoveButtonTapped(tag))
                                        }
                                    }
                                }
                            }
                            .scrollClipDisabled()
                            
                            AddTagButton {
                                store.send(.addTagButtonTapped)
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.editTagsButtonTapped)
                            }
                        }
                        .foregroundStyle(.cyan)
                    }
                    
                    Section {
                        ForEach(store.translations) { translation in
                            TranslationCell(translation: translation) {
                                store.send(.translationTapped(translation))
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.translationEditButtonTapped(translation))
                            } onLongPressMenuGoToDetailButtonTapped: {
                                store.send(.translationGoToDetailButtonTapped(translation))
                            } onLongPressMenuRemoveButtonTapped: {
                                store.send(.translationRemoveButtonTapped(translation))
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach {
                                let translation = store.translations.remove(at: $0)
                                store.send(.translationSwipedAndDeleted(translation))
                            }
                        }
                    } header: {
                        SectionHeader(title: "Translations") {
                            AddTranslationButton {
                                store.send(.addTranslationButtonTapped)
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.editTranslationsButtonTapped)
                            }
                        }
                        .foregroundStyle(.purple)
                    }
                    
                    Section {
                        ForEach(store.examples) { example in
                            ExampleCell(example: example) {
                                store.send(.exampleTapped(example))
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.exampleEditButtonTapped(example))
                            } onLongPressMenuAddNewExampleTranslationButtonTapped: {
                                store.send(.exampleAddNewTranslationButtonTapped(example))
                            } translationCell: { translation in
                                ExampleTranslationCell(translation: translation) {
                                    store.send(.exampleTranslationCellTapped(translation))
                                } onLongPressMenuEditButtonTapped: {
                                    store.send(.exampleTranslationEditButtonTapped(translation))
                                } onLongPressMenuRemoveButtonTapped: {
                                    store.send(.exampleTranslationRemoveButtonTapped(translation))
                                }
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach {
                                let example = store.examples.remove(at: $0)
                                store.send(.exampleSwipedAndDeleted(example))
                            }
                        }
                    } header: {
                        SectionHeader(title: "Examples") {
                            AddExampleButton {
                                store.send(.addExampleButtonTapped)
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.editExamplesButtonTapped)
                            }
                        }
                        .foregroundStyle(.indigo)
                    }
                    
                    Section {
                        ForEach(store.notes) { note in
                            NoteCell(note: note) {
                                store.send(.noteCellTapped(note))
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.noteEditButtonTapped(note))
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach {
                                let note = store.notes.remove(at: $0)
                                store.send(.noteSwipedAndDeleted(note))
                            }
                        }
                    } header: {
                        SectionHeader(title: "Notes") {
                            AddNoteButton {
                                store.send(.addNoteButtonTapped)
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.editNotesButtonTapped)
                            }
                        }
                        .foregroundStyle(.purple)
                    }
                    
                    Section {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(store.relatedEntries) { entry in
                                    IndividualRelatedEntryButton(relatedWord: entry) {
                                        store.send(.individualRelatedEntryCellTapped(entry))
                                    } onLongPressMenuRemoveButtonTapped: {
                                        store.send(.individualRelatedEntryRemoveButtonTapped(entry))
                                    }
                                }
                            }
                        }
                    } header: {
                        SectionHeader(title: "See Also") {
                            AddRelatedEntryButton {
                                store.send(.addRelatedEntryButtonTapped)
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.editRelatedEntriesButtonTapped)
                            }
                        }
                    }
                    .foregroundStyle(.indigo)
                    
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

struct PlainList<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        List {
            content()
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

struct EntrySpellingField: View {
    
    let spelling: String
    let onChangeCommitted: (String) -> Void
    
    @State private var draft: String = ""
    @State private var isEditing: Bool = false
    
    private func beginEditing() {
        draft = spelling
        isEditing = true
    }
    
    private func reset() {
        isEditing = false
        draft = ""
    }
    
    var body: some View {
        Group {
            if isEditing {
                TextField("Spelling", text: $draft) {
                    defer { reset() }
                    let committed = draft
                    if committed != spelling {
                        onChangeCommitted(committed)
                    }
                }
            } else {
                Text(spelling)
                    .onLongPressGesture {
                        beginEditing()
                    }
            }
        }
        .font(.largeTitle.bold())
    }
}

struct PronunciationButton: View {
    
    let pronunciation: EntryDetailStore.Pronunciation?
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Edit pronunciation", systemImage: "pencil", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                if pronunciation?.audio != nil {
                    Image(systemName: "waveform.path")
                } else {
                    Image(systemName: "waveform.path.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
        .environment(\.adaptiveHighlightableTwoTone.lightMode.standard.background, .clear)
        .foregroundStyle(.blue)
    }
}

struct AddTagButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new tag", action: primaryAction)
                Button("Edit tags", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Tag")
                } icon: {
                    Image(systemName: "tag")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct IndividualTagButton: View {
    
    let tag: EntryDetailStore.Tag
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    let onLongPressMenuRemoveButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Go to this tag", action: primaryAction)
                Button("Edit this tag", action: onLongPressMenuEditButtonTapped)
                Button("Remove this tag", action: onLongPressMenuRemoveButtonTapped)
            },
            label: {
                Text(tag.title)
                    .italic()
                    .padding(6)
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone(highlighted: false))
        .environment(\.roundedTwoToneButton.square, false)
        .environment(\.roundedTwoToneButton.dimension, .none)
    }
}

struct AddToCollectionButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add to a new collection", action: primaryAction)
                Button("Edit collection membership", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add to Collection")
                } icon: {
                    Image(systemName: "rectangle.stack.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}


struct SectionHeader<Icon: View>: View {
    
    let title: String
    let icon: () -> Icon
    
    var body: some View {
        HStack(alignment: .bottom) {
            
            Text(title)
                .font(.title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            icon()
            
        }
    }
}

struct AddTranslationButton: View {
    
    let primaryAction: () -> Void
    var onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new translation", action: primaryAction)
                Button("Edit translations", action: onLongPressMenuEditButtonTapped)
            }, 
            label: {
                Label {
                    Text("Add Translation")
                } icon: {
                    Image(systemName: "character.book.closed.fill")
                }
            }, 
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct TranslationCell: View {
    
    let translation: EntryDetailStore.Translation
    let primaryAction: () -> Void
    var onLongPressMenuEditButtonTapped: () -> Void
    var onLongPressMenuGoToDetailButtonTapped: () -> Void
    var onLongPressMenuRemoveButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            LanguageTagView(language: translation.language)
            
            Menu(
                content: {
                    Button("Edit this translation", action: onLongPressMenuEditButtonTapped)
                    Button("Go to translation detail", action: onLongPressMenuGoToDetailButtonTapped)
                    Button("Remove this translation", action: onLongPressMenuRemoveButtonTapped)
                },
                label: {
                    Text(translation.value)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                },
                primaryAction: primaryAction
            )
        }
        .foregroundStyle(.primary)
    }
}

struct AddExampleButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new example", action: primaryAction)
                Button("Edit examples", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Example")
                } icon: {
                    Image(systemName: "text.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct ExampleCell: View {
    
    let example: EntryDetailStore.Example
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    let onLongPressMenuAddNewExampleTranslationButtonTapped: () -> Void
    let translationCell: (EntryDetailStore.ExampleTranslation) -> ExampleTranslationCell
        
    var body: some View {
        HStack(alignment: .top) {
            Text("\(example.index).")

            VStack {
                Menu(
                    content: {
                        Button("Edit Example", action: onLongPressMenuEditButtonTapped)
                        Button("Add new example translation", action: onLongPressMenuAddNewExampleTranslationButtonTapped)
                    },
                    label: {
                        Text(example.value)
                            .multilineTextAlignment(.leading)
                    },
                    primaryAction: primaryAction
                )
                .foregroundStyle(.primary)
                
                ForEach(example.translations) { translated in
                    translationCell(translated)
                }
            }
        }
        .padding(.top, 8)
        .multilineTextAlignment(.leading)

    }
}

struct ExampleTranslationCell: View {
    
    let translation: EntryDetailStore.ExampleTranslation
    let primaryAction: () -> Void
    var onLongPressMenuEditButtonTapped: () -> Void
    var onLongPressMenuRemoveButtonTapped: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            
            LanguageTagView(language: translation.language)
            
            Menu(
                content: {
                    Button("Edit this translation", action: onLongPressMenuEditButtonTapped)
                    Button("Remove this translation", action: onLongPressMenuRemoveButtonTapped)
                },
                label: {
                    Text(translation.value)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 1)
                        .multilineTextAlignment(.leading)
                },
                primaryAction: primaryAction
            )
        }
        .foregroundStyle(.primary)
    }
}


struct AddNoteButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Add a new note", action: primaryAction)
                Button("Edit notes", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Note")
                } icon: {
                    Image(systemName: "pencil.tip.crop.circle.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct NoteCell: View {
    
    let note: EntryDetailStore.IndexedNote
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Edit Note", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                HStack(alignment: .top) {
                    Text("\(note.index).")
                    Text(note.value)
                }
                .padding(.top, 8)
                .multilineTextAlignment(.leading)
            },
            primaryAction: primaryAction
        )
        .foregroundStyle(.primary)
    }
}

struct AddRelatedEntryButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new related word", action: primaryAction)
                Button("Edit related words", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Related Word")
                } icon: {
                    Image(systemName: "link.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct IndividualRelatedEntryButton: View {
    
    let relatedWord: EntryDetailStore.RelatedEntry
    let primaryAction: () -> Void
    let onLongPressMenuRemoveButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Go to this word", action: primaryAction)
                Button("Disconnect these words", action: onLongPressMenuRemoveButtonTapped)
            },
            label: {
                Text(relatedWord.spelling)
                    .italic()
                    .padding(6)
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone(highlighted: false))
        .environment(\.roundedTwoToneButton.square, false)
        .environment(\.roundedTwoToneButton.dimension, .none)
    }
}

struct AddAdditionalContextButton: View {
    
    let onAddNewPhoto: () -> Void
    let onAddNewPronunciation: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new photo", systemImage: "photo.badge.plus", action: onAddNewPhoto)
                Button("Add a new pronunciation", systemImage: "waveform.badge.plus", action: onAddNewPronunciation)
            },
            label: {
                Label {
                    Text("Add more context")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, false)
    }
}

struct LanguageTagView: View {
    
    let language: Language
    
    @Environment(\.languageNameFormatter) var formatter
    
    var body: some View {
        Menu {
            Text("This is ^[a \(formatter.displayName(for: language, style: .full))](inflect: true) translation")
        } label: {
            Text(formatter.displayName(for: language))
                .foregroundStyle(.background)
                .padding(4)
                .background(.secondary)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .foregroundStyle(.blue)
        }
    }
}

public struct LanguageNameFormatter: EnvironmentKey {
    public static var defaultValue: Self = .init()
    public enum Style {
        case full, short
    }
    var formatter: (Language, Style) -> String = { (language, style) in
        let fallback = language.id.rawValue
        let languageCode = language.primaryLanguage ?? fallback
        switch style {
        case .full:
            return Locale.current.localizedString(forLanguageCode: languageCode) ?? fallback
        case .short:
            return language.primaryLanguage ?? fallback
        }
    }
    public func displayName(for language: Language, style: Style = .short) -> String {
        formatter(language, style)
    }
    public mutating func update(formatter: @escaping (Language, Style) -> String) {
        self.formatter = formatter
    }
}

extension EnvironmentValues {
    public var languageNameFormatter: LanguageNameFormatter {
        get { self[LanguageNameFormatter.self] }
        set { self[LanguageNameFormatter.self] = newValue }
    }
}

#Preview {
    EntryDetailContent(store: .init())
}
