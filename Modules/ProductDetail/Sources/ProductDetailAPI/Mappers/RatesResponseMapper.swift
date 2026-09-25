import Foundation
import ProductDetailFeature

public enum RatesResponseMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> RateTable {
        guard response.statusCode == 200,
            let dto = try? JSONDecoder().decode(RatesDTO.self, from: data)
        else {
            throw Error.invalidData
        }
        var ratesToUSD: [String: Decimal] = [:]
        for (currencyCode, rate) in dto.rates {
            guard let decimal = Decimal(string: rate) else { throw Error.invalidData }
            ratesToUSD[currencyCode] = decimal
        }
        return RateTable(ratesToUSD: ratesToUSD)
    }

    private struct RatesDTO: Decodable {
        let rates: [String: String]
    }
}
