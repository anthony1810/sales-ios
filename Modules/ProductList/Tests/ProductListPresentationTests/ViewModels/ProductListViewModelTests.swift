import Foundation
import ProductListFeature
import ProductListPresentation
import ProductListTestSupport
import TestSupport
import Testing

@MainActor
struct ProductListViewModelTests {

    @Test func load_succeedingLoader_deliversMappedRows() async {
        let summary = makeSummary(id: UUID(1), name: "Mac mini", salesCount: 2)
        let sut = ProductListViewModel.productList(loadSummaries: { [summary] })

        await sut.load()

        #expect(sut.rows.map(\.name) == [summary.name])
        #expect(sut.errorMessage == nil)
    }

    @Test func load_failingLoader_showsTheProductListMessage() async {
        let sut = ProductListViewModel.productList(loadSummaries: { throw anyNSError() })

        await sut.load()

        #expect(sut.errorMessage == ProductListViewModel.productListFailureMessage)
    }
}
