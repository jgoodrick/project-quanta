
import SwiftUI

struct EntryDetailHeader: View {
    @State var store: EntryDetailStore
    var body: some View {
        HStack {
            
            EntrySpellingField(spelling: store.spelling) {
                store.send(.newSpellingCommitted(value: $0))
            }
            
            PronunciationButton(pronunciation: store.pronunciation) {
                store.send(.pronunciationButtonTapped)
            } onLongPressMenuEditButtonTapped: {
                store.send(.pronunciationEditButtonTapped)
            }

            Spacer()
            
            AddToCollectionButton {
                store.send(.addToCollectionButtonTapped)
            } onLongPressMenuEditButtonTapped: {
                store.send(.editCollectionMembershipButtonTapped)
            }
            .foregroundStyle(.mint)
            
        }
    }
}

struct EntrySpellingField: View {
    
    let spelling: String
    let onChangeCommitted: (String) -> Void
    
    @State private var draft: String = ""
    @State private var isEditing: Bool = false
    
    private func beginEditing() {
        draft = spelling
        isEditing = true
    }
    
    private func reset() {
        isEditing = false
        draft = ""
    }
    
    var body: some View {
        Group {
            if isEditing {
                TextField("Spelling", text: $draft) {
                    defer { reset() }
                    let committed = draft
                    if committed != spelling {
                        onChangeCommitted(committed)
                    }
                }
            } else {
                Text(spelling)
                    .onLongPressGesture {
                        beginEditing()
                    }
            }
        }
        .font(.largeTitle.bold())
    }
}

struct PronunciationButton: View {
    
    let pronunciation: EntryDetailStore.Pronunciation?
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Edit pronunciation", systemImage: "pencil", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                if pronunciation?.audio != nil {
                    Image(systemName: "waveform.path")
                } else {
                    Image(systemName: "waveform.path.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
        .environment(\.adaptiveHighlightableTwoTone.lightMode.standard.background, .clear)
        .foregroundStyle(.blue)
    }
}

struct AddToCollectionButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add to a new collection", action: primaryAction)
                Button("Edit collection membership", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add to Collection")
                } icon: {
                    Image(systemName: "rectangle.stack.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}


#Preview("Empty") {
    EntryDetailHeader(store: .init())
}

#Preview("Populated") {
    EntryDetailHeader(store: .mock)
}
