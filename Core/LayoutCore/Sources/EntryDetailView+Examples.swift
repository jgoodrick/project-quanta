
import SwiftUI

struct EntryDetailExamplesSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

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
            Group {
                if store.examples.isEmpty {
                    AddExampleButton {
                        store.send(.addExampleButtonTapped)
                    }
                } else {
                    SectionHeader(title: "Examples") {
                        AddExampleMenu {
                            store.send(.addExampleButtonTapped)
                        } onLongPressMenuEditButtonTapped: {
                            store.send(.editExamplesButtonTapped)
                        }
                    }
                }
            }
            .foregroundStyle(style.primarySectionColors.examples)
        }
    }
}

struct AddExampleButton: View {
    
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Example")
            } icon: {
                Image(systemName: "text.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct AddExampleMenu: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new example", action: primaryAction)
                Button("Edit examples", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                AddExampleButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
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
