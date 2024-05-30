
import Dependencies
import OSLog

extension DependencyValues {
    public var logger: Logger {
        get { self[Logger.self] }
        set { self[Logger.self] = newValue }
    }
}

extension Logger: DependencyKey {
    public static var liveValue: Logger { Logger() }
    public static var testValue: Logger { Logger() }
    public static var previewValue: Logger { Logger() }
}

extension Logger {
    public subscript(category: String) -> Logger {
        Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(short id: UUID) {
        appendInterpolation(id.uuidString.suffix(3))
    }
}
