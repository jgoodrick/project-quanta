
import StructuralModel
import SwiftUI

struct EntryDetailContent: View {
    let entry: Entry
    let displayTag: (Language) -> String
    @State private var image: Image? = Image(systemName: "star.circle")
    @State private var favorited: Bool = false
    @State private var keywords: [String] = [
        "noun", "plural", "masculine",
    ]
    @State private var phonetic: String = "pro-noun-cia-tion"
    @State private var translations: [Translation] = [
        .init(
            value: "quanta",
            language: .english
        ),
        .init(
            value: "cuantos",
            language: .spanish
        ),
    ]
    @State private var examples: [ExampleCouplet] = [
        .init(
            index: 1,
            example: "Учені досліджували властивості квантів у рамках нової теорії фізики.",
            translated: [
                .init(
                    value: "Scientists studied the properties of quanta within the framework of a new theory in physics.",
                    language: .english
                ),
                .init(
                    value: "Los científicos investigaron las propiedades de los cuantos en el marco de una nueva teoría de la física.",
                    language: .spanish
                ),
            ]
        ),
        .init(
            index: 2,
            example: "Квантова механіка описує поведінку частинок на рівні квантів.",
            translated: [
                .init(
                    value: "Quantum mechanics describes the behavior of particles at the level of quanta.",
                    language: .english
                ),
            ]
        ),
    ]
    
    @State private var notes: [IndexedNote] = [
        .init(
            index: 1,
            value: "this word is really only used in physics contexts in Ukrainian"
        ),
    ]
    
    @State private var relatedWords: [Entry] = [
        .init(id: .init(rawValue: .init()), spelling: "Квантова"),
        .init(id: .init(rawValue: .init()), spelling: "квантів"),
        .init(id: .init(rawValue: .init()), spelling: "Квантова"),
    ]
    
    struct IndexedNote: Identifiable {
        var id: Int { index }
        var index: Int
        var value: String
    }
    
    struct ExampleCouplet: Identifiable {
        var id: Int { index }
        var index: Int
        var example: String
        var translated: [Translation] = []
    }
    
    struct Translation: Identifiable {
        var id: String { value }
        var value: String
        var language: Language
    }
    
    var splashImage: some View {
        image?
            .resizable()
            .aspectRatio(contentMode: .fill)
            .padding(100)
            .foregroundStyle(.white)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            splashImage
                .frame(maxHeight: 100)
                .background {
                    Rectangle().fill(.black).ignoresSafeArea()
                }

            VStack {
                HStack {
                    
                    Text(entry.spelling)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    PronunciationButton(available: true) {
                        print("tapped pronunciation button")
                    }

                    Spacer()
                    
                    AddToCollectionButton {
                        print("tapped collection button")
                    }
                    .foregroundStyle(.mint)
                    
                }
                .padding([.leading, .top, .trailing])
                
                ScrollView(.vertical) {
                    
                    VStack(spacing: 16) {
                        
                        HStack {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(keywords, id: \.self) { keyword in
                                        KeywordButton(title: keyword) {
                                            print("\(keyword) button tapped")
                                        }
                                    }
                                }
                            }
                            .scrollClipDisabled()
                            
                            AddKeywordButton {
                                print("tapped add keyword button")
                            }
                        }
                        .foregroundStyle(.cyan)
                        
                        VStack {
                            SectionHeader(title: "Translations") {
                                AddTranslationButton {
                                    print("tapped add translation button")
                                }
                            }
                            .foregroundStyle(.purple)

                            ForEach(translations) { translation in
                                Menu {
                                    Button("Edit Translation") {
                                        print("tapped edit menu item for \(translation.value)")
                                    }
                                    Button("Go To") {
                                        print("tapped go to menu item for \(translation.value)")
                                    }
                                } label: {
                                    HStack {
                                        Text(displayTag(translation.language))
                                            .foregroundStyle(.background)
                                            .padding(4)
                                            .background(.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                        Text(translation.value)
                                            .font(.title)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                } primaryAction: {
                                    print("tapped \(translation.value)")
                                }
                            }
                        }

                        VStack {
                            SectionHeader(title: "Examples") {
                                AddExampleButton {
                                    print("tapped add example button")
                                }
                            }
                            .foregroundStyle(.indigo)
                            
                            
                            ForEach(examples) { couplet in
                                HStack(alignment: .top) {
                                    Text("\(couplet.index).")
                                    VStack {
                                        Text(couplet.example)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        ForEach(couplet.translated) { translated in
                                            HStack(alignment: .top) {
                                                Text(displayTag(translated.language))
                                                    .foregroundStyle(.background)
                                                    .padding(4)
                                                    .background(.secondary)
                                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                                Text(translated.value)
                                                    .italic()
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.top, 1)
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                            }
                        }
                        
                        VStack {
                            
                            SectionHeader(title: "Notes") {
                                AddNoteButton {
                                    print("tapped add note button")
                                }
                            }
                            .foregroundStyle(.purple)
                            
                            ForEach(notes) { note in
                                HStack(alignment: .top) {
                                    Text("\(note.index).")
                                    Text(note.value)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.top, 8)
                            }
                            
                        }
                        
                        VStack {
                            
                            SectionHeader(title: "See Also") {
                                AddRelatedWordButton {
                                    print("tapped Add Related Word button")
                                }
                            }
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(relatedWords) { word in
                                        KeywordButton(title: word.spelling) {
                                            print("\(word.spelling) button tapped")
                                        }
                                    }
                                }
                            }
                            
                        }
                        .foregroundStyle(.indigo)
                        
                    }
                    .padding(.horizontal)
                }
                .scrollIndicators(.hidden)
                .safeAreaPadding(.bottom, 64)
            }
        }
    }
}

struct PronunciationButton: View {
    
    let available: Bool
    var action: () -> Void
    
    var body: some View {
        Button {
            print("tapped pronunciation button")
        } label: {
            if available {
                Image(systemName: "waveform.path")
            } else {
                Image(systemName: "waveform.path.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
//        .environment(\.roundedTwoToneButton.dimension, 32)
        .environment(\.adaptiveHighlightableTwoTone.lightMode.standard.background, .clear)
        .foregroundStyle(.blue)
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

struct AddPhotoButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Photo")
            } icon: {
                Image(systemName: "photo.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct AddTranslationButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Translation")
            } icon: {
                Image(systemName: "character.book.closed.fill")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct AddKeywordButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Keyword")
            } icon: {
                Image(systemName: "tag")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct KeywordButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .italic()
                .padding(6)
        }
        .buttonStyle(.roundedTwoTone(highlighted: false))
        .environment(\.roundedTwoToneButton.square, false)
        .environment(\.roundedTwoToneButton.dimension, .none)
    }
}

struct AddToCollectionButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add to Collection")
            } icon: {
                Image(systemName: "rectangle.stack.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct AddExampleButton: View {
    let action: () -> Void
    var square: Bool = false
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Example")
            } icon: {
                Image(systemName: "text.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct AddNoteButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Note")
            } icon: {
                Image(systemName: "pencil.tip.crop.circle.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

struct AddRelatedWordButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label {
                Text("Add Related Word")
            } icon: {
                Image(systemName: "link.badge.plus")
            }
        }
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, true)
    }
}

#Preview {
    EntryDetailContent(entry: .init(id: .mock(0), spelling: "кванти"), displayTag: { $0.primaryLanguage ?? "??" })
}
