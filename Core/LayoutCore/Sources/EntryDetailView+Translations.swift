
import SwiftUI

struct EntryDetailTranslationsSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
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
            Group {
                if store.translations.isEmpty {
                    AddTranslationButton {
                        store.send(.addTranslationButtonTapped)
                    }
                } else {
                    SectionHeader(title: "Translations") {
                        AddTranslationMenu {
                            store.send(.addTranslationButtonTapped)
                        } onLongPressMenuEditButtonTapped: {
                            store.send(.editTranslationsButtonTapped)
                        }
                    }
                }
            }
            .foregroundStyle(style.primarySectionColors.translation)
        }
    }
}

struct AddTranslationButton: View {
    
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Translation")
            } icon: {
                Image(systemName: "character.book.closed.fill")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct AddTranslationMenu: View {
    
    let primaryAction: () -> Void
    var onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new translation", action: primaryAction)
                Button("Edit translations", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                AddTranslationButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
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


#Preview("Empty") {
    EntryDetailTranslationsSection(store: .init())
}

#Preview("Populated") {
    EntryDetailTranslationsSection(store: .mock)
}

#Preview("Empty-Contextualized") {
    EntryDetailView(store: .init())
}

#Preview("Populated-Contextualized") {
    EntryDetailView(store: .mock)
}
