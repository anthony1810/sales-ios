import Foundation

public enum SalesEndpoint {
    case sales

    public func request(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: "sales"))
        request.httpMethod = "GET"
        return request
    }
}
