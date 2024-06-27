
import SwiftUI

struct EntryDetailExamplesSection: View {
    
    @Bindable var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
        Section {
            ForEach($store.examples) { example in
                ExampleCell(store: store, example: example) {
                    store.send(.exampleTapped(example.wrappedValue))
                } onEditButtonTapped: {
                    store.send(.exampleEditButtonTapped(example.wrappedValue))
                } onRemoveButtonTapped: {
                    store.send(.exampleRemoveButtonTapped(example.wrappedValue))
                } onFocusDropped: {
                    store.send(.exampleFocusDropped(example.wrappedValue))
                } onTextCommitted: {
                    store.send(.exampleTextCommitted(example.wrappedValue))
                } onAddNewExampleTranslationButtonTapped: {
                    store.send(.exampleAddNewTranslationButtonTapped(example.wrappedValue))
                } translationCell: { translation in
                    ExampleTranslationCell(translation: translation) {
                        store.send(.exampleTranslationCellTapped(translation.wrappedValue))
                    } onEditButtonTapped: {
                        store.send(.exampleTranslationEditButtonTapped(translation.wrappedValue))
                    } onRemoveButtonTapped: {
                        store.send(.exampleTranslationRemoveButtonTapped(translation.wrappedValue))
                    } onFocusDropped: {
                        store.send(.exampleTranslationFocusDropped(translation.wrappedValue))
                    } onTextCommitted: {
                        store.send(.exampleTranslationTextCommitted(translation.wrappedValue))
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
        .buttonStyle(.roundedTwoTone(square: true))
    }
}

struct ExampleCell: View {
    
    @Bindable var store: EntryDetailStore
    @Binding var example: EntryDetailStore.Example
    var onUnfocusedCellTapped: () -> Void
    var onEditButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    var onAddNewExampleTranslationButtonTapped: () -> Void
    let translationCell: (Binding<EntryDetailStore.ExampleTranslation>) -> ExampleTranslationCell
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        HStack(alignment: .top) {
            Text("\(example.index).")

            VStack(alignment: .leading) {
                Group {
                    if editMode.isNotEditing {
                        Menu(
                            content: {
                                Button("Edit this example", action: onEditButtonTapped)
                                Button("Add new example translation", action: onAddNewExampleTranslationButtonTapped)
                                Button("Remove this example", action: onRemoveButtonTapped)
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
                        TextEditor(text: $example.draft)
                            .padding(.horizontal, 8)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.0).foregroundStyle(.secondary)
                            }
                            .textInputAutocapitalization(.sentences)
                            .disableAutocorrection(false)
                            .task {
                                if example.value != example.draft {
                                    example.draft = example.value
                                }
                            }
                    }
                }
                
                ForEach($example.translations) { translated in
                    translationCell(translated)
                }
                .onMove { indices, newOffset in
                    store.send(.exampleTranslationsMoved(fromOffsets: indices, toOffset: newOffset))
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
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        HStack(alignment: .top) {
            
            LanguageTagView(language: translation.language)
            
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
                    TextEditor(text: $translation.draft)
                        .padding(.horizontal, 8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.0).foregroundStyle(.secondary)
                        }
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(false)
                        .task {
                            if translation.value != translation.draft {
                                translation.draft = translation.value
                            }
                        }
                }
            }
        }
        .foregroundStyle(.primary)
    }
}



#Preview("Empty") {
    EntryDetailExamplesSection(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailExamplesSection(store: .mock)
}
