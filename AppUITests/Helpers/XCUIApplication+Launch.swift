import XCTest

@MainActor
extension XCUIApplication {
    enum Connectivity {
        case online
        case offline
    }

    enum Session {
        case signedOut
        case kept
    }

    static func launch(_ connectivity: Connectivity, session: Session) -> XCUIApplication {
        let app = XCUIApplication()
        if session == .signedOut {
            app.launchArguments += ["-reset"]
        }
        if connectivity == .offline {
            app.launchArguments += ["-connectivity", "offline"]
        }
        app.launch()
        return app
    }

    var loginScreen: LoginScreen { LoginScreen(app: self) }
    var productListScreen: ProductListScreen { ProductListScreen(app: self) }
    var productDetailScreen: ProductDetailScreen { ProductDetailScreen(app: self) }
}

@MainActor
extension XCUIElement {
    static let appearanceTimeout: TimeInterval = 20

    func appears() -> Bool {
        waitForExistence(timeout: Self.appearanceTimeout)
    }

    func disappears() -> Bool {
        let gone = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: gone, object: self)
        return XCTWaiter().wait(for: [expectation], timeout: Self.appearanceTimeout) == .completed
    }
}

@MainActor
extension XCTestCase {
    func requireLiveBackend() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["END_TO_END"] == "1",
            "Set END_TO_END=1 to run against the real backend"
        )
    }
}
