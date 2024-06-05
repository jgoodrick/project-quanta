
import SwiftUI

struct AddOrClearButton: View {
    
    let rotated: Bool
    let onTap: () -> Void
    
    struct Style: EnvironmentKey {
        static var defaultValue: Self = .init()
        var clockwise: Bool = true
        var customHeight: Double? = .none
        var background: Color = .gray
    }
    
    var rotationMagnitudeDegrees: Double {
        135
    }
    
    var rotatedAngle: Angle {
        .degrees(style.clockwise ? rotationMagnitudeDegrees : -rotationMagnitudeDegrees)
    }
    
    @Environment(\.addOrClearButton) private var style

    var body: some View {
        Image(systemName: "plus")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(rotated ? rotatedAngle : .zero)
            .animation(.default, value: rotated)
            .padding(6)
            .contentShape(Circle())
            .transition(
                .asymmetric(
                    insertion: AnyTransition.move(edge: .trailing),
                    removal:AnyTransition.move(edge: .trailing)
                )
            )
            .onTapGesture(perform: onTap)
    }
}

extension EnvironmentValues {
    var addOrClearButton: AddOrClearButton.Style {
        get { self[AddOrClearButton.Style.self] }
        set { self[AddOrClearButton.Style.self] = newValue}
    }
}

struct AddOrClearButton_Previews: PreviewProvider {
    static var previews: some View {
        AddOrClearButton(rotated: false) {
            print("")
        }
    }
}
