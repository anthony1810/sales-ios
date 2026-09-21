import Foundation

extension UUID {
    public init(_ intValue: Int) {
        self.init(uuidString: String(format: "00000000-0000-0000-0000-%012X", intValue))!
    }
}

extension Date {
    public static func fixture(_ iso8601: String) -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: iso8601)!
    }
}
