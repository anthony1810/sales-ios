import Foundation
import ProductDetailFeature
import ProductDetailTestSupport
import TestSupport
import Testing

struct ProductDetailPolicyTests {

    // MARK: - Converted to USD

    @Test func convertedToUSD_currencyInTheTable_multipliesByItsRateExactly() {
        let brlRate = dec("0.19")
        let rates = RateTable(ratesToUSD: ["BRL": brlRate])
        let sold = makeMoney(dec("2299"), currencyCode: "BRL")

        let converted = ProductDetailPolicy.convertedToUSD(sold, using: rates)

        #expect(converted == makeMoney(dec("436.81"), currencyCode: ProductDetailPolicy.usdCurrencyCode))
    }

    @Test func convertedToUSD_currencyMissingFromTheTable_deliversNothing() {
        let rates = RateTable(ratesToUSD: ["BRL": dec("0.19")])
        let unlistedCurrency = makeMoney(dec("10"), currencyCode: "AUD")

        #expect(ProductDetailPolicy.convertedToUSD(unlistedCurrency, using: rates) == nil)
    }

    // MARK: - Detail

    @Test func detail_salesOfSeveralProducts_keepsOnlyTheRequestedProducts() {
        let requestedProduct = makeProduct(id: UUID(1), name: "Mac mini")
        let otherProduct = makeProduct(id: UUID(2), name: "Apple TV")
        let requestedSale = makeSale(productID: requestedProduct.id, amount: makeMoney(10))
        let otherSale = makeSale(productID: otherProduct.id, amount: makeMoney(20))

        let detail = ProductDetailPolicy.detail(
            of: requestedProduct,
            sales: [otherSale, requestedSale],
            rates: nil
        )

        #expect(detail.product == requestedProduct)
        #expect(detail.sales.map(\.amount) == [requestedSale.amount])
    }

    @Test func detail_salesOutOfOrder_sortsThemNewestFirst() {
        let product = makeProduct(id: UUID(1))
        let newest = Date()
        let middle = newest.addingTimeInterval(-3600)
        let oldest = newest.addingTimeInterval(-7200)
        let sales = [
            makeSale(productID: product.id, date: middle),
            makeSale(productID: product.id, date: oldest),
            makeSale(productID: product.id, date: newest),
        ]

        let detail = ProductDetailPolicy.detail(of: product, sales: sales, rates: nil)

        #expect(detail.sales.map(\.date) == [newest, middle, oldest])
    }

    @Test func detail_everySaleConverts_carriesEachConversionAndTheExactTotal() {
        let product = makeProduct(id: UUID(1))
        let brlRate = dec("0.19")
        let gbpRate = dec("1.27")
        let rates = RateTable(ratesToUSD: ["BRL": brlRate, "GBP": gbpRate])
        let brlSale = makeSale(
            productID: product.id, amount: makeMoney(dec("2299"), currencyCode: "BRL"))
        let gbpSale = makeSale(
            productID: product.id, amount: makeMoney(dec("304"), currencyCode: "GBP"))

        let detail = ProductDetailPolicy.detail(
            of: product, sales: [brlSale, gbpSale], rates: rates)

        let brlInUSD = makeMoney(dec("436.81"), currencyCode: ProductDetailPolicy.usdCurrencyCode)
        let gbpInUSD = makeMoney(dec("386.08"), currencyCode: ProductDetailPolicy.usdCurrencyCode)
        #expect(Set(detail.sales.compactMap(\.convertedToUSD).map(\.amount)) == [brlInUSD.amount, gbpInUSD.amount])
        #expect(detail.total == makeMoney(dec("822.89"), currencyCode: ProductDetailPolicy.usdCurrencyCode))
    }

    @Test func detail_oneSaleCannotConvert_leavesTheTotalUnknown() {
        let product = makeProduct(id: UUID(1))
        let rates = RateTable(ratesToUSD: ["BRL": dec("0.19")])
        let convertibleSale = makeSale(
            productID: product.id, amount: makeMoney(dec("2299"), currencyCode: "BRL"))
        let unlistedSale = makeSale(
            productID: product.id, amount: makeMoney(dec("10"), currencyCode: "AUD"))

        let detail = ProductDetailPolicy.detail(
            of: product, sales: [convertibleSale, unlistedSale], rates: rates)

        #expect(detail.total == nil)
        #expect(detail.sales.filter { $0.convertedToUSD == nil }.count == 1)
    }

    @Test func detail_withoutARateTable_leavesEveryConversionAndTheTotalUnknown() {
        let product = makeProduct(id: UUID(1))
        let sale = makeSale(
            productID: product.id, amount: makeMoney(dec("2299"), currencyCode: "BRL"))

        let detail = ProductDetailPolicy.detail(of: product, sales: [sale], rates: nil)

        #expect(detail.sales.allSatisfy { $0.convertedToUSD == nil })
        #expect(detail.total == nil)
    }
}
