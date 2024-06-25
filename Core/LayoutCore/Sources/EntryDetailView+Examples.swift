
import SwiftUI

struct EntryDetailExamplesSection: View {
    @State var store: EntryDetailStore
    var body: some View {
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



#Preview("Empty") {
    EntryDetailExamplesSection(store: .init())
}

#Preview("Populated") {
    EntryDetailExamplesSection(store: .mock)
}
