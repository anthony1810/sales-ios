import Foundation

public struct ProductDetailViewData: Equatable, Sendable {
    public let title: String
    public let summaryText: String
    public let rows: [SaleRow]

    public init(title: String, summaryText: String, rows: [SaleRow]) {
        self.title = title
        self.summaryText = summaryText
        self.rows = rows
    }
}
