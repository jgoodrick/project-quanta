
import SwiftUI

struct EntryDetailHeader: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style
    
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
            .foregroundStyle(style.primarySectionColors.header)

            Spacer()
            
            AdditionalContextButton {
                store.send(.addNewPhotoButtonTapped)
            } onAddPronunciationMenuButton: {
                store.send(.addNewPronunciationButtonTapped)
            } onAddToCollectionMenuButton: {
                store.send(.addToCollectionButtonTapped)
            } onEditCollectionMembershipMenuButton: {
                store.send(.editCollectionMembershipButtonTapped)
            }
            .foregroundStyle(style.primarySectionColors.header)
            
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
        .environment(\.adaptiveHighlightableTwoTone.darkMode.standard.background, .clear)
    }
}

struct AdditionalContextButton: View {
    
    let onAddPhotoMenuButton: () -> Void
    let onAddPronunciationMenuButton: () -> Void
    let onAddToCollectionMenuButton: () -> Void
    let onEditCollectionMembershipMenuButton: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a photo", systemImage: "photo.badge.plus", action: onAddPhotoMenuButton)
                Button("Add a pronunciation", systemImage: "waveform.path.badge.plus", action: onAddPronunciationMenuButton)
                Button("Add to a new collection", systemImage: "rectangle.stack.badge.plus", action: onAddToCollectionMenuButton)
                Button("Edit collection membership", systemImage: "rectangle.stack.badge.minus", action: onEditCollectionMembershipMenuButton)
            },
            label: {
                Label {
                    Text("Additional Context")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
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
