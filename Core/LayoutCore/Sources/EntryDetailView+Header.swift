
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
                store.send(.pronunciationAddButtonTapped)
            } onEditButtonTapped: {
                store.send(.pronunciationEditButtonTapped)
            } onRemoveButtonTapped: {
                store.send(.pronunciationRemoveButtonTapped)
            }
            .foregroundStyle(style.primarySectionColors.header)

            Spacer()
            
            AdditionalContextButton(
                splashImage: SplashImageButton(image: store.image) {
                    store.send(.imageAddButtonTapped)
                } onEditButtonTapped: {
                    store.send(.imageEditButtonTapped)
                } onRemoveButtonTapped: {
                    store.send(.imageRemoveButtonTapped)
                },
                pronunciation: PronunciationButton(pronunciation: store.pronunciation) {
                    store.send(.pronunciationAddButtonTapped)
                } onEditButtonTapped: {
                    store.send(.pronunciationEditButtonTapped)
                } onRemoveButtonTapped: {
                    store.send(.pronunciationRemoveButtonTapped)
                }
            )
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

struct SplashImageButton: View {
    
    let image: EntryDetailStore.SplashImage?
    let onAddButtonTapped: () -> Void
    let onEditButtonTapped: () -> Void
    let onRemoveButtonTapped: () -> Void
    
    var body: some View {
        Group {
            if image != nil {
                Menu(
                    content: {
                        Button("Edit image", systemImage: "pencil", action: onEditButtonTapped)
                        Button("Remove image", systemImage: "trash", action: onRemoveButtonTapped)
                    },
                    label: {
                        Label {
                            Text("Image")
                        } icon: {
                            Image(systemName: "photo")
                        }
                    }
                )
            } else {
                Button("Add an image", systemImage: "photo.badge.plus", action: onAddButtonTapped)
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
        .environment(\.adaptiveTwoTone.lightMode.standard.background, .clear)
        .environment(\.adaptiveTwoTone.darkMode.standard.background, .clear)
    }
}

struct PronunciationButton: View {
    
    let pronunciation: EntryDetailStore.Pronunciation?
    let onAddButtonTapped: () -> Void
    let onEditButtonTapped: () -> Void
    let onRemoveButtonTapped: () -> Void
    
    var body: some View {
        Group {
            if pronunciation != nil {
                Menu(
                    content: {
                        Button("Edit pronunciation", systemImage: "pencil", action: onEditButtonTapped)
                        Button("Remove pronunciation", systemImage: "trash", action: onRemoveButtonTapped)
                    },
                    label: {
                        Label {
                            Text("Pronunciation")
                        } icon: {
                            Image(systemName: "waveform.path")
                        }
                    }
                )
            } else {
                Button("Add a pronunciation", systemImage: "waveform.path.badge.plus", action: onAddButtonTapped)
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
        .environment(\.adaptiveTwoTone.lightMode.standard.background, .clear)
        .environment(\.adaptiveTwoTone.darkMode.standard.background, .clear)
    }
}

struct AdditionalContextButton: View {
    
    let splashImage: SplashImageButton
    let pronunciation: PronunciationButton
    
    var body: some View {
        Menu(
            content: {
                splashImage
                pronunciation
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
