import SwiftUI

struct StrategyListView: View {
    @State private var viewModel = StrategyViewModel()

    var body: some View {
        NavigationStack {
            List {
                // 策略选择
                Section("选择策略") {
                    ForEach(Strategy.allCases) { strategy in
                        Button {
                            viewModel.selectedStrategy = strategy
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(strategy.rawValue).font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(strategy.description).font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if viewModel.selectedStrategy == strategy {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // 筛选结果
                Section("筛选结果 (\(viewModel.results.count))") {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.results.isEmpty {
                        Text("暂无符合条件的股票").foregroundStyle(.secondary)
                    } else {
                        ForEach(viewModel.results.prefix(50)) { v in
                            StrategyResultRow(valuation: v)
                        }
                    }
                }
            }
            .navigationTitle("选股策略")
            .onAppear { viewModel.load() }
        }
    }
}

struct StrategyResultRow: View {
    let valuation: Valuation

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(valuation.name).font(.headline)
                Text("\(valuation.market) \(valuation.symbol)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                if let pe = valuation.pe {
                    Text("PE \(pe.priceText)").font(.caption)
                }
                if let roe = valuation.roe {
                    Text("ROE \(roe.priceText)%").font(.caption)
                }
                if let dy = valuation.dividendYield {
                    Text("股息 \(dy.priceText)%").font(.caption).foregroundStyle(.blue)
                }
            }
        }
    }
}
