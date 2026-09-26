import Foundation
import ProductListFeature
import ProductListTestSupport
import TestSupport
import Testing

@testable import SalesInUSD

struct ProductListServiceTests {

    private enum LoaderCall: Equatable {
        case products
        case sales
    }

    @Test func loadSummaries_bothLoadersSucceed_joinsThemWithThePolicy() async throws {
        let product = makeProduct(id: UUID(1), name: "Mac mini")
        let sut = ProductListService(
            loadProducts: { [product] },
            loadSales: { [makeSale(productID: product.id)] }
        )

        let summaries = try await sut.loadSummaries()

        #expect(summaries == [makeSummary(of: product, salesCount: 1)])
    }

    @Test func loadSummaries_productsLoaderFails_throws() async {
        let sut = ProductListService(loadProducts: { throw anyNSError() }, loadSales: { [] })

        await #expect(throws: Error.self) {
            try await sut.loadSummaries()
        }
    }

    @Test func loadSummaries_salesLoaderFails_throws() async {
        let sut = ProductListService(loadProducts: { [] }, loadSales: { throw anyNSError() })

        await #expect(throws: Error.self) {
            try await sut.loadSummaries()
        }
    }

    @Test func loadSummaries_runningLoaders_startsBothBeforeEitherFinishes() async {
        await withMainSerialExecutor {
            let productsGate = Gate()
            let salesGate = Gate()
            let calls = LockIsolated<[LoaderCall]>([])
            let sut = ProductListService(
                loadProducts: {
                    calls.withValue { $0.append(.products) }
                    await productsGate.wait()
                    return []
                },
                loadSales: {
                    calls.withValue { $0.append(.sales) }
                    await salesGate.wait()
                    return []
                }
            )

            let inFlight = Task { try await sut.loadSummaries() }
            await Task.megaYield()

            #expect(calls.value == [.products, .sales])
            productsGate.open()
            salesGate.open()
            _ = try? await inFlight.value
        }
    }
}
