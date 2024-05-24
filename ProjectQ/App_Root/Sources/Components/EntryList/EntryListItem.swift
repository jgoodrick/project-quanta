
import ComposableArchitecture
import SwiftUI

public struct HomeListItemView: View {

    let entry: Entry
    let highlightedCharacters: Set<Character>
    
    var title: String {
        entry.spelling
    }
    
    var subtitle: String? {
        .none
//        entry.topTranslation?.spelling
    }
            
    public struct Style: EnvironmentKey {
        public static let defaultValue: Self = .init()
        public var wordFont: Font = .largeTitle
        public var highlightedCharactersFont: Font = .largeTitle
        public var highlightedCharactersWeight: Font.Weight = .semibold
        public var highlightedCharactersForegroundColor: Color? = .none
        public var subtitleFont: Font = .body
        public var italicizeSubtitle: Bool = true
    }
    
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
        for (_, character) in title.enumerated() {
            result = result + highlighted(character: character, if: highlightedCharacters.contains(character))
        }
        return result
    }
    
    var italicizedSubtitle: Text? {
        guard let subtitle else { return nil }
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
    var homeListItem: HomeListItemView.Style {
        get { self[HomeListItemView.Style.self] }
        set { self[HomeListItemView.Style.self] = newValue }
    }
}

//#Preview { Host() }
//private struct Host: View {
//    var body: some View {
//        HomeListItemView(entry: .mock(id: 0, spelling: "Example"), highlightedCharacters: ["E", "x"])
//    }
//}
