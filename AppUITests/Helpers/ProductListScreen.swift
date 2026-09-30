import XCTest

@MainActor
struct ProductListScreen {
    let app: XCUIApplication

    var isShowing: Bool { firstProduct.appears() }
    var isShowingPlaceholder: Bool { app.staticTexts["productList.placeholder"].appears() }
    var productCount: Int { app.buttons.matching(identifier: "productList.row").count }

    func openFirstProduct() -> String {
        XCTAssertTrue(firstProduct.appears(), "expected at least one product row to open")
        let name = firstProduct.label
        firstProduct.tap()
        return name
    }

    private var firstProduct: XCUIElement {
        app.buttons.matching(identifier: "productList.row").firstMatch
    }
}
