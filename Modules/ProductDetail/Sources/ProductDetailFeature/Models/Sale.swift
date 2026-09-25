import Foundation

public struct Sale: Equatable, Sendable {
    public let productID: UUID
    public let amount: Money
    public let date: Date

    public init(productID: UUID, amount: Money, date: Date) {
        self.productID = productID
        self.amount = amount
        self.date = date
    }
}
