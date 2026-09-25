#if canImport(UIKit)
    import ProductListFeature
    import ProductListPresentation
    import ProductListTestSupport
    import SnapshotTesting
    import SwiftUI
    import TestSupport
    import Testing

    @testable import ProductListUI

    @MainActor
    @Suite struct ProductListSUViewSnapshotTests {

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func content_matchesTheReference(style: UIUserInterfaceStyle) async {
            let summaries = sampleSummaries
            let view = await makeView(loadSummaries: { summaries })

            assert(view, style: style, testName: "content")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func empty_matchesTheReference(style: UIUserInterfaceStyle) async {
            let view = await makeView(loadSummaries: { [] })

            assert(view, style: style, testName: "empty")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func error_matchesTheReference(style: UIUserInterfaceStyle) async {
            let view = await makeView(loadSummaries: { throw anyNSError() })

            assert(view, style: style, testName: "error")
        }

        @Test(arguments: [UIUserInterfaceStyle.light, .dark])
        func refreshFailure_matchesTheReference(style: UIUserInterfaceStyle) async {
            let summaries = screenFillingSummaries
            let calls = LockIsolated(0)
            let view = await makeView(refreshes: 1) {
                let call = calls.withValue { count in
                    count += 1
                    return count
                }
                if call == 1 { return summaries }
                throw anyNSError()
            }

            assert(view, style: style, testName: "refreshFailure")
        }

        // MARK: - Helpers

        private var screenFillingSummaries: [ProductSummary] {
            (1...14).map { index in
                makeSummary(id: UUID(index), name: "Product \(index)", salesCount: index)
            }
        }

        private var sampleSummaries: [ProductSummary] {
            [
                makeSummary(id: UUID(1), name: "Apple TV", salesCount: 1),
                makeSummary(id: UUID(2), name: "iPhone 17 Pro", salesCount: 42),
                makeSummary(id: UUID(3), name: "Mac mini", salesCount: 0),
                makeSummary(id: UUID(4), name: "Studio Display", salesCount: 7),
            ]
        }

        private func makeView(
            refreshes: Int = 0,
            loadSummaries: @escaping @Sendable () async throws -> [ProductSummary]
        ) async -> AnyView {
            let viewModel = ProductListViewModel.productList(loadSummaries: loadSummaries)
            for _ in 0...refreshes {
                await viewModel.load()
            }
            return AnyView(
                NavigationStack { ProductListSUView(viewModel: viewModel) }
                    .transaction { $0.animation = nil }
            )
        }

        private func assert(_ view: some View, style: UIUserInterfaceStyle, testName: String) {
            assertSnapshot(
                of: view,
                as: .image(
                    precision: 0.95,
                    perceptualPrecision: 0.97,
                    layout: .device(config: .iPhone17(style))
                ),
                named: style.snapshotName,
                record: SnapshotHost.isRecording ? .all : nil,
                testName: testName
            )
        }
    }
#endif
