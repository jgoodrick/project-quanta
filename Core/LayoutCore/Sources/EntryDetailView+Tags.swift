
import SwiftUI

struct EntryDetailTagsSection: View {
    @State var store: EntryDetailStore
    var body: some View {
        Section {
            HStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(store.tags) { tag in
                            IndividualTagButton(tag: tag) {
                                store.send(.individualTagButtonTapped(tag))
                            } onLongPressMenuEditButtonTapped: {
                                store.send(.individualTagEditButtonTapped(tag))
                            } onLongPressMenuRemoveButtonTapped: {
                                store.send(.individualTagRemoveButtonTapped(tag))
                            }
                        }
                    }
                }
                .scrollClipDisabled()
                
                AddTagButton {
                    store.send(.addTagButtonTapped)
                } onLongPressMenuEditButtonTapped: {
                    store.send(.editTagsButtonTapped)
                }
            }
            .foregroundStyle(.cyan)
        }
    }
}

struct AddTagButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new tag", action: primaryAction)
                Button("Edit tags", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Tag")
                } icon: {
                    Image(systemName: "tag")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct IndividualTagButton: View {
    
    let tag: EntryDetailStore.Tag
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    let onLongPressMenuRemoveButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Go to this tag", action: primaryAction)
                Button("Edit this tag", action: onLongPressMenuEditButtonTapped)
                Button("Remove this tag", action: onLongPressMenuRemoveButtonTapped)
            },
            label: {
                Text(tag.title)
                    .italic()
                    .padding(6)
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone(highlighted: false))
        .environment(\.roundedTwoToneButton.square, false)
        .environment(\.roundedTwoToneButton.dimension, .none)
    }
}


#Preview("Empty") {
    EntryDetailTagsSection(store: .init())
}

#Preview("Populated") {
    EntryDetailTagsSection(store: .mock)
}
