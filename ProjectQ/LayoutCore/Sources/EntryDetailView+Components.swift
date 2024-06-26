
import SwiftUI

struct PlainList<Content: View>: View {
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        List {
            content()
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }
}

struct SectionHeader<Icon: View>: View {
    
    let title: String
    let icon: () -> Icon
    
    @Environment(\.editMode) var editMode

    var body: some View {
        HStack(alignment: .bottom) {
            
            Text(title)
                .font(.title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if editMode.isNotEditing {
                
                icon()
                
            }
        }
    }
}

struct SuffixedEditButton: View {
    init(_ suffix: LocalizedStringResource, systemImage: String = "pencil", additionalAction: @escaping () -> Void = { }) {
        self.suffix = suffix
        self.systemImage = systemImage
        self.additionalAction = additionalAction
    }
    
    let suffix: LocalizedStringResource
    var systemImage: String
    var additionalAction: () -> Void
    
    @Environment(\.editMode) private var editMode
    
    var title: LocalizedStringKey {
        if editMode.isNotEditing {
            "Edit \(suffix)"
        } else {
            "Done editing"
        }
    }
    
    func toggleEditMode() {
        if editMode.isNotEditing {
            editMode?.wrappedValue = .active
        } else {
            editMode?.wrappedValue = .inactive
        }
    }
    
    var body: some View {
        Button(title, systemImage: systemImage) {
            toggleEditMode()
            additionalAction()
        }
    }
}

extension Optional where Wrapped == Binding<EditMode> {
    var isNotEditing: Bool {
        self?.wrappedValue.isEditing != true
    }
}
