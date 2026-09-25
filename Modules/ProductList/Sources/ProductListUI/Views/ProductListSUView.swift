import ProductListPresentation
import SwiftUI

public struct ProductListSUView: View {
    private let viewModel: ProductListViewModel

    public init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List(viewModel.rows) { row in
            HStack {
                Text(row.name)
                Spacer()
                Text(row.salesCountText)
                    .foregroundStyle(.secondary)
            }
        }
        .overlay { emptyState }
        .overlay { errorState }
        .navigationTitle(ProductListViewModel.screenTitle)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder private var emptyState: some View {
        if viewModel.rows.isEmpty, viewModel.errorMessage == nil, viewModel.isLoading == false {
            Text(ProductListViewModel.emptyMessage)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder private var errorState: some View {
        if let message = viewModel.errorMessage {
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}
