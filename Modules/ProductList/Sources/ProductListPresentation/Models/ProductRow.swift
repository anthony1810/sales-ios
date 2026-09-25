import Foundation

public struct ProductRow: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let name: String
    public let salesCountText: String

    public init(id: UUID, name: String, salesCountText: String) {
        self.id = id
        self.name = name
        self.salesCountText = salesCountText
    }
}
