
import SwiftUI

public protocol TextEditableItem: Identifiable {
    var value: String { get }
}

public struct TextEditableItemsSection<Item: TextEditableItem>: View {
    
    public init(
        title: String,
        items: [Item],
        onSelected: ((Item) -> Void)? = nil,
        onDeleted: @escaping (Item) -> Void,
        onMoved: @escaping (IndexSet, Int) -> Void,
        onMenuShortPressed: @escaping () -> Void
    ) {
        self.title = title
        self.items = items
        self.onSelected = onSelected
        self.onDeleted = onDeleted
        self.onMoved = onMoved
        self.onMenuShortPressed = onMenuShortPressed
    }
    
    let title: String
    let items: [Item]
    let onSelected: ((Item) -> Void)?
    let onDeleted: (Item) -> Void
    let onMoved: (_ fromOffsets: IndexSet, _ toOffset: Int) -> Void
    let onMenuShortPressed: () -> Void
        
    public var body: some View {
        Section {
            ForEach(items) { item in
                HStack {
                    if let onSelected {
                        Button(action: { onSelected(item) }) {
                            Text(item.value)
                        }
                    } else {
                        Text(item.value)
                    }
                    Spacer()
                }
                #if !os(tvOS)
                .swipeActions {
                    Button(
                        role: .destructive,
                        action: {
                            onDeleted(item)
                        },
                        label: {
                            Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                        }
                    )
                }
                #endif
            }
            .onMove { from, to in
                onMoved(from, to)
            }

        } header: {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                
                Spacer()
                
                Button {
                    onMenuShortPressed()
                } label: {
                    Text("+ Add")
                        .font(.callout)
                        .textCase(.lowercase)
                }
            }
        }
    }

}

