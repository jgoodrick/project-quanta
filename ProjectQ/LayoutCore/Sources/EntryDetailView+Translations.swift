
import SwiftUI

struct EntryDetailTranslationsSection: View {
    @State var store: EntryDetailStore
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
            SectionHeader(title: "Translations") {
                AddTranslationButton {
                    store.send(.addTranslationButtonTapped)
                } onLongPressMenuEditButtonTapped: {
                    store.send(.editTranslationsButtonTapped)
                }
            }
            .foregroundStyle(.purple)
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


#Preview("Empty") {
    EntryDetailTranslationsSection(store: .init())
}

#Preview("Populated") {
    EntryDetailTranslationsSection(store: .mock)
}
