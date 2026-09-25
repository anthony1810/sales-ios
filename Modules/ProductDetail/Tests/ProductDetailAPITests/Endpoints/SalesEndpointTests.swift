import Foundation
import ProductDetailAPI
import TestSupport
import Testing

struct SalesEndpointTests {

    @Test func request_sales_getsTheSalesPath() {
        let baseURL = anyURL()

        let request = SalesEndpoint.sales.request(baseURL: baseURL)

        #expect(request.url == baseURL.appending(path: "sales"))
        #expect(request.httpMethod == "GET")
    }
}
