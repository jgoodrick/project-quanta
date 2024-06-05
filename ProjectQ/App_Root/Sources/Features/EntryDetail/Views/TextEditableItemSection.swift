
import SwiftUI

protocol TextEditableItem: Identifiable {
    var value: String { get }
}

struct TextEditableItemsSection<Item: TextEditableItem>: View {
    
    let title: String
    let items: [Item]
    let onSelected: ((Item) -> Void)?
    let onDeleted: (Item) -> Void
    let onMoved: (_ fromOffsets: IndexSet, _ toOffset: Int) -> Void
    let onMenuShortPressed: () -> Void
        
    var body: some View {
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

