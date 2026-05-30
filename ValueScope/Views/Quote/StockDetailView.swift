import SwiftUI
import Charts

struct StockDetailView: View {
    let stock: Stock
    @State private var viewModel = QuoteViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 报价头部
                if let quote = viewModel.quote {
                    QuoteHeaderView(quote: quote)
                }

                // K线图
                KLineChartView(data: viewModel.klineData, period: viewModel.selectedPeriod)
                    .frame(height: 300)

                // 周期选择
                Picker("周期", selection: $viewModel.selectedPeriod) {
                    ForEach(KLinePeriod.allCases, id: \.self) { period in
                        Text(period.label).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: viewModel.selectedPeriod) { _, newValue in
                    viewModel.changePeriod(newValue, stock: stock)
                }

                // 详细数据
                if let quote = viewModel.quote {
                    QuoteDetailGrid(quote: quote)
                }
            }
            .padding()
        }
        .navigationTitle(stock.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.load(stock: stock) }
    }
}

struct QuoteHeaderView: View {
    let quote: Quote

    var body: some View {
        VStack(spacing: 8) {
            Text(quote.price.priceText)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(quote.isUp ? .red : .green)
            HStack(spacing: 16) {
                Text(quote.change.priceText)
                Text(quote.changePercent.percentText)
            }
            .font(.headline)
            .foregroundStyle(quote.isUp ? .red : .green)
        }
    }
}

struct QuoteDetailGrid: View {
    let quote: Quote

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            DetailCell(title: "今开", value: quote.open.priceText)
            DetailCell(title: "最高", value: quote.high.priceText)
            DetailCell(title: "最低", value: quote.low.priceText)
            DetailCell(title: "成交量", value: quote.volume.volumeText)
            DetailCell(title: "成交额", value: quote.amount.volumeText)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DetailCell: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline).bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
