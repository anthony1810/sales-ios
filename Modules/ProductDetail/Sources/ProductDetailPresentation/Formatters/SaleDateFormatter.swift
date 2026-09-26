import Foundation
import SharedPresentation

public final class SaleDateFormatter {
    private let formatter: DateFormatter

    public init(locale: Locale, timeZone: TimeZone) {
        let strings = Bundle.productDetailPresentation.localized(for: locale)
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.amSymbol = NSLocalizedString("SALE_DATE_AM", bundle: strings, comment: "")
        formatter.pmSymbol = NSLocalizedString("SALE_DATE_PM", bundle: strings, comment: "")
        formatter.dateFormat = NSLocalizedString("SALE_DATE_FORMAT", bundle: strings, comment: "")
        self.formatter = formatter
    }

    public func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
