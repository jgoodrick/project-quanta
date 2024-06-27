
import SwiftUI

struct EntryDetailTranslationsSection: View {
    
    @Bindable var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
        Section {
            ForEach($store.translations) { $translation in
                TranslationCell(focusState: $store.focused, translation: $translation) {
                    store.send(.translationTapped(translation))
                } onEditButtonTapped: {
                    store.send(.translationEditButtonTapped(translation))
                } onGoToDetailButtonTapped: {
                    store.send(.translationGoToDetailButtonTapped(translation))
                } onRemoveButtonTapped: {
                    store.send(.translationRemoveButtonTapped(translation))
                } onFocusDropped: {
                    store.send(.translationFocusDropped(translation))
                } onTextCommitted: {
                    store.send(.translationTextCommitted(translation))
                }
            }
            .onMove { indices, newOffset in
                store.send(.translationsMoved(fromOffsets: indices, toOffset: newOffset))
            }
            .onDelete { indexSet in
                store.send(.translationSwipedAndDeleted(indexSet: indexSet))
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
        
    let store: EntryDetailStore
        
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
    
    @Binding var focusState: EntryDetailStore.State.FocusedField?
    @Binding var translation: EntryDetailStore.Translation
    var onUnfocusedCellTapped: () -> Void
    var onEditButtonTapped: () -> Void
    var onGoToDetailButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode
    @Environment(\.languageNameFormatter) private var formatter

    var placeholder: String { "\(formatter.displayName(for: translation.language, style: .full)) translation" }
    
    var body: some View {
        HStack {
            
            LanguageTagView(language: translation.language)
            
            Group {
                if editMode.isNotEditing {
                    Menu(
                        content: {
                            Button("Edit this translation", action: onEditButtonTapped)
                            Button("Go to translation detail", action: onGoToDetailButtonTapped)
                            Button("Remove this translation", action: onRemoveButtonTapped)
                        },
                        label: {
                            Text(translation.value)
                        },
                        primaryAction: {
                            editMode?.wrappedValue = .active
                            focused = true
                            onUnfocusedCellTapped()
                        }
                    )
                } else {
                    TextField(placeholder, text: $translation.draft)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .task {
                            translation.draft = translation.value
                        }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .font(.title)
            
        }
        .foregroundStyle(.primary)
        .focused($focused)
        .synchronize(focusState: $focused, when: $focusState, equals: .translation(translation.id), onFocusDrop: onFocusDropped)
        .onSubmit(onTextCommitted)
    }
}


#Preview("Empty") {
    EntryDetailTranslationsSection(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailTranslationsSection(store: .mock)
}

