
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
    
    var body: some View {
        HStack(alignment: .bottom) {
            
            Text(title)
                .font(.title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            icon()
            
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
        if editMode?.wrappedValue.isEditing == true {
            "Done editing"
        } else {
            "Edit \(suffix)"
        }
    }
    
    func toggleEditMode() {
        if editMode?.wrappedValue.isEditing == true {
            editMode?.wrappedValue = .inactive
        } else {
            editMode?.wrappedValue = .active
        }
    }
    
    var body: some View {
        Button(title, systemImage: systemImage) {
            toggleEditMode()
            additionalAction()
        }
    }
}
