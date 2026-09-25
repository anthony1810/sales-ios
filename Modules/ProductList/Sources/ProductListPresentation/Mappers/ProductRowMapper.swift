import Foundation
import ProductListFeature

public enum ProductRowMapper {
    public static func rows(from summaries: [ProductSummary]) -> [ProductRow] {
        summaries.map {
            ProductRow(
                id: $0.id,
                name: $0.name,
                salesCountText: salesCountText(for: $0.salesCount)
            )
        }
    }

    private static func salesCountText(for count: Int) -> String {
        String.localizedStringWithFormat(Localized.string("PRODUCT_SALES_COUNT"), count)
    }
}
