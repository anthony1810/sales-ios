import Foundation
import ProductDetailFeature
import ProductDetailPresentation
import ProductDetailTestSupport
import SharedPresentation
import TestSupport
import Testing

@MainActor
struct ProductDetailViewModelTests {

    @Test func init_doesNotLoad() {
        let calls = LockIsolated(0)
        _ = makeSUT(loadDetail: {
            calls.withValue { $0 += 1 }
            return anyDetail()
        })

        #expect(calls.value == 0)
    }

    @Test func load_succeedingLoader_deliversTheMappedViewData() async {
        let product = makeProduct(id: UUID(1), name: "Mac mini")
        let sut = makeSUT(loadDetail: { anyDetail(product: product) })

        await sut.load()

        #expect(sut.viewData?.title == product.name)
        #expect(sut.errorMessage == nil)
        #expect(sut.isLoading == false)
    }

    @Test func load_failingLoader_showsTheDetailMessageAndKeepsNoViewData() async {
        let sut = makeSUT(loadDetail: { throw anyNSError() })

        await sut.load()

        #expect(sut.errorMessage == ProductDetailViewModel.loadErrorMessage)
        #expect(sut.viewData == nil)
        #expect(sut.isLoading == false)
    }

    @Test func load_withAPriorFailure_clearsTheErrorOnSuccess() async throws {
        let calls = LockIsolated(0)
        let sut = makeSUT(loadDetail: {
            let call = calls.withValue { count in
                count += 1
                return count
            }
            if call == 1 { throw anyNSError() }
            return anyDetail()
        })

        await sut.load()
        try #require(sut.errorMessage != nil)

        await sut.load()

        #expect(sut.errorMessage == nil)
        #expect(sut.viewData != nil)
    }

    @Test func load_runningLoader_reportsLoading() async {
        await withMainSerialExecutor {
            let gate = Gate()
            let sut = makeSUT(loadDetail: {
                await gate.wait()
                return anyDetail()
            })

            let inFlight = Task { await sut.load() }
            await Task.megaYield()

            #expect(sut.isLoading == true)
            gate.open()
            await inFlight.value
            #expect(sut.isLoading == false)
        }
    }

    @Test func load_overlappingLoads_sendOneRequest() async {
        await withMainSerialExecutor {
            let gate = Gate()
            let calls = LockIsolated(0)
            let sut = makeSUT(loadDetail: {
                calls.withValue { $0 += 1 }
                await gate.wait()
                return anyDetail()
            })

            let firstLoad = Task { await sut.load() }
            await Task.megaYield()
            let secondLoad = Task { await sut.load() }
            await Task.megaYield()
            gate.open()
            await firstLoad.value
            await secondLoad.value

            #expect(calls.value == 1)
        }
    }

    // MARK: - Helpers

    private func makeSUT(
        loadDetail: @escaping @Sendable () async throws -> ProductDetail
    ) -> ProductDetailViewModel {
        ProductDetailViewModel(
            loadDetail: loadDetail,
            mapper: ProductDetailViewMapper(
                dates: SaleDateFormatter(
                    locale: Locale(identifier: "en_US"), timeZone: TimeZone(identifier: "UTC")!),
                money: MoneyFormatter(locale: Locale(identifier: "en_US"))
            )
        )
    }
}

private func anyDetail(product: Product = makeProduct()) -> ProductDetail {
    ProductDetail(product: product, sales: [], total: nil)
}
