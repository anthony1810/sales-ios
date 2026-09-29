import Foundation

enum ServiceURLs {
    static let backend = URL(string: "https://ile-b2p4.essentialdeveloper.com")!
    static let defaultRates = URL(string: "http://localhost:8080")!
    static let ratesOverrideKey = "RATES_BASE_URL"

    static func rates(environment: [String: String]) -> URL {
        guard let override = environment[ratesOverrideKey],
            let url = URL(string: override), url.host() != nil
        else {
            return defaultRates
        }
        
        return url
    }
}
