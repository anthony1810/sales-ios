import Foundation

public struct Sale: Equatable, Sendable {
    public let productID: UUID

    public init(productID: UUID) {
        self.productID = productID
    }
}
