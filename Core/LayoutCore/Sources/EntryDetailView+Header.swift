
import SwiftUI

struct EntryDetailHeader: View {
    
    let store: EntryDetailStore
    
    @Environment(\.entryDetail) var style
    @Environment(\.editMode) private var editMode
    
    var body: some View {
        HStack {
            
            EntrySpellingField(store: store)
            
            if store.pronunciation != nil {
                PronunciationButton(
                    compact: true,
                    store: store
                )
            }

            Spacer()
            
            if editMode.isNotEditing, !store.unpopulatedAdditionalContext.isEmpty {
                Menu(
                    content: {
                        EntryDetailUnpopulatedAdditionalContext(store: store)
                    },
                    label: {
                        Label {
                            Text("Additional Context")
                        } icon: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                )
                .buttonStyle(.roundedTwoTone(square: true))
                .foregroundStyle(style.primarySectionColors.additionalContext)
            }
        }
    }
}

struct EntrySpellingField: View {
    
    @Bindable var store: EntryDetailStore
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        SpellingCell(focusState: $store.focused, entry: $store.entry) {
            store.send(.spellingTapped)
        } onEditButtonTapped: {
            store.send(.spellingEditButtonTapped)
        } onRemoveButtonTapped: {
            store.send(.spellingRemoveButtonTapped)
        } onFocusDropped: {
            store.send(.spellingFocusDropped)
        } onTextCommitted: {
            store.send(.spellingTextCommitted)
        }
    }
}

struct SpellingCell: View {
    
    @Binding var focusState: EntryDetailStore.State.FocusedField?
    @Binding var entry: EntryDetailStore.Entry
    var onUnfocusedCellTapped: () -> Void
    var onEditButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode
    @Environment(\.languageNameFormatter) private var formatter

    var body: some View {
        HStack {
            
            LanguageTagView(language: entry.language)
            
            Group {
                if editMode.isNotEditing {
                    Menu(
                        content: {
                            Button("Edit this entry", action: onEditButtonTapped)
                            Button("Remove this entry entirely", action: onRemoveButtonTapped)
                        },
                        label: {
                            Text(entry.spelling)
                        },
                        primaryAction: {
                            editMode?.wrappedValue = .active
                            focused = true
                            onUnfocusedCellTapped()
                        }
                    )
                } else {
                    TextField("Spelling", text: $entry.draft)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .task {
                            entry.draft = entry.spelling
                        }
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .font(.largeTitle.bold())

        }
        .foregroundStyle(.primary)
        .focused($focused)
        .synchronize(focusState: $focused, when: $focusState, equals: .spelling, onFocusDrop: onFocusDropped)
        .onSubmit(onTextCommitted)
    }
}


#Preview("Empty") {
    EntryDetailHeader(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailHeader(store: .mock)
}
