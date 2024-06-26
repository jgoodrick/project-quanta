
import SwiftUI

struct EntryDetailRelatedEntriesSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

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
            Group {
                if store.relatedEntries.isEmpty {
                    AddRelatedEntryButton {
                        store.send(.addRelatedEntryButtonTapped)
                    }
                } else {
                    SectionHeader(title: "See Also") {
                        AddRelatedEntryMenu {
                            store.send(.addRelatedEntryButtonTapped)
                        } onLongPressMenuEditButtonTapped: {
                            store.send(.editRelatedEntriesButtonTapped)
                        }
                    }
                }
            }
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
                Text("Add Related Word")
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
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new related word", action: primaryAction)
                Button("Edit related words", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                AddRelatedEntryButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
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

#Preview("Empty-Contextualized") {
    EntryDetailView(store: .init())
}

#Preview("Populated-Contextualized") {
    EntryDetailView(store: .mock)
}
