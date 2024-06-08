
import Foundation
import ModelCore
import RelationalCore

extension Database {
    static func mock(entries: Range<Int>, created: Date) -> Self {
        var result = Self.init()
        entries.forEach {
            result.create(.entry(.init(id: .init($0), spelling: "\($0)")), now: created)
        }
        return result
    }
}
