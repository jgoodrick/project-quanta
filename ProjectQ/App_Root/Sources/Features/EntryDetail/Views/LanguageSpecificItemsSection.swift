
import SwiftUI
import Model

protocol CategorizedItemsSectionCategory: Identifiable {
    var title: String { get }
}

protocol CategorizedItem: Identifiable {
    var value: String { get }
}

struct CategorizedItemsSection<Item: CategorizedItem, Category: CategorizedItemsSectionCategory>: View {
    
    let title: String
    let items: [Item]
    let availableCategories: [Category]
    let onSelected: ((Item) -> Void)?
    let onDeleted: (Item) -> Void
    let onMoved: (_ fromOffsets: IndexSet, _ toOffset: Int) -> Void
    let onMenuItemTapped: (Category) -> Void
    let onMenuShortPressed: (() -> Void)?
    
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
                    Image(systemName: "line.3.horizontal").foregroundStyle(.secondary)
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
