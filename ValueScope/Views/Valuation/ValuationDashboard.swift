import SwiftUI
import Charts

struct ValuationDashboard: View {
    @State private var viewModel = ValuationViewModel()

    var body: some View {
        NavigationStack {
            List {
                // 市场选择
                Picker("市场", selection: $viewModel.selectedMarket) {
                    Text("A股").tag(Market.sh)
                    Text("港股").tag(Market.hk)
                    Text("美股").tag(Market.us)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
                .onChange(of: viewModel.selectedMarket) { _, _ in
                    viewModel.load()
                }

                if viewModel.isLoading {
                    ProgressView().frame(maxWidth: .infinity)
                } else if let error = viewModel.error {
                    Text(error).foregroundStyle(.secondary)
                } else {
                    // 估值概览
                    Section("低估值 (\(viewModel.undervalued.count))") {
                        ForEach(viewModel.undervalued.prefix(10)) { v in
                            NavigationLink(value: v) {
                                ValuationRowView(valuation: v)
                            }
                        }
                    }

                    Section("高估值 (\(viewModel.overvalued.count))") {
                        ForEach(viewModel.overvalued.prefix(10)) { v in
                            NavigationLink(value: v) {
                                ValuationRowView(valuation: v)
                            }
                        }
                    }
                }
            }
            .navigationTitle("估值分析")
            .navigationDestination(for: Valuation.self) { v in
                ValuationDetailView(valuation: v)
            }
            .onAppear { viewModel.load() }
        }
    }
}

struct ValuationRowView: View {
    let valuation: Valuation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(valuation.name).font(.headline)
                Text(valuation.symbol).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("PE \(valuation.pe?.priceText ?? "-")")
                    .font(.subheadline)
                Text(valuation.valuationLevel.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(levelColor.opacity(0.15))
                    .foregroundStyle(levelColor)
                    .cornerRadius(4)
            }
        }
    }

    private var levelColor: Color {
        switch valuation.valuationLevel {
        case .undervalued: .green
        case .normal: .orange
        case .overvalued: .red
        }
    }
}
