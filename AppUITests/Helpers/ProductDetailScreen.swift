import XCTest

@MainActor
struct ProductDetailScreen {
    let app: XCUIApplication

    var isShowingSummary: Bool { app.staticTexts["productDetail.summary"].appears() }
    var isShowingPlaceholder: Bool { app.staticTexts["productDetail.placeholder"].appears() }

    func isShowingTitle(_ title: String) -> Bool {
        app.navigationBars[title].appears()
    }
}
