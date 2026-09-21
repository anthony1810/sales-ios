import Foundation

public struct ProductSummary: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let salesCount: Int

    public init(id: UUID, name: String, salesCount: Int) {
        self.id = id
        self.name = name
        self.salesCount = salesCount
    }
}
