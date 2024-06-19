
import SwiftUI

public protocol EntryListItem {
    var title: String { get }
    var subtitle: String? { get }
}

public struct EntryListItemStyle: EnvironmentKey {
    public static let defaultValue: Self = .init()
    var wordFont: Font = .largeTitle
    var highlightedCharactersFont: Font = .largeTitle
    var highlightedCharactersWeight: Font.Weight = .semibold
    var highlightedCharactersForegroundColor: Color? = .none
    var subtitleFont: Font = .body
    var italicizeSubtitle: Bool = true
}

public struct EntryListItemView<Item: EntryListItem>: View {

    public init(item: Item, highlightedCharacters: Set<Character>) {
        self.item = item
        self.highlightedCharacters = highlightedCharacters
    }
    
    let item: Item
    let highlightedCharacters: Set<Character>
    
    @Environment(\.homeListItem) private var style
    
    func highlighted(character: Character, if condition: Bool) -> Text {
        if condition {
            return Text(String(character))
                .font(style.highlightedCharactersFont)
                .fontWeight(style.highlightedCharactersWeight)
                .foregroundColor(style.highlightedCharactersForegroundColor)
        } else {
            return Text(String(character))
                .font(style.wordFont)
        }
    }
    
    var highlightedTextView: some View {
        var result = Text("")
        for (_, character) in item.title.enumerated() {
            result = result + highlighted(character: character, if: highlightedCharacters.contains(character))
        }
        return result
    }
    
    var italicizedSubtitle: Text? {
        guard let subtitle = item.subtitle else { return nil }
        if style.italicizeSubtitle {
            return Text(subtitle).italic()
        } else {
            return Text(subtitle)
        }
    }
    
    var image: some View {
        Image(systemName: "square.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 60, height: 60)
            .clipped()
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            highlightedTextView
                .allowsTightening(true).minimumScaleFactor(0.5)
            
            italicizedSubtitle
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension EnvironmentValues {
    var homeListItem: EntryListItemStyle {
        get { self[EntryListItemStyle.self] }
        set { self[EntryListItemStyle.self] = newValue }
    }
}

#Preview { Preview }
private var Preview: some View {
    EntryListItemView<MockItem>(
        item: .init(),
        highlightedCharacters: ["i", "l"]
    )
}

private struct MockItem: EntryListItem {
    var title: String = "Title"
    var subtitle: String? = "Subtitle"
}
