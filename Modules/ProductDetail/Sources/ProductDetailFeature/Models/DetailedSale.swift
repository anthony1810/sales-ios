import Foundation

public struct DetailedSale: Equatable, Sendable {
    public let amount: Money
    public let date: Date
    public let convertedToUSD: Money?

    public init(amount: Money, date: Date, convertedToUSD: Money?) {
        self.amount = amount
        self.date = date
        self.convertedToUSD = convertedToUSD
    }
}
