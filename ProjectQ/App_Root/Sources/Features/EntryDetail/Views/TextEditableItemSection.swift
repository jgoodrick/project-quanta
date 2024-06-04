
import SwiftUI

protocol TextEditableItem: Identifiable {
    var boundValue: Binding<String> { get }
}

struct TextEditableItemsSection<Item: TextEditableItem>: View {
    
    let title: String
    let items: [Item]
    @Binding var focusedItem: Item.ID?
    let onDelete: (Item) -> Void
    let onMoved: (_ fromOffsets: IndexSet, _ toOffset: Int) -> Void
    let onMenuShortPressed: () -> Void
    
    @FocusState private var focused: Item.ID?
    
    var body: some View {
        Section {
            ForEach(items) { item in
                TextEditor(text: item.boundValue)
                    .focused($focused, equals: item.id)
                    .swipeActions {
                        Button(
                            role: .destructive,
                            action: {
                                onDelete(item)
                            },
                            label: {
                                Label(title: { Text("Delete") }, icon: { Image(systemName: "trash") })
                            }
                        )
                    }
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
        .synchronize($focusedItem, $focused)
    }

}

