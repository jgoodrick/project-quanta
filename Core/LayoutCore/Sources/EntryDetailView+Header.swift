
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
        
    var body: some View {
        TextField(
            "Spelling",
            text: $store.draftSpelling
        )
        .onSubmit(of: .text) {
            store.send(.draftSpellingCommitted)
        }
        .focused($focused)
        .font(.largeTitle.bold())
        .synchronize(focusState: $focused, when: $store.focused, equals: .spelling)
    }
}

#Preview("Empty") {
    EntryDetailHeader(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailHeader(store: .mock)
}
