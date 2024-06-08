
import SwiftUI

public protocol CategorizedItemsSectionCategory: Identifiable {
    var title: String { get }
}

public protocol CategorizedItem: Identifiable {
    var value: String { get }
}

public struct CategorizedItemsSection<Item: CategorizedItem, Category: CategorizedItemsSectionCategory>: View {
    
    public init(
        title: String,
        items: [Item],
        availableCategories: [Category],
        onSelected: ((Item) -> Void)?,
        onDeleted: @escaping (Item) -> Void,
        onMoved: @escaping (_: IndexSet, _: Int) -> Void,
        onMenuItemTapped: @escaping (Category) -> Void,
        onMenuShortPressed: (() -> Void)?
    ) {
        self.title = title
        self.items = items
        self.availableCategories = availableCategories
        self.onSelected = onSelected
        self.onDeleted = onDeleted
        self.onMoved = onMoved
        self.onMenuItemTapped = onMenuItemTapped
        self.onMenuShortPressed = onMenuShortPressed
    }
    
    let title: String
    let items: [Item]
    let availableCategories: [Category]
    let onSelected: ((Item) -> Void)?
    let onDeleted: (Item) -> Void
    let onMoved: (_ fromOffsets: IndexSet, _ toOffset: Int) -> Void
    let onMenuItemTapped: (Category) -> Void
    let onMenuShortPressed: (() -> Void)?
    
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
//                    Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
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
                
                if let onMenuShortPressed {
                    Menu(content: {
                        // long press
                        ForEach(availableCategories) { menuItem in
                            Button(action: {
                                onMenuItemTapped(menuItem)
                            }) {
                                Label(menuItem.title.capitalized, systemImage: "flag")
                            }
                        }
                    }, label: {
                        Text("+ Add")
                            .font(.callout)
                            .textCase(.lowercase)
                    }, primaryAction: {
                        // on tap
                        onMenuShortPressed()
                    })
                } else {
                    Menu {
                        ForEach(availableCategories) { menuItem in
                            Button(action: {
                                onMenuItemTapped(menuItem)
                            }) {
                                Label(menuItem.title.capitalized, systemImage: "flag")
                            }
                        }
                    } label: {
                        Text("+ Add")
                            .font(.callout)
                            .textCase(.lowercase)
                    }
                }
            }
        }
    }

}
