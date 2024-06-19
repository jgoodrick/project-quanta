
import SwiftUI

public struct AddOrClearButton: View {
    
    public init(rotated: Bool, onTap: @escaping () -> Void) {
        self.rotated = rotated
        self.onTap = onTap
    }
    
    let rotated: Bool
    let onTap: () -> Void
    
    public struct Style: EnvironmentKey {
        public static var defaultValue: Self = .init()
        public var clockwise: Bool = true
        public var customHeight: Double? = .none
        public var background: Color = .gray
    }
    
    var rotationMagnitudeDegrees: Double {
        135
    }
    
    var rotatedAngle: Angle {
        .degrees(style.clockwise ? rotationMagnitudeDegrees : -rotationMagnitudeDegrees)
    }
    
    @Environment(\.addOrClearButton) private var style

    public var body: some View {
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
