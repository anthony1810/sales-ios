import Foundation

public struct SaleRow: Equatable, Sendable, Identifiable {
    public let id: Int
    public let amountText: String
    public let dateText: String
    public let convertedText: String

    public init(id: Int, amountText: String, dateText: String, convertedText: String) {
        self.id = id
        self.amountText = amountText
        self.dateText = dateText
        self.convertedText = convertedText
    }
}
