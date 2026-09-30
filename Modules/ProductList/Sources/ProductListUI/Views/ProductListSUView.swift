import ProductListPresentation
import SwiftUI

public struct ProductListSUView: View {
    private let viewModel: ProductListViewModel
    private let onSelect: (ProductRow) -> Void

    public init(
        viewModel: ProductListViewModel,
        onSelect: @escaping (ProductRow) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.onSelect = onSelect
    }

    public var body: some View {
        List {
            if let message = viewModel.errorMessage, viewModel.rows.isEmpty == false {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            ForEach(viewModel.rows) { row in
                Button {
                    onSelect(row)
                } label: {
                    HStack {
                        Text(row.name)
                        Spacer()
                        Text(row.salesCountText)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .overlay { placeholder }
        .navigationTitle(ProductListViewModel.screenTitle)
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder private var placeholder: some View {
        if viewModel.rows.isEmpty {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.errorMessage ?? ProductListViewModel.emptyMessage)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}
