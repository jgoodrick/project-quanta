
import SwiftUI

struct EntryDetailNotesSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

    var body: some View {
        Section {
            ForEach(store.notes) { note in
                NoteCell(note: note) {
                    store.send(.noteCellTapped(note))
                } onEditButtonTapped: {
                    store.send(.noteEditButtonTapped(note))
                }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    store.send(.noteSwipedAndDeleted(store.notes[$0]))
                }
            }
            .onMove { indices, newOffset in
                store.send(.notesMoved(fromOffsets: indices, toOffset: newOffset))
            }
        } header: {
            SectionHeader(title: "Notes") {
                AddNoteMenu {
                    store.send(.addNoteButtonTapped)
                } onEditButtonTapped: {
                    store.send(.editNotesButtonTapped)
                }
            }
            .foregroundStyle(style.primarySectionColors.notes)
        }
    }
}

struct AddFirstNotesButton: View {
        
    @State var store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        AddNoteButton {
            store.send(.addNoteButtonTapped)
        }
        .foregroundStyle(style.primarySectionColors.notes)
    }
}

struct AddNoteButton: View {

    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text("Note")
            } icon: {
                Image(systemName: "pencil.tip.crop.circle.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone(square: compact))
    }
}

struct AddNoteMenu: View {
    
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Add a new note", action: primaryAction)
                SuffixedEditButton("notes", additionalAction: onEditButtonTapped)
            },
            label: {
                AddNoteButton(compact: true, action: primaryAction)
            },
            primaryAction: primaryAction
        )
    }
}

struct NoteCell: View {
    
    let note: EntryDetailStore.IndexedNote
    let primaryAction: () -> Void
    let onEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Edit Note", action: onEditButtonTapped)
            },
            label: {
                HStack(alignment: .top) {
                    Text("\(note.index).")
                    Text(note.value)
                }
                .padding(.top, 8)
                .multilineTextAlignment(.leading)
            },
            primaryAction: primaryAction
        )
        .foregroundStyle(.primary)
    }
}


#Preview("Empty") {
    EntryDetailNotesSection(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailNotesSection(store: .mock)
}
