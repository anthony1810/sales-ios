import SwiftUI

@main
struct SalesInUSDApp: App {
    @State private var composition = AppComposition()

    var body: some Scene {
        WindowGroup {
            RootView(composition: composition)
        }
    }
}
