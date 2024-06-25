
import SwiftUI

struct EntryDetailRelatedEntriesSection: View {
    @State var store: EntryDetailStore
    var body: some View {
        Section {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(store.relatedEntries) { entry in
                        IndividualRelatedEntryButton(relatedWord: entry) {
                            store.send(.individualRelatedEntryCellTapped(entry))
                        } onLongPressMenuRemoveButtonTapped: {
                            store.send(.individualRelatedEntryRemoveButtonTapped(entry))
                        }
                    }
                }
            }
        } header: {
            SectionHeader(title: "See Also") {
                AddRelatedEntryButton {
                    store.send(.addRelatedEntryButtonTapped)
                } onLongPressMenuEditButtonTapped: {
                    store.send(.editRelatedEntriesButtonTapped)
                }
            }
        }
        .foregroundStyle(.indigo)
    }
}

struct AddRelatedEntryButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new related word", action: primaryAction)
                Button("Edit related words", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Related Word")
                } icon: {
                    Image(systemName: "link.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct IndividualRelatedEntryButton: View {
    
    let relatedWord: EntryDetailStore.RelatedEntry
    let primaryAction: () -> Void
    let onLongPressMenuRemoveButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Go to this word", action: primaryAction)
                Button("Disconnect these words", action: onLongPressMenuRemoveButtonTapped)
            },
            label: {
                Text(relatedWord.spelling)
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
    EntryDetailRelatedEntriesSection(store: .init())
}

#Preview("Populated") {
    EntryDetailRelatedEntriesSection(store: .mock)
}
