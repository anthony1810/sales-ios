import Foundation
import HTTPClient

public final class URLSessionHTTPClient: HTTPClient {
    public struct UnexpectedValuesRepresentation: Error {}

    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    public func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            throw UnexpectedValuesRepresentation()
        }
        return (data, response)
    }
}
