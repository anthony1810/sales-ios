import Foundation
import ProductListAPI
import TestSupport
import Testing

struct ProductListEndpointTests {

    @Test func request_products_getsTheProductsPath() {
        let baseURL = anyURL()

        let request = ProductListEndpoint.products.request(baseURL: baseURL)

        #expect(request.url == baseURL.appending(path: "products"))
        #expect(request.httpMethod == "GET")
    }

    @Test func request_sales_getsTheSalesPath() {
        let baseURL = anyURL()

        let request = ProductListEndpoint.sales.request(baseURL: baseURL)

        #expect(request.url == baseURL.appending(path: "sales"))
        #expect(request.httpMethod == "GET")
    }
}
