
import SwiftUI

struct PronunciationButton: View {
    
    var compact: Bool = false
    let store: EntryDetailStore
        
    @Environment(\.entryDetail) var style

    var body: some View {
        PronunciationButtonOrMenu(compact: compact, pronunciation: store.pronunciation) {
            store.send(.pronunciationPlayButtonTapped)
        } onAddButtonTapped: {
            store.send(.pronunciationAddButtonTapped)
        } onEditButtonTapped: {
            store.send(.pronunciationEditButtonTapped)
        } onRemoveButtonTapped: {
            store.send(.pronunciationRemoveButtonTapped)
        }
        .foregroundStyle(style.primarySectionColors.pronunciation)
    }
}

struct PronunciationButtonOrMenu: View {
    
    var compact: Bool = false
    let pronunciation: EntryDetailStore.Pronunciation?
    let onPlayButtonTapped: () -> Void
    let onAddButtonTapped: () -> Void
    let onEditButtonTapped: () -> Void
    let onRemoveButtonTapped: () -> Void
    
    @Environment(\.editMode) private var editMode
    
    private var background: Color? {
        compact ? .clear : .none
    }
    
    var body: some View {
        Group {
            if pronunciation != nil {
                if editMode.isNotEditing {
                    Menu(
                        content: {
                            EditPronunciationButton(action: onEditButtonTapped)
                            RemovePronunciationButton(action: onRemoveButtonTapped)
                        },
                        label: {
                            PronunciationMenuLabel()
                        },
                        primaryAction: onPlayButtonTapped
                    )
                } else {
                    Menu(
                        content: {
                            EditPronunciationButton(action: onEditButtonTapped)
                            RemovePronunciationButton(action: onRemoveButtonTapped)
                        },
                        label: {
                            PronunciationMenuLabel()
                        }
                    )
                }
            } else {
                AddPronunciationButton(action: onAddButtonTapped)
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
        .modifier(OverrideIf(compact, \.adaptiveTwoTone.lightMode.standard.background, .clear))
        .modifier(OverrideIf(compact, \.adaptiveTwoTone.darkMode.standard.background, .clear))
    }
}

struct PronunciationMenuLabel: View {
    var body: some View {
        Label {
            Text("Pronunciation")
        } icon: {
            Image(systemName: "waveform.path")
        }
    }
}

struct AddPronunciationButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Pronunce", systemImage: "waveform.path.badge.plus", action: action)
    }
}

struct EditPronunciationButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Edit pronunciation", systemImage: "pencil", action: action)
    }
}

struct RemovePronunciationButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Remove pronunciation", systemImage: "trash", action: action)
    }
}

