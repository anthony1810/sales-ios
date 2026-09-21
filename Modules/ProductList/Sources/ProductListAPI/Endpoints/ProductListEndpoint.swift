import Foundation

public enum ProductListEndpoint {
    case products
    case sales

    public func request(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "GET"
        return request
    }

    private var path: String {
        switch self {
        case .products: "products"
        case .sales: "sales"
        }
    }
}
