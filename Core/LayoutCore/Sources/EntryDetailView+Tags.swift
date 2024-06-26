
import SwiftUI

struct EntryDetailTagsSection: View {
    
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        Group {
            if store.translations.isEmpty {
                Section {
                    
                } header: {
                    AddTagButton {
                        store.send(.addTagButtonTapped)
                    }
                }
            } else {
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
                        
                        AddTagMenu {
                            store.send(.addTagButtonTapped)
                        } onLongPressMenuEditButtonTapped: {
                            store.send(.editTagsButtonTapped)
                        }
                    }
                }
            }
        }
        .foregroundStyle(style.primarySectionColors.tags)
    }
}

struct AddTagButton: View {
    
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Tag")
            } icon: {
                Image(systemName: "tag")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct AddTagMenu: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new tag", systemImage: "plus", action: primaryAction)
                Button("Edit tags", systemImage: "ellipses", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                AddTagButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
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
