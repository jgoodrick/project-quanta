
import SwiftUI

struct FavoriteButton: View {
    
    @Binding var favorited: Bool
    var action: () -> Void
    
    var title: String {
        if favorited {
            "Unfavorite"
        } else {
            "Favorite"
        }
    }
    
    var iconSystemName: String {
        if favorited {
            "heart.fill"
        } else {
            "heart"
        }
    }
    
    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                Image(systemName: iconSystemName)
            }
        }
        .buttonStyle(.roundedTwoTone(highlighted: favorited))
        .environment(\.roundedTwoToneButton.square, true)
        .foregroundStyle(.red)
    }
}

#Preview {
    HStack {
        FavoriteButton(favorited: .constant(true), action: { })
        FavoriteButton(favorited: .constant(false), action: { })
    }
}
