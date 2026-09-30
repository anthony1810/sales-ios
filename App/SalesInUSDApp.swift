import SwiftUI

@main
struct SalesInUSDApp: App {
    @State private var composition = AppComposition.launch()

    var body: some Scene {
        WindowGroup {
            RootView(composition: composition)
        }
    }
}
