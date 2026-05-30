import SwiftUI

struct StockRowView: View {
    let quote: Quote

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(quote.stock.name)
                    .font(.headline)
                Text("\(quote.stock.market.name) \(quote.stock.symbol)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(quote.price.priceText)
                    .font(.headline)
                    .foregroundStyle(quote.isUp ? .red : .green)
                Text(quote.changePercent.percentText)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(quote.isUp ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                    .cornerRadius(4)
                    .foregroundStyle(quote.isUp ? .red : .green)
            }
        }
        .padding(.vertical, 4)
    }
}
