import Foundation

public enum RatesEndpoint {
    case rates

    public func request(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: "rates"))
        request.httpMethod = "GET"
        return request
    }
}
