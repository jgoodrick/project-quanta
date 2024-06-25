
import SwiftUI

struct EntryDetailNotesSection: View {
    @State var store: EntryDetailStore
    var body: some View {
        Section {
            ForEach(store.notes) { note in
                NoteCell(note: note) {
                    store.send(.noteCellTapped(note))
                } onLongPressMenuEditButtonTapped: {
                    store.send(.noteEditButtonTapped(note))
                }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    let note = store.notes.remove(at: $0)
                    store.send(.noteSwipedAndDeleted(note))
                }
            }
        } header: {
            SectionHeader(title: "Notes") {
                AddNoteButton {
                    store.send(.addNoteButtonTapped)
                } onLongPressMenuEditButtonTapped: {
                    store.send(.editNotesButtonTapped)
                }
            }
            .foregroundStyle(.purple)
        }
    }
}

struct AddNoteButton: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Add a new note", action: primaryAction)
                Button("Edit notes", action: onLongPressMenuEditButtonTapped)
            },
            label: {
                Label {
                    Text("Add Note")
                } icon: {
                    Image(systemName: "pencil.tip.crop.circle.badge.plus")
                }
            },
            primaryAction: primaryAction
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct NoteCell: View {
    
    let note: EntryDetailStore.IndexedNote
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Edit Note", action: onLongPressMenuEditButtonTapped)
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
    EntryDetailNotesSection(store: .init())
}

#Preview("Populated") {
    EntryDetailNotesSection(store: .mock)
}
