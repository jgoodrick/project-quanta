
import SwiftUI

struct EntryDetailHeader: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style
    @Environment(\.editMode) var editMode
    
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
    
    @State var store: EntryDetailStore
    
    @FocusState private var focused: Bool
    
    private func beginEditing() {
        store.draftSpelling = store.spelling
        focused = true
    }
    
    private func reset() {
        focused = false
        store.draftSpelling = ""
    }
    
    var body: some View {
        TextField("Spelling", text: $store.draftSpelling) {
            defer { reset() }
            let committed = store.draftSpelling
            if committed != store.spelling {
                store.send(.newSpellingCommitted(value: committed))
            }
        }
        .focused($focused)
        .font(.largeTitle.bold())
        .synchronize(focusState: $focused, with: $store.spellingFocused)
    }
}

#Preview("Empty") {
    EntryDetailHeader(store: .init())
}

#Preview("Populated") {
    EntryDetailHeader(store: .mock)
}
