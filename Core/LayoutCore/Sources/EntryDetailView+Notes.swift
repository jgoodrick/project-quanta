
import SwiftUI

struct EntryDetailNotesSection: View {
    
    @State var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style

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
            Group {
                if store.examples.isEmpty {
                    AddNoteButton {
                        store.send(.addNoteButtonTapped)
                    }
                } else {
                    SectionHeader(title: "Notes") {
                        AddNoteMenu {
                            store.send(.addNoteButtonTapped)
                        } onLongPressMenuEditButtonTapped: {
                            store.send(.editNotesButtonTapped)
                        }
                    }
                }
            }
            .foregroundStyle(style.primarySectionColors.notes)
        }
    }
}

struct AddNoteButton: View {

    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Note")
            } icon: {
                Image(systemName: "pencil.tip.crop.circle.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct AddNoteMenu: View {
    
    let primaryAction: () -> Void
    let onLongPressMenuEditButtonTapped: () -> Void

    var body: some View {
        Menu(
            content: {
                Button("Add a new note", action: primaryAction)
                Button("Edit notes", action: onLongPressMenuEditButtonTapped)
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
