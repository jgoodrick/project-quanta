
import SwiftUI
import StructuralModel

struct EntryDetailExamplesSection: View {
    
    @Bindable var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style
    
    var body: some View {
        Section {
            ForEach($store.examples) { example in
                ExampleCell(example: example) {
                    store.send(.exampleTapped(example.wrappedValue))
                } onTextEditorTask: {
                    store.send(.exampleTextEditorTask(example.wrappedValue))
                } onEditButtonTapped: {
                    store.send(.exampleEditButtonTapped(example.wrappedValue))
                } onRemoveButtonTapped: {
                    store.send(.exampleRemoveButtonTapped(example.wrappedValue))
                } onFocusDropped: {
                    store.send(.exampleFocusDropped(example.wrappedValue))
                } onTextCommitted: {
                    store.send(.exampleTextCommitted(example.wrappedValue))
                } onAddTranslationButtonTapped: { language in
                    store.send(.exampleAddTranslationButtonTapped(example: example.wrappedValue, language: language))
                } translationCell: { translation in
                    ExampleTranslationCell(translation: translation) {
                        store.send(.exampleTranslationCellTapped(translation.wrappedValue))
                    } onEditButtonTapped: {
                        store.send(.exampleTranslationEditButtonTapped(translation.wrappedValue))
                    } onRemoveButtonTapped: {
                        store.send(.exampleTranslationRemoveButtonTapped(translation.wrappedValue))
                    } onTextEditorTask: {
                        store.send(.exampleTranslationTextEditorTask(translation.wrappedValue))
                    } onFocusDropped: {
                        store.send(.exampleTranslationFocusDropped(translation.wrappedValue))
                    } onTextCommitted: {
                        store.send(.exampleTranslationTextCommitted(translation.wrappedValue))
                    }
                } draftTranslationCell: { draft in
                    ExampleTranslationDraftCell(translation: draft, unavailableLanguages: example.wrappedValue.representedLanguageIDs) {
                        store.send(.exampleTranslationDraftRemoveButtonTapped(draft.wrappedValue))
                    } onFocusDropped: {
                        store.send(.exampleTranslationDraftFocusDropped(draft.wrappedValue))
                    } onTextCommitted: {
                        store.send(.exampleTranslationDraftTextCommitted(draft.wrappedValue))
                    }
                }
            }
            .onDelete { indexSet in
                store.send(.exampleSwipedAndDeleted(indexSet: indexSet))
            }
            .onMove { indices, newOffset in
                store.send(.examplesMoved(fromOffsets: indices, toOffset: newOffset))
            }
        } header: {
            SectionHeader(title: "Examples") {
                AddExampleMenu {
                    store.send(.addExampleButtonTapped)
                } onEditButtonTapped: {
                    store.send(.editExamplesButtonTapped)
                }
            }
            .foregroundStyle(style.primarySectionColors.examples)
        }
    }
}

struct AddFirstExamplesButton: View {
        
    let store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        Button {
            store.send(.addExampleButtonTapped)
        } label: {
            Label {
                Text("Add Example")
            } icon: {
                Image(systemName: "text.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .foregroundStyle(style.primarySectionColors.examples)
    }
}

struct AddExampleMenu: View {
    
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new example", action: primaryAction)
                SuffixedEditButton("examples", additionalAction: onEditButtonTapped)
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

extension EntryDetailStore.Example {
    var representedLanguageIDs: Set<Language.ID> {
        var result = Set<Language.ID>()
        result.insert(language.id)
        result.formUnion(translations.keys)
        result.formUnion(draftTranslations.keys)
        return result
    }
}

struct ExampleCell: View {
    
    @Binding var example: EntryDetailStore.Example
    var onUnfocusedCellTapped: () -> Void
    var onTextEditorTask: () -> Void
    var onEditButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    var onAddTranslationButtonTapped: (Language?) -> Void
    let translationCell: (Binding<EntryDetailStore.ExampleTranslation>) -> ExampleTranslationCell
    let draftTranslationCell: (Binding<EntryDetailStore.ExampleTranslationDraft>) -> ExampleTranslationDraftCell
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode
    @Environment(\.languageTagMenuAvailableLanguages) private var availableLanguages
        
    var translations: [Binding<EntryDetailStore.ExampleTranslation>] {
        $example.translations.values.sorted {
            let lhs = availableLanguages.firstIndex(of: $0.wrappedValue.id.language) ?? .max
            let rhs = availableLanguages.firstIndex(of: $1.wrappedValue.id.language) ?? .max
            return lhs < rhs
        }
    }

    var draftTranslations: [Binding<EntryDetailStore.ExampleTranslationDraft>] {
        $example.draftTranslations.values.sorted {
            let lhs = availableLanguages.map(\.id).firstIndex(of: $0.wrappedValue.id.language) ?? .max
            let rhs = availableLanguages.map(\.id).firstIndex(of: $1.wrappedValue.id.language) ?? .max
            return lhs < rhs
        }
    }
    
    var moreLanguagesAreAvailableForTranslation: Bool {
        !availableLanguages.filter({ !example.representedLanguageIDs.contains($0.id) }).isEmpty
    }
    
    var body: some View {
        HStack(alignment: .top) {
            if editMode.isNotEditing {
                Text("•")
//                Text("\(index).")
            }

            VStack(alignment: .leading) {
                Group {
                    if editMode.isNotEditing {
                        Menu(
                            content: {
                                Button("Edit this example", action: onEditButtonTapped)
                                
                                Button("Remove this example", action: onRemoveButtonTapped)
                                
                                if moreLanguagesAreAvailableForTranslation {
                                    Button("Add new translation") {
                                        onAddTranslationButtonTapped(nil)
                                    }
                                }
                                
                            },
                            label: {
                                Text(example.value)
                                    .multilineTextAlignment(.leading)
                            },
                            primaryAction: {
                                editMode?.wrappedValue = .active
                                focused = true
                                onUnfocusedCellTapped()
                            }
                        )
                    } else {
                        SentenceEditor(
                            text: $example.draft,
                            onAddedNewLine: onTextCommitted
                        )
                        .task {
                            onTextEditorTask()
                        }
                    }
                }
                
                ForEach(translations) { translated in
                    translationCell(translated)
                }
                
                if editMode.isEditing {
                    
                    ForEach(draftTranslations) { draft in
                        draftTranslationCell(draft)
                    }
                    
                    if moreLanguagesAreAvailableForTranslation {
                        HStack {
                            Spacer()
                            
                            AddForLanguageMenu(
                                unavailableLanguages: example.representedLanguageIDs,
                                action: onAddTranslationButtonTapped
                            )
                        }
                        .padding(.top, 8)
                        .padding(.bottom)
                    }
                }
                
            }
        }
        .padding(.top, 8)
        .multilineTextAlignment(.leading)
        .foregroundStyle(.primary)
    }
}

struct ExampleTranslationCell: View {
    
    @Binding var translation: EntryDetailStore.ExampleTranslation
    var onUnfocusedCellTapped: () -> Void
    var onEditButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    var onTextEditorTask: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        HStack(alignment: .top) {

            VStack {
                
                LanguageTagMenu(language: translation.id.language)

                Spacer(minLength: 0)

            }
            .modifier(RemovableWhenEditing(onRemoveButtonTapped: onRemoveButtonTapped))
            
            Group {
                if editMode.isNotEditing {
                    Menu(
                        content: {
                            Button("Edit this translation", action: onEditButtonTapped)
                            Button("Remove this translation", action: onRemoveButtonTapped)
                        },
                        label: {
                            Text(translation.value)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 1)
                                .multilineTextAlignment(.leading)
                        },
                        primaryAction: {
                            editMode?.wrappedValue = .active
                            focused = true
                            onUnfocusedCellTapped()
                        }
                    )
                } else {
                    SentenceEditor(text: $translation.draft, onAddedNewLine: onTextCommitted)
                        .task {
                            onTextEditorTask()
                        }
                }
            }
        }
        .padding(.top, editMode.isNotEditing ? 0 : 8)
        .foregroundStyle(.primary)
    }
}

struct ExampleTranslationDraftCell: View {
    
    @Binding var translation: EntryDetailStore.ExampleTranslationDraft
    let unavailableLanguages: Set<Language>
    var onRemoveButtonTapped: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        HStack(alignment: .top) {

            VStack {
                
                LanguageTagMenu(language: translation.id.language.id, unavailableLanguages: unavailableLanguages) {
                    translation.id.language = $0
                }

                Spacer(minLength: 0)

            }
            .modifier(RemovableWhenEditing(onRemoveButtonTapped: onRemoveButtonTapped))

            SentenceEditor(
                text: $translation.draft,
                onAddedNewLine: onTextCommitted
            )
            
        }
        .padding(.top, editMode.isNotEditing ? 0 : 8)
        .foregroundStyle(.primary)
    }
}

struct RemovableWhenEditing: ViewModifier {
    
    let onRemoveButtonTapped: () -> Void
    
    @Environment(\.editMode) private var editMode

    func body(content: Content) -> some View {
        content.overlay {
            if editMode.isEditing {
                
                Button(action: onRemoveButtonTapped) {
                    Image(systemName: "minus.circle.fill")
                }
                .background {
                    Circle()
                        .fill(.background)
                        .padding(2)
                }
                .foregroundStyle(.red)
                .buttonStyle(.plain) // this stops a bug that was causing this button to react to every tap gesture in the entire cell (including other buttons)
                
            }
        }

    }
}

struct SentenceEditor: View {
    
    @Binding var text: String
    
    let onAddedNewLine: () -> Void
    
    var body: some View {
        TextEditor(text: $text)
            .onChange(of: text) { _, _ in
                if text.last?.isNewline ?? false {
                    text.removeLast()
                    onAddedNewLine()
                }
            }
            .padding(.horizontal, 8)
            .overlay {
                RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.0).foregroundStyle(.secondary)
            }
            .textInputAutocapitalization(.sentences)
            .disableAutocorrection(false)
    }
}


#Preview("Editing") {
    let store: EntryDetailStore = .mock
    return NewEntryDetailView(store: store)
        .task {
            store.editMode = .active
        }
}
