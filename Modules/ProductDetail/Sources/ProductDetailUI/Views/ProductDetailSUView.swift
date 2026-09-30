import ProductDetailPresentation
import SwiftUI

public struct ProductDetailSUView: View {
    private let viewModel: ProductDetailViewModel

    public init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            if let message = viewModel.errorMessage, viewModel.viewData != nil {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let viewData = viewModel.viewData {
                Section {
                    ForEach(viewData.rows) { row in
                        SaleRowView(row: row)
                    }
                } header: {
                    Text(viewData.summaryText)
                        .font(.subheadline)
                        .textCase(nil)
                }
            }
        }
        .overlay { placeholder }
        .navigationTitle(viewModel.viewData?.title ?? "")
        .task { await viewModel.load() }
    }

    @ViewBuilder private var placeholder: some View {
        if viewModel.viewData == nil {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.errorMessage ?? ProductDetailViewModel.emptyMessage)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
}

private struct SaleRowView: View {
    let row: SaleRow

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(row.amountText)
                    .font(.headline)
                Spacer()
                Text(row.convertedText)
                    .foregroundStyle(.secondary)
            }
            Text(row.dateText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
