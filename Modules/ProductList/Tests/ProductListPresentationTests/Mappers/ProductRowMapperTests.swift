import Foundation
import ProductListFeature
import ProductListPresentation
import ProductListTestSupport
import TestSupport
import Testing

struct ProductRowMapperTests {

    @Test func rows_severalSummaries_keepTheirOrderIdentityAndName() {
        let firstSummary = makeSummary(id: UUID(1), name: "Apple TV", salesCount: 2)
        let secondSummary = makeSummary(id: UUID(2), name: "Mac mini", salesCount: 0)

        let rows = ProductRowMapper.rows(from: [firstSummary, secondSummary])

        #expect(rows.map(\.id) == [firstSummary.id, secondSummary.id])
        #expect(rows.map(\.name) == [firstSummary.name, secondSummary.name])
    }

    @Test func rows_oneSale_readsAsTheEnglishSingular() throws {
        try requireEnglishBundle()
        let englishSingular = "1 sale"
        let soldOnce = makeSummary(salesCount: 1)

        let rows = ProductRowMapper.rows(from: [soldOnce])

        #expect(rows.map(\.salesCountText) == [englishSingular])
    }

    @Test func rows_severalSales_readAsTheEnglishPlural() throws {
        try requireEnglishBundle()
        let englishPlural = "2 sales"
        let soldTwice = makeSummary(salesCount: 2)

        let rows = ProductRowMapper.rows(from: [soldTwice])

        #expect(rows.map(\.salesCountText) == [englishPlural])
    }

    @Test func rows_noSales_readAsTheEnglishPlural() throws {
        try requireEnglishBundle()
        let englishZero = "0 sales"
        let neverSold = makeSummary(salesCount: 0)

        let rows = ProductRowMapper.rows(from: [neverSold])

        #expect(rows.map(\.salesCountText) == [englishZero])
    }

    // MARK: - Helpers

    private func requireEnglishBundle() throws {
        try #require(Bundle.productListPresentation.preferredLocalizations.first == "en")
    }
}
