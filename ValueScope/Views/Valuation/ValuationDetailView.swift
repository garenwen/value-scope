import SwiftUI
import Charts

struct ValuationDetailView: View {
    let valuation: Valuation

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 估值等级标签
                Text(valuation.valuationLevel.rawValue)
                    .font(.title2).bold()
                    .foregroundStyle(levelColor)

                // 核心指标卡片
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    MetricCard(title: "PE (市盈率)", value: valuation.pe?.priceText ?? "-",
                               percentile: valuation.pePercentile)
                    MetricCard(title: "PB (市净率)", value: valuation.pb?.priceText ?? "-",
                               percentile: valuation.pbPercentile)
                    MetricCard(title: "ROE", value: valuation.roe.map { "\($0.priceText)%" } ?? "-",
                               percentile: nil)
                    MetricCard(title: "股息率", value: valuation.dividendYield.map { "\($0.priceText)%" } ?? "-",
                               percentile: nil)
                }

                // PE 百分位图
                if let pePct = valuation.pePercentile {
                    PercentileBar(title: "PE 历史百分位", value: pePct)
                }
                if let pbPct = valuation.pbPercentile {
                    PercentileBar(title: "PB 历史百分位", value: pbPct)
                }

                // 市值
                if let cap = valuation.marketCap {
                    HStack {
                        Text("总市值").foregroundStyle(.secondary)
                        Spacer()
                        Text("\(cap.volumeText)亿")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle(valuation.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var levelColor: Color {
        switch valuation.valuationLevel {
        case .undervalued: .green
        case .normal: .orange
        case .overvalued: .red
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let percentile: Double?

    var body: some View {
        VStack(spacing: 8) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.title3).bold()
            if let pct = percentile {
                Text("百分位 \(Int(pct))%")
                    .font(.caption2)
                    .foregroundStyle(pct < 30 ? .green : pct > 70 ? .red : .orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PercentileBar: View {
    let title: String
    let value: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.subheadline)
                Spacer()
                Text("\(Int(value))%").font(.subheadline).bold()
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(width: geo.size.width * value / 100)
                }
            }
            .frame(height: 8)
            HStack {
                Text("低估").font(.caption2).foregroundStyle(.green)
                Spacer()
                Text("高估").font(.caption2).foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private var barColor: Color {
        if value < 30 { return .green }
        if value > 70 { return .red }
        return .orange
    }
}
