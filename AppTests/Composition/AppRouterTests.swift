import Foundation
import ProductListFeature
import Testing

@testable import SalesInUSD

@MainActor
struct AppRouterTests {

    @Test func init_startsAtLoginWithNothingPushed() {
        let sut = AppRouter()

        #expect(sut.screen == .login)
        #expect(sut.path.isEmpty)
        #expect(sut.sessionDidExpire == false)
    }

    @Test func signedIn_fromLogin_movesToTheProductList() {
        let sut = AppRouter()

        sut.signedIn()

        #expect(sut.screen == .productList)
    }

    @Test func sessionExpired_whileViewingADetail_returnsToLoginAndClearsThePath() {
        let sut = AppRouter()
        sut.signedIn()
        sut.showDetail(of: Product(id: UUID(1), name: "Mac mini"))

        sut.sessionExpired()

        #expect(sut.screen == .login)
        #expect(sut.path.isEmpty)
        #expect(sut.sessionDidExpire == true)
    }

    @Test func signedIn_afterASessionExpired_clearsTheExpiryNotice() {
        let sut = AppRouter()
        sut.sessionExpired()

        sut.signedIn()

        #expect(sut.sessionDidExpire == false)
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
