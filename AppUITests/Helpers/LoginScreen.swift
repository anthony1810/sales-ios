import XCTest

@MainActor
struct LoginScreen {
    let app: XCUIApplication

    var isShowing: Bool { username.appears() }
    var isShowingError: Bool { app.staticTexts["login.error"].appears() }
    var isShowingSessionExpired: Bool { app.staticTexts["login.sessionExpired"].appears() }
    var canSubmit: Bool { submit.isEnabled }

    func signIn(as account: TesterAccount) {
        XCTAssertTrue(username.appears(), "expected the username field before signing in")
        username.tap()
        username.typeText(account.username)

        password.tap()
        password.typeText(account.password)

        submit.tap()
    }

    private var username: XCUIElement { app.textFields["login.username"] }
    private var password: XCUIElement { app.secureTextFields["login.password"] }
    private var submit: XCUIElement { app.buttons["login.submit"] }
}
