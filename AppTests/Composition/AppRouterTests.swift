import Foundation
import ProductListFeature
import Testing

@testable import SalesInUSD

@MainActor
struct AppRouterTests {

    @Test func init_startsWithNothingPushed() {
        let sut = AppRouter()

        #expect(sut.path.isEmpty)
    }

    @Test func showDetail_aProduct_pushesThatProductOntoThePath() {
        let selected = Product(id: UUID(1), name: "Mac mini")
        let sut = AppRouter()

        sut.showDetail(of: selected)

        #expect(sut.path == [.detail(selected)])
    }

    @Test func showDetail_twoProducts_pushesBothInOrder() {
        let firstSelected = Product(id: UUID(1), name: "Mac mini")
        let secondSelected = Product(id: UUID(2), name: "Apple TV")
        let sut = AppRouter()

        sut.showDetail(of: firstSelected)
        sut.showDetail(of: secondSelected)

        #expect(sut.path == [.detail(firstSelected), .detail(secondSelected)])
    }
}
