import XCTest

final class SignInAndBrowseUITests: XCTestCase {

    func test_fromLaunch_reachesTheProductsAndOpensOneOfThem() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["END_TO_END"] == "1",
            "Set END_TO_END=1 to run against the real backend"
        )

        let app = XCUIApplication()
        app.launch()

        signInIfAsked(app)

        let products = app.staticTexts["Products"]
        XCTAssertTrue(
            products.waitForExistence(timeout: 20),
            "the product list never appeared"
        )

        let firstProduct = app.buttons.firstMatch
        XCTAssertTrue(firstProduct.waitForExistence(timeout: 10), "no product rows appeared")
        let productName = firstProduct.label
        firstProduct.tap()

        let backToProducts = app.navigationBars.buttons["Products"]
        XCTAssertTrue(
            backToProducts.waitForExistence(timeout: 10),
            "tapping \(productName) did not open a detail screen"
        )
    }

    private func signInIfAsked(_ app: XCUIApplication) {
        let username = app.textFields["Username"]
        guard username.waitForExistence(timeout: 10) else { return }

        username.tap()
        username.typeText("tester")

        let password = app.secureTextFields["Password"]
        password.tap()
        password.typeText("password")

        app.buttons["Log in"].tap()
    }
}
