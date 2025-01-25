
import SwiftUI

struct SplashImageButton: View {
    
    var compact: Bool = false
    let store: EntryDetailStore

    @Environment(\.entryDetail) var style

    var body: some View {
        SplashImageButtonOrMenu(compact: compact, image: store.image) {
            store.send(.imageAddButtonTapped)
        } onEditButtonTapped: {
            store.send(.imageEditButtonTapped)
        } onRemoveButtonTapped: {
            store.send(.imageRemoveButtonTapped)
        }
        .foregroundStyle(style.primarySectionColors.image)
    }
}

struct SplashImageButtonOrMenu: View {
    
    var compact: Bool = false
    let image: EntryDetailStore.SplashImage?
    let onAddButtonTapped: () -> Void
    let onEditButtonTapped: () -> Void
    let onRemoveButtonTapped: () -> Void
    
    @Environment(\.editMode) private var editMode

    var body: some View {
        Group {
            if image != nil {
                Menu(
                    content: {
                        EditSplashImageButton(action: onEditButtonTapped)
                        RemoveSplashImageButton(action: onRemoveButtonTapped)
                    },
                    label: {
                        SplashImageMenuLabel()
                    }
                )
            } else {
                AddSplashImageButton(action: onAddButtonTapped)
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, compact)
    }
}

struct SplashImageMenuLabel: View {
    var body: some View {
        Label {
            Text("Image")
        } icon: {
            Image(systemName: "photo")
        }
    }
}

struct AddSplashImageButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Add an image", systemImage: "photo.badge.plus", action: action)
    }
}

struct EditSplashImageButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Edit image", systemImage: "pencil", action: action)
    }
}

struct RemoveSplashImageButton: View {
    
    let action: () -> Void
    
    var body: some View {
        Button("Remove image", systemImage: "trash", action: action)
    }
}

