import Foundation

public struct RateTable: Equatable, Sendable {
    private let ratesToUSD: [String: Decimal]

    public init(ratesToUSD: [String: Decimal]) {
        self.ratesToUSD = ratesToUSD
    }

    public func rateToUSD(for currencyCode: String) -> Decimal? {
        ratesToUSD[currencyCode]
    }
}
