import LoginPresentation
import SwiftUI

public struct LoginSUView: View {
    @Bindable private var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text(LoginViewModel.title)
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 24)
            TextField(LoginViewModel.usernamePlaceholder, text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .loginFieldCapitalization()
                .accessibilityIdentifier("login.username")
            SecureField(LoginViewModel.passwordPlaceholder, text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("login.password")
            if viewModel.showsSessionExpired {
                Text(LoginViewModel.sessionExpiredMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("login.sessionExpired")
            }
            if let message = viewModel.errorMessage {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .accessibilityIdentifier("login.error")
            }
            Button {
                Task { await viewModel.submit() }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(LoginViewModel.submitButtonTitle)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSubmit || viewModel.isLoading)
            .accessibilityIdentifier("login.submit")
            Spacer()
        }
        .padding()
    }
}

extension View {
    fileprivate func loginFieldCapitalization() -> some View {
        #if os(iOS)
        return textInputAutocapitalization(.never)
        #else
        return self
        #endif
    }
}
