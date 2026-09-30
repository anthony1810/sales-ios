import XCTest

@MainActor
final class ProductBrowsingUITests: XCTestCase {

    func test_productList_opensTheDetailOfATappedProduct() throws {
        try requireLiveBackend()
        let app = signedInApp()
        let products = app.productListScreen

        let openedProduct = products.openFirstProduct()

        XCTAssertTrue(
            app.productDetailScreen.isShowingTitle(openedProduct),
            "the detail for \(openedProduct) is visible after tapping its row"
        )
    }

    func test_productDetail_showsTheSalesSummary() throws {
        try requireLiveBackend()
        let app = signedInApp()

        _ = app.productListScreen.openFirstProduct()

        XCTAssertTrue(
            app.productDetailScreen.isShowingSummary,
            "the sales summary is visible on the detail screen"
        )
    }

    func test_session_survivesARelaunchWithoutAskingToSignInAgain() throws {
        try requireLiveBackend()
        let firstLaunch = signedInApp()
        XCTAssertTrue(firstLaunch.productListScreen.isShowing, "the product list is visible before the relaunch")
        firstLaunch.terminate()

        let secondLaunch = XCUIApplication.launch(.online, session: .kept)

        XCTAssertTrue(secondLaunch.productListScreen.isShowing, "the product list is visible after the relaunch")
    }

    // MARK: - Helpers

    private func signedInApp() -> XCUIApplication {
        let app = XCUIApplication.launch(.online, session: .signedOut)
        app.loginScreen.signIn(as: .valid)
        XCTAssertTrue(app.productListScreen.isShowing, "expected the product list after signing in")
        return app
    }
}
