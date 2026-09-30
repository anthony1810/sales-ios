import Foundation
import ProductDetailFeature

public enum SalesResponseMapper {
    public enum Error: Swift.Error, Equatable {
        case invalidData
    }

    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [Sale] {
        guard response.statusCode == 200,
            let dtos = try? JSONDecoder().decode([SaleDTO].self, from: data)
        else {
            throw Error.invalidData
        }
        
        return try dtos.map { dto in
            guard let amount = Decimal(string: dto.amount),
                  let date = try? Date(dto.date, strategy: dateStrategy) else { throw Error.invalidData }
            
            return Sale(
                productID: dto.product_id,
                amount: Money(amount: amount, currencyCode: dto.currency_code),
                date: date
            )
        }
    }

    private static let dateStrategy = Date.ISO8601FormatStyle(includingFractionalSeconds: true)

    private struct SaleDTO: Decodable {
        let currency_code: String
        let amount: String
        let product_id: UUID
        let date: String
    }
}
