
import SwiftUI

struct EntryDetailExamplesSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
        Section {
            ForEach(store.examples) { example in
                ExampleCell(store: store, example: example) {
                    store.send(.exampleTapped(example))
                } onEditButtonTapped: {
                    store.send(.exampleEditButtonTapped(example))
                } onAddNewExampleTranslationButtonTapped: {
                    store.send(.exampleAddNewTranslationButtonTapped(example))
                } translationCell: { translation in
                    ExampleTranslationCell(translation: translation) {
                        store.send(.exampleTranslationCellTapped(translation))
                    } onEditButtonTapped: {
                        store.send(.exampleTranslationEditButtonTapped(translation))
                    } onRemoveButtonTapped: {
                        store.send(.exampleTranslationRemoveButtonTapped(translation))
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    store.send(.exampleSwipedAndDeleted(store.examples[$0]))
                }
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
        
    @State var store: EntryDetailStore
        
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
    
    let store: EntryDetailStore
    let example: EntryDetailStore.Example
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    let onAddNewExampleTranslationButtonTapped: () -> Void
    let translationCell: (EntryDetailStore.ExampleTranslation) -> ExampleTranslationCell
        
    var body: some View {
        HStack(alignment: .top) {
            Text("\(example.index).")

            VStack {
                Menu(
                    content: {
                        Button("Edit Example", action: onEditButtonTapped)
                        Button("Add new example translation", action: onAddNewExampleTranslationButtonTapped)
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
                .onMove { indices, newOffset in
                    store.send(.exampleTranslationsMoved(fromOffsets: indices, toOffset: newOffset))
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
    var onEditButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            
            LanguageTagView(language: translation.language)
            
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
                primaryAction: primaryAction
            )
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
