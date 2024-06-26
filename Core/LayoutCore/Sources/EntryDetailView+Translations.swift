
import SwiftUI

struct EntryDetailTranslationsSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
        Section {
            ForEach(store.translations) { translation in
                TranslationCell(translation: translation) {
                    store.send(.translationTapped(translation))
                } onEditButtonTapped: {
                    store.send(.translationEditButtonTapped(translation))
                } onGoToDetailButtonTapped: {
                    store.send(.translationGoToDetailButtonTapped(translation))
                } onRemoveButtonTapped: {
                    store.send(.translationRemoveButtonTapped(translation))
                }
            }
            .onMove { indices, newOffset in
                store.send(.translationsMoved(fromOffsets: indices, toOffset: newOffset))
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    let translation = store.translations.remove(at: $0)
                    store.send(.translationSwipedAndDeleted(translation))
                }
            }
        } header: {
            SectionHeader(title: "Translations") {
                AddTranslationMenu {
                    store.send(.addTranslationButtonTapped)
                } onEditButtonTapped: {
                    store.send(.editTranslationsButtonTapped)
                }
            }
            .foregroundStyle(style.primarySectionColors.translation)
        }
    }
}

struct AddFirstTranslationsButton: View {
        
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        AddTranslationButton {
            store.send(.addTranslationButtonTapped)
        }
        .foregroundStyle(style.primarySectionColors.translation)
    }
}

struct AddTranslationButton: View {
    
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text("Translate")
            } icon: {
                Image(systemName: "character.book.closed.fill")
            }
        }
        .buttonStyle(.roundedTwoTone(square: compact))
    }
}

struct AddTranslationMenu: View {
    
    let primaryAction: () -> Void
    var onEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new translation", action: primaryAction)
                SuffixedEditButton("translations", additionalAction: onEditButtonTapped)
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
    var onEditButtonTapped: () -> Void
    var onGoToDetailButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    
    @Environment(\.editMode) var editMode
    
    var body: some View {
        HStack {
            
            LanguageTagView(language: translation.language)
            
            Menu(
                content: {
                    Button("Edit this translation", action: onEditButtonTapped)
                    Button("Go to translation detail", action: onGoToDetailButtonTapped)
                    Button("Remove this translation", action: onRemoveButtonTapped)
                },
                label: {
                    TranslationCellContent(translation: translation)
                },
                primaryAction: primaryAction
            )
        }
        .foregroundStyle(.primary)
    }
}

struct TranslationCellContent: View {
    let translation: EntryDetailStore.Translation
    var body: some View {
        Text(translation.value)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview("Empty") {
    EntryDetailTranslationsSection(store: .init())
}

#Preview("Populated") {
    EntryDetailTranslationsSection(store: .mock)
}

