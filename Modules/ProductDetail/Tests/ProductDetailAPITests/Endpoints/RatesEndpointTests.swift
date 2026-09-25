import Foundation
import ProductDetailAPI
import TestSupport
import Testing

struct RatesEndpointTests {

    @Test func request_rates_getsTheRatesPath() {
        let baseURL = anyURL()

        let request = RatesEndpoint.rates.request(baseURL: baseURL)

        #expect(request.url == baseURL.appending(path: "rates"))
        #expect(request.httpMethod == "GET")
    }
}
