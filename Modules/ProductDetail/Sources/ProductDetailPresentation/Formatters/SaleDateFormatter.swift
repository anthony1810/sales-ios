import Foundation

public final class SaleDateFormatter {
    private let formatter: DateFormatter

    public init(locale: Locale, timeZone: TimeZone) {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "MMM d, yyyy 'at' h a"
        self.formatter = formatter
    }

    public func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
