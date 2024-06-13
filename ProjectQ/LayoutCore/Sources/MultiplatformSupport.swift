
import SwiftUI

public struct HideListRowSeparators: ViewModifier {
    public init() {}
    public func body(content: Content) -> some View {
        content
            #if !os(tvOS) && !os(watchOS)
            .listRowSeparator(.hidden)
            #endif
    }
}

public struct DeleteSwipeAction_tvOSexcluded: ViewModifier {
    
    public init(onDeletionConfirmed: @escaping () -> Void) {
        self.onDeletionConfirmed = onDeletionConfirmed
    }
    
    let onDeletionConfirmed: () -> Void
    
    public func body(content: Content) -> some View {
        content
            #if !os(tvOS)
            .swipeActions {
                Button(
                    role: .destructive,
                    action: onDeletionConfirmed,
                    label: {
                        Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                    }
                )
            }
            #endif
    }
}

public struct EditSwipeAction_tvOSexcluded: ViewModifier {
    
    public init(onEditConfirmed: @escaping () -> Void) {
        self.onEditConfirmed = onEditConfirmed
    }
    
    let onEditConfirmed: () -> Void
    
    public func body(content: Content) -> some View {
        content
            #if !os(tvOS)
            .swipeActions {
                Button(
                    action: onEditConfirmed,
                    label: {
                        Label(title: { Text("Edit") }, icon: { Image(systemName: "pencil") })
                    }
                )
                .tint(.yellow)
            }
            #endif
    }
}
