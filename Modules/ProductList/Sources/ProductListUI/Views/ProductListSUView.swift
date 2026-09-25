import ProductListPresentation
import SwiftUI

public struct ProductListSUView: View {
    private let viewModel: ProductListViewModel

    public init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            if let message = viewModel.errorMessage, viewModel.rows.isEmpty == false {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(viewModel.rows) { row in
                HStack {
                    Text(row.name)
                    Spacer()
                    Text(row.salesCountText)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay { placeholder }
        .navigationTitle(ProductListViewModel.screenTitle)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder private var placeholder: some View {
        if viewModel.rows.isEmpty, viewModel.isLoading == false {
            Text(viewModel.errorMessage ?? ProductListViewModel.emptyMessage)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}
