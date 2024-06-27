
import SwiftUI

struct EntryDetailTagsSection: View {
    
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 0) {
                TagLayout(alignment: .leading) {
                    ForEach(store.tags) { tag in
                        IndividualTagButton(tag: tag) {
                            store.send(.individualTagButtonTapped(tag))
                        } onEditButtonTapped: {
                            store.send(.individualTagEditButtonTapped(tag))
                        } onRemoveButtonTapped: {
                            store.send(.individualTagRemoveButtonTapped(tag))
                        } onEditModeRemoveButtonTapped: {
                            store.send(.individualTagRemoveButtonTapped(tag))
                        }
                    }
                }
                
                Spacer(minLength: 8)
                
                if editMode.isNotEditing {
                    AddTagMenu {
                        store.send(.addTagButtonTapped)
                    } onEditButtonTapped: {
                        store.send(.editTagsButtonTapped)
                    }
                }
            }
        }
        .foregroundStyle(style.primarySectionColors.tags)
    }
}

struct AddFirstTagButton: View {
    
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        AddTagButton {
            store.send(.addTagButtonTapped)
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
                Text("Tag")
            } icon: {
                Image(systemName: "tag")
            }
        }
        .buttonStyle(.roundedTwoTone(square: compact))
    }
}

struct AddTagMenu: View {
    
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new tag", systemImage: "plus", action: primaryAction)
                SuffixedEditButton("tags", additionalAction: onEditButtonTapped)
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
    let onEditButtonTapped: () -> Void
    let onRemoveButtonTapped: () -> Void
    let onEditModeRemoveButtonTapped: () -> Void
    
    @Environment(\.editMode) var editMode
    @Namespace var namespace

    var body: some View {
        Group {
            if editMode.isNotEditing {
                
                Menu(
                    content: {
                        Button("Go to this tag", action: primaryAction)
                        Button("Edit this tag", action: onEditButtonTapped)
                        Button("Remove this tag", action: onRemoveButtonTapped)
                    },
                    label: {
                        IndividualTagButtonContent(tag: tag)
                            .matchedGeometryEffect(id: "2", in: namespace)
                    },
                    primaryAction: primaryAction
                )

            } else {

                Button(action: { /* This is just for the button styling */ }) {
                    IndividualTagButtonContent(tag: tag)
                        .matchedGeometryEffect(id: "2", in: namespace)
                }
                .disabled(true)
                .padding(.leading)
                .overlay(alignment: .topLeading) {
                    Button(action: onEditModeRemoveButtonTapped) {
                        Image(systemName: "x.circle.fill")
                    }
                    .buttonStyle(.plain)
                }
                
            }
        }
        .buttonStyle(.roundedTwoTone(highlighted: false, square: false))
    }
}

struct IndividualTagButtonContent: View {

    let tag: EntryDetailStore.Tag
    
    var body: some View {
        Text(tag.title)
            .italic()
            .padding(6)
    }
}


#Preview("Empty") {
    EntryDetailTagsSection(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailTagsSection(store: .mock)
}
