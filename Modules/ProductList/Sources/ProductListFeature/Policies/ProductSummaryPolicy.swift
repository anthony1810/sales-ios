import Foundation

public enum ProductSummaryPolicy {
    public static func summaries(products: [Product], sales: [Sale]) -> [ProductSummary] {
        var countsByProductID: [UUID: Int] = [:]
        for sale in sales {
            countsByProductID[sale.productID, default: 0] += 1
        }
        return products
            .map {
                ProductSummary(
                    id: $0.id,
                    name: $0.name,
                    salesCount: countsByProductID[$0.id, default: 0]
                )
            }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
