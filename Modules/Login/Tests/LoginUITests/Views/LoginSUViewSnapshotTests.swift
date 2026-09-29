#if canImport(UIKit)
import LoginFeature
import LoginPresentation
import SnapshotTesting
import SwiftUI
import TestSupport
import Testing

@testable import LoginUI

@MainActor
@Suite struct LoginSUViewSnapshotTests {

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func empty_matchesTheReference(style: UIUserInterfaceStyle) {
        let (view, _) = makeView()

        assert(view, style: style, testName: "empty")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func filled_matchesTheReference(style: UIUserInterfaceStyle) {
        let (view, viewModel) = makeView()
        viewModel.username = "tester"
        viewModel.password = "password"

        assert(view, style: style, testName: "filled")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func loading_matchesTheReference(style: UIUserInterfaceStyle) async {
        await withMainSerialExecutor {
            let gate = Gate()
            let (view, viewModel) = makeView(login: { _ in await gate.wait() })
            viewModel.username = "tester"
            viewModel.password = "password"

            let inFlight = Task { await viewModel.submit() }
            await Task.megaYield()

            assert(view, style: style, testName: "loading")
            gate.open()
            await inFlight.value
        }
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func error_matchesTheReference(style: UIUserInterfaceStyle) async {
        let serverMessage = "Invalid credentials."
        let (view, viewModel) = makeView(login: { _ in
            throw LoginUseCase.Error.invalidCredentials(message: serverMessage)
        })
        viewModel.username = "tester"
        viewModel.password = "password"

        await viewModel.submit()

        assert(view, style: style, testName: "error")
    }

    @Test(arguments: [UIUserInterfaceStyle.light, .dark])
    func sessionExpired_matchesTheReference(style: UIUserInterfaceStyle) {
        let (view, viewModel) = makeView()
        viewModel.showsSessionExpired = true

        assert(view, style: style, testName: "sessionExpired")
    }

    // MARK: - Helpers

    private func makeView(
        login: @escaping @Sendable (Credentials) async throws -> Void = { _ in }
    ) -> (view: AnyView, viewModel: LoginViewModel) {
        let viewModel = LoginViewModel(login: login)
        let view = AnyView(
            LoginSUView(viewModel: viewModel)
                .transaction { $0.animation = nil }
        )
        return (view, viewModel)
    }

    private func assert(_ view: some View, style: UIUserInterfaceStyle, testName: String) {
        assertSnapshot(
            of: view,
            as: .image(
                precision: 0.95,
                perceptualPrecision: 0.97,
                layout: .device(config: .iPhone17(style))
            ),
            named: style.snapshotName,
            record: SnapshotHost.isRecording ? .all : nil,
            testName: testName
        )
    }
}
#endif
