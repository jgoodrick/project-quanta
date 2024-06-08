
import Foundation

extension UUID {
    init(_ intValue: Int) {
        self.init(uuidString: "00000000-0000-0000-0000-\(String(format: "%012x", intValue))")!
    }
}
