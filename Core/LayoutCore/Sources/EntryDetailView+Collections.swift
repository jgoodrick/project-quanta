
import SwiftUI

struct EntryDetailCollectionsMembershipSection: View {
    
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style
    
    var column: GridItem {
        GridItem(.adaptive(minimum: 100, maximum: .infinity), spacing: 0, alignment: .leading)
    }

    var body: some View {
        Section {
            
            TagLayout(alignment: .leading) {
                ForEach(store.collectionsMembership) { collection in
                    IndividualCollectionMembershipButton(collection: collection) {
                        store.send(.individualCollectionButtonTapped(collection))
                    } onEditButtonTapped: {
                        store.send(.individualCollectionEditButtonTapped(collection))
                    } onRemoveButtonTapped: {
                        store.send(.individualCollectionRemoveButtonTapped(collection))
                    } onEditModeRemoveButtonTapped: {
                        store.send(.individualCollectionRemoveButtonTapped(collection))
                    }
                }
            }

        } header: {
            SectionHeader(title: "Collections") {
                AddToCollectionMembershipMenu {
                    store.send(.addTranslationButtonTapped)
                } onEditButtonTapped: {
                    store.send(.editTranslationsButtonTapped)
                }
            }
            .foregroundStyle(style.primarySectionColors.translation)
        }
        .foregroundStyle(style.primarySectionColors.collections)
    }
}

struct EntryDetailAddFirstCollectionMembershipButton: View {
    
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        AddToCollectionButton {
            store.send(.addToCollectionButtonTapped)
        }
        .foregroundStyle(style.primarySectionColors.collections)
    }
}

struct AddToCollectionButton: View {
    
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add to collection")
            } icon: {
                Image(systemName: "rectangle.stack.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct AddToCollectionMembershipMenu: View {
    
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add to a collection", systemImage: "rectangle.stack.badge.plus", action: primaryAction)
                SuffixedEditButton("collection membership", additionalAction: onEditButtonTapped)
            },
            label: {
                AddToCollectionButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
    }
}

struct IndividualCollectionMembershipButton: View {
    
    let collection: EntryDetailStore.EntryCollection
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    let onRemoveButtonTapped: () -> Void
    let onEditModeRemoveButtonTapped: () -> Void
    
    @Environment(\.editMode) var editMode
    @Namespace var namespace

    var body: some View {
        Group {
            if editMode?.wrappedValue.isEditing == true {
                
                Button(action: { /* This is just for the button styling */ }) {
                    IndividualCollectionMembershipButtonContent(collection: collection)
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

            } else {
                Menu(
                    content: {
                        Button("Go to this collection", action: primaryAction)
                        Button("Remove from this collection", action: onRemoveButtonTapped)
                    },
                    label: {
                        IndividualCollectionMembershipButtonContent(collection: collection)
                            .matchedGeometryEffect(id: "2", in: namespace)
                    },
                    primaryAction: primaryAction
                )
            }
        }
        .buttonStyle(.roundedTwoTone(highlighted: false))
        .environment(\.roundedTwoToneButton.square, false)
        .environment(\.roundedTwoToneButton.dimension, .none)
    }
}

struct IndividualCollectionMembershipButtonContent: View {

    let collection: EntryDetailStore.EntryCollection
    
    var body: some View {
        Text(collection.title)
            .italic()
            .padding(6)
    }
}


#Preview("Empty") {
    EntryDetailCollectionsMembershipSection(store: .init())
}

#Preview("Populated") {
    EntryDetailCollectionsMembershipSection(store: .mock)
}
