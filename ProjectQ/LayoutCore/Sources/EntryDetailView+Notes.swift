
import SwiftUI

struct EntryDetailNotesSection: View {
    
    @Bindable var store: EntryDetailStore
    
    @Environment(\.entryDetail) var style
    @Environment(\.editMode) private var editMode

    var body: some View {
        Section {
            ForEach($store.notes) { note in
                NoteCell(note: note) {
                    store.send(.noteCellTapped(note.wrappedValue))
                } onTextEditorTask: {
                    store.send(.noteTextEditorTask(note.wrappedValue))
                } onEditButtonTapped: {
                    store.send(.noteEditButtonTapped(note.wrappedValue))
                } onRemoveButtonTapped: {
                    store.send(.noteRemoveButtonTapped(note.wrappedValue))
                } onFocusDropped: {
                    store.send(.noteFocusDropped(note.wrappedValue))
                } onTextCommitted: {
                    store.send(.noteTextCommitted(note.wrappedValue))
                }
            }
            .onDelete { indexSet in
                store.send(.noteSwipedAndDeleted(indexSet: indexSet))
            }
            .onMove { indices, newOffset in
                store.send(.notesMoved(fromOffsets: indices, toOffset: newOffset))
            }
            
            if editMode.isEditing {
                
                ForEach($store.noteDrafts) { noteDraft in
                    NoteEditor(original: "", text: noteDraft.draft) {
                        store.send(.noteDraftFocusDropped(noteDraft.wrappedValue))
                    } onTextCommitted: {
                        store.send(.noteDraftTextCommitted(noteDraft.wrappedValue))
                    }
                }
                .onDelete { indexSet in
                    store.send(.noteDraftSwipedAndDeleted(indexSet: indexSet))
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        store.send(.addNoteButtonTapped)
                    } label: {
                        Text("+")
                    }
                    .buttonStyle(LanguageTagButtonStyle())

                }
                .padding(.top, 8)
                .padding(.bottom)
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
        
    let store: EntryDetailStore
        
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
    
    @Binding var note: EntryDetailStore.Note
    var onUnfocusedCellTapped: () -> Void
    var onTextEditorTask: () -> Void
    var onEditButtonTapped: () -> Void
    var onRemoveButtonTapped: () -> Void
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void

    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        Group {
            if editMode.isNotEditing {
                Menu(
                    content: {
                        Button("Edit Note", action: onEditButtonTapped)
                    },
                    label: {
                        HStack(alignment: .top) {
                            Text("•")
        //                    Text("\(note.index).")
                            Text(note.value)
                        }
                        .padding(.top, 8)
                        .multilineTextAlignment(.leading)
                    },
                    primaryAction: onUnfocusedCellTapped
                )
                .foregroundStyle(.primary)
            } else {
                NoteEditor(
                    original: note.value,
                    text: $note.draft,
                    onFocusDropped: onFocusDropped,
                    onTextCommitted: onTextCommitted
                )
                .task {
                    onTextEditorTask()
                }
            }
        }
    }
}


struct NoteEditor: View {
    
    let original: String
    @Binding var text: String
    var onFocusDropped: () -> Void
    var onTextCommitted: () -> Void
    
    @FocusState private var focused: Bool
    @Environment(\.editMode) private var editMode

    var body: some View {
        HStack(alignment: .top) {

            TextEditor(text: $text)
                .padding(.horizontal, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.0).foregroundStyle(.secondary)
                }
                .textInputAutocapitalization(.sentences)
                .disableAutocorrection(false)
                .frame(minHeight: 80)

            if original != text, !text.isEmpty {
                VStack {
                    
                    Spacer(minLength: 0)
                    
                    Button(action: onTextCommitted) {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.green)
                    .font(.title2)
                    
                    Spacer(minLength: 0)
                    
                }
            }

        }
        .padding(.top, editMode.isNotEditing ? 0 : 8)
        .foregroundStyle(.primary)
    }
}

#Preview("Empty") {
    EntryDetailNotesSection(store: .mockEmpty)
}

#Preview("Populated") {
    EntryDetailNotesSection(store: .mock)
}
