import Foundation
import ProductDetailFeature
import ProductDetailTestSupport
import TestSupport
import Testing

@testable import SalesInUSD

struct ProductDetailServiceTests {

    private enum LoaderCall: Equatable {
        case sales
        case rates
    }

    @Test func loadDetail_bothLoadersSucceed_convertsEverySale() async throws {
        let product = makeProduct(id: UUID(1), name: "Mac mini")
        let sut = ProductDetailService(
            loadSales: {
                [makeSale(productID: product.id, amount: makeMoney(dec("2299"), currencyCode: "BRL"))]
            },
            loadRates: { RateTable(ratesToUSD: ["BRL": dec("0.19")]) }
        )

        let detail = try await sut.loadDetail(of: product)

        #expect(detail.sales.compactMap { $0.convertedToUSD?.amount } == [dec("436.81")])
        #expect(detail.total?.amount == dec("436.81"))
    }

    @Test func loadDetail_failingRates_stillDeliversTheSalesWithoutATotal() async throws {
        let product = makeProduct(id: UUID(1), name: "Mac mini")
        let sut = ProductDetailService(
            loadSales: {
                [makeSale(productID: product.id, amount: makeMoney(dec("2299"), currencyCode: "BRL"))]
            },
            loadRates: { throw anyNSError() }
        )

        let detail = try await sut.loadDetail(of: product)

        #expect(detail.sales.count == 1)
        #expect(detail.sales.allSatisfy { $0.convertedToUSD == nil })
        #expect(detail.total == nil)
    }

    @Test func loadDetail_failingSales_throws() async {
        let sut = ProductDetailService(
            loadSales: { throw anyNSError() },
            loadRates: { RateTable(ratesToUSD: [:]) }
        )

        await #expect(throws: Error.self) {
            try await sut.loadDetail(of: makeProduct())
        }
    }

    @Test func loadDetail_runningLoaders_startsBothBeforeEitherFinishes() async {
        await withMainSerialExecutor {
            let salesGate = Gate()
            let ratesGate = Gate()
            let calls = LockIsolated<[LoaderCall]>([])
            let sut = ProductDetailService(
                loadSales: {
                    calls.withValue { $0.append(.sales) }
                    await salesGate.wait()
                    return []
                },
                loadRates: {
                    calls.withValue { $0.append(.rates) }
                    await ratesGate.wait()
                    return RateTable(ratesToUSD: [:])
                }
            )

            let inFlight = Task { try await sut.loadDetail(of: makeProduct()) }
            await Task.megaYield()

            #expect(calls.value == [.sales, .rates])
            salesGate.open()
            ratesGate.open()
            _ = try? await inFlight.value
        }
    }
}
