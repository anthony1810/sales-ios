import Foundation

extension UUID {
    public init(_ intValue: Int) {
        self.init(uuidString: String(format: "00000000-0000-0000-0000-%012X", intValue))!
    }
}

extension Date {
    public static func fixture(_ iso8601: String) -> Date {
        try! Date(iso8601, strategy: ISO8601FormatStyle(includingFractionalSeconds: true))
    }
}
