
import SwiftUI

struct EntryDetailRelatedEntriesSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
        Section {
            TagLayout(alignment: .leading) {
                ForEach(store.relatedEntries) { entry in
                    IndividualRelatedEntryButton(relatedEntry: entry) {
                        store.send(.individualRelatedEntryCellTapped(entry))
                    } onRemoveButtonTapped: {
                        store.send(.individualRelatedEntryRemoveButtonTapped(entry))
                    } onEditModeRemoveButtonTapped: {
                        store.send(.individualRelatedEntryRemoveButtonTapped(entry))
                    }
                }
            }
        } header: {
            SectionHeader(title: "See Also") {
                AddRelatedEntryMenu {
                    store.send(.addRelatedEntryButtonTapped)
                } onEditButtonTapped: {
                    store.send(.editRelatedEntriesButtonTapped)
                }
            }
        }
        .foregroundStyle(style.primarySectionColors.relatedWords)
    }
}

struct EntryDetailAddFirstRelatedEntriesButton: View {
        
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        AddRelatedEntryButton {
            store.send(.addRelatedEntryButtonTapped)
        }
        .foregroundStyle(style.primarySectionColors.relatedWords)
    }
}

struct AddRelatedEntryButton: View {
    
    var compact: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Related")
            } icon: {
                Image(systemName: "link.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct AddRelatedEntryMenu: View {
    
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new related word", action: primaryAction)
                SuffixedEditButton("related", additionalAction: onEditButtonTapped)
            },
            label: {
                AddRelatedEntryButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
    }
}

struct IndividualRelatedEntryButton: View {
    
    let relatedEntry: EntryDetailStore.RelatedEntry
    let primaryAction: () -> Void
    let onRemoveButtonTapped: () -> Void
    let onEditModeRemoveButtonTapped: () -> Void

    @Environment(\.editMode) var editMode
    @Namespace var namespace

    var body: some View {
        Group {
            if editMode?.wrappedValue.isEditing == true {
                Button(action: { }) {
                    IndividualRelatedEntryButtonContent(relatedEntry: relatedEntry)
                        .matchedGeometryEffect(id: "2", in: namespace)
                }.disabled(true)
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
                        Button("Go to this word", action: primaryAction)
                        Button("Disconnect these words", action: onRemoveButtonTapped)
                    },
                    label: {
                        IndividualRelatedEntryButtonContent(relatedEntry: relatedEntry)
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

struct IndividualRelatedEntryButtonContent: View {

    let relatedEntry: EntryDetailStore.RelatedEntry
    
    var body: some View {
        Text(relatedEntry.spelling)
            .italic()
            .padding(6)
    }
}

#Preview("Empty") {
    EntryDetailRelatedEntriesSection(store: .init())
}

#Preview("Populated") {
    EntryDetailRelatedEntriesSection(store: .mock)
}
