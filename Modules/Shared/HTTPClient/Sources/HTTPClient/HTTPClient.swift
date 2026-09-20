import Foundation

public protocol HTTPClient: Sendable {
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}
