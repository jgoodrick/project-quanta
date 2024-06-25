
import SwiftUI

enum SplashImage: View {
    case url(URL)
    case data(Data)
    case systemName(String)
    
    var body: some View {
        switch self {
        case .url(let url):
            AsyncImage(url: url)
        case .data(let data):
            UIImage(data: data).map(Image.init(uiImage:))?
                .resizable()
                .aspectRatio(contentMode: .fill)
        case .systemName(let name):
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .padding(160)
                .foregroundStyle(.white)
        }
    }
}

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

struct AddAdditionalContextButton: View {
    
    let onAddNewPhoto: () -> Void
    let onAddNewPronunciation: () -> Void
    
    var body: some View {
        Menu(
            content: {
                Button("Add a new photo", systemImage: "photo.badge.plus", action: onAddNewPhoto)
                Button("Add a new pronunciation", systemImage: "waveform.badge.plus", action: onAddNewPronunciation)
            },
            label: {
                Label {
                    Text("Add more context")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        )
        .buttonStyle(.roundedTwoTone())
        .environment(\.roundedTwoToneButton.square, false)
    }
}

