#if canImport(UIKit)
    import Foundation
    import ProductDetailFeature
    import ProductDetailPresentation
    import ProductDetailTestSupport
    import SharedPresentation
    import SnapshotTesting
    import SwiftUI
    import TestSupport
    import Testing

    @testable import ProductDetailUI

    @MainActor
    @Suite struct ProductDetailSUViewSnapshotTests {

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func content_matchesTheReference(style: UIUserInterfaceStyle) async {
            let detail = convertedDetail
            let view = await makeView(loadDetail: { detail })

            assert(view, style: style, testName: "content")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func usdUnavailable_matchesTheReference(style: UIUserInterfaceStyle) async {
            let detail = unconvertedDetail
            let view = await makeView(loadDetail: { detail })

            assert(view, style: style, testName: "usdUnavailable")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func empty_matchesTheReference(style: UIUserInterfaceStyle) async {
            let detail = ProductDetail(product: makeProduct(name: "Mac mini"), sales: [], total: nil)
            let view = await makeView(loadDetail: { detail })

            assert(view, style: style, testName: "empty")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func error_matchesTheReference(style: UIUserInterfaceStyle) async {
            let view = await makeView(loadDetail: { throw anyNSError() })

            assert(view, style: style, testName: "error")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func reloadFailure_matchesTheReference(style: UIUserInterfaceStyle) async {
            let detail = convertedDetail
            let calls = LockIsolated(0)
            let view = await makeView(loads: 2) {
                let call = calls.withValue { count in
                    count += 1
                    return count
                }
                if call == 1 { return detail }
                throw anyNSError()
            }

            assert(view, style: style, testName: "reloadFailure")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func loading_matchesTheReference(style: UIUserInterfaceStyle) async {
            await withMainSerialExecutor {
                let gate = Gate()
                let viewModel = ProductDetailViewModel(
                    loadDetail: {
                        await gate.wait()
                        return ProductDetail(product: makeProduct(), sales: [], total: nil)
                    },
                    mapper: ProductDetailViewMapper(
                        dates: SaleDateFormatter(
                            locale: Locale(identifier: "en_US"),
                            timeZone: TimeZone(identifier: "UTC")!
                        ),
                        money: MoneyFormatter(locale: Locale(identifier: "en_US"))
                    )
                )
                let view = AnyView(
                    NavigationStack { ProductDetailSUView(viewModel: viewModel) }
                        .transaction { $0.animation = nil }
                )
                let inFlight = Task { await viewModel.load() }
                await Task.megaYield()

                assert(view, style: style, testName: "loading")
                gate.open()
                await inFlight.value
            }
        }

        // MARK: - Helpers

        private var convertedDetail: ProductDetail {
            ProductDetail(
                product: makeProduct(id: UUID(1), name: "Mac mini"),
                sales: [
                    DetailedSale(
                        amount: makeMoney(dec("2299"), currencyCode: "BRL"),
                        date: Date.fixture("2030-01-02T11:00:00.000Z"),
                        convertedToUSD: makeMoney(dec("436.81"), currencyCode: "USD")),
                    DetailedSale(
                        amount: makeMoney(dec("304"), currencyCode: "GBP"),
                        date: Date.fixture("2030-01-01T15:00:00.000Z"),
                        convertedToUSD: makeMoney(dec("386.08"), currencyCode: "USD")),
                    DetailedSale(
                        amount: makeMoney(dec("1480.79"), currencyCode: "AUD"),
                        date: Date.fixture("2029-12-30T08:30:00.000Z"),
                        convertedToUSD: makeMoney(dec("972.18"), currencyCode: "USD")),
                ],
                total: makeMoney(dec("1795.07"), currencyCode: "USD"))
        }

        private var unconvertedDetail: ProductDetail {
            ProductDetail(
                product: makeProduct(id: UUID(1), name: "Mac mini"),
                sales: [
                    DetailedSale(
                        amount: makeMoney(dec("2299"), currencyCode: "BRL"),
                        date: Date.fixture("2030-01-02T11:00:00.000Z"),
                        convertedToUSD: nil),
                    DetailedSale(
                        amount: makeMoney(dec("304"), currencyCode: "GBP"),
                        date: Date.fixture("2030-01-01T15:00:00.000Z"),
                        convertedToUSD: nil),
                ],
                total: nil)
        }

        private func makeView(
            loads: Int = 1,
            loadDetail: @escaping @Sendable () async throws -> ProductDetail
        ) async -> AnyView {
            let viewModel = ProductDetailViewModel(
                loadDetail: loadDetail,
                mapper: ProductDetailViewMapper(
                    dates: SaleDateFormatter(
                        locale: Locale(identifier: "en_US"),
                        timeZone: TimeZone(identifier: "UTC")!),
                    money: MoneyFormatter(locale: Locale(identifier: "en_US"))))
            for _ in 0..<loads {
                await viewModel.load()
            }
            return AnyView(
                NavigationStack { ProductDetailSUView(viewModel: viewModel) }
                    .transaction { $0.animation = nil })
        }

        private func assert(_ view: some View, style: UIUserInterfaceStyle, testName: String) {
            assertSnapshot(
                of: view,
                as: .image(
                    precision: 0.95,
                    perceptualPrecision: 0.97,
                    layout: .device(config: .iPhone17(style))),
                named: style.snapshotName,
                record: SnapshotHost.isRecording ? .all : nil,
                testName: testName)
        }
    }
#endif
