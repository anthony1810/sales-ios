import XCTest

@MainActor
final class LoginUITests: XCTestCase {

    func test_login_showsAnErrorWhenTheAppCannotReachTheBackend() {
        let app = XCUIApplication.launch(.offline, session: .signedOut)
        let login = app.loginScreen
        XCTAssertTrue(login.isShowing, "the login screen is visible on a signed out launch")

        login.signIn(as: .valid)

        XCTAssertTrue(login.isShowingError, "the login error is visible after an offline attempt")
    }

    func test_login_showsTheProductListAfterSigningIn() throws {
        try requireLiveBackend()
        let app = XCUIApplication.launch(.online, session: .signedOut)
        let login = app.loginScreen
        XCTAssertTrue(login.isShowing, "the login screen is visible on a signed out launch")

        login.signIn(as: .valid)

        XCTAssertTrue(app.productListScreen.isShowing, "the product list is visible after signing in")
    }
}
