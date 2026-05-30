import SwiftUI
import SwiftData

struct StockSearchView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var watchlist: [WatchlistItem]
    @State private var keyword = ""
    @State private var results: [Stock] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            List(results) { stock in
                HStack {
                    VStack(alignment: .leading) {
                        Text(stock.name).font(.headline)
                        Text("\(stock.market.name) \(stock.symbol)")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if isInWatchlist(stock) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button("添加") { addToWatchlist(stock) }
                            .buttonStyle(.bordered)
                    }
                }
            }
            .searchable(text: $keyword, prompt: "输入股票代码或名称")
            .onChange(of: keyword) { _, newValue in
                search(newValue)
            }
            .navigationTitle("搜索股票")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
            .overlay {
                if isSearching {
                    ProgressView()
                } else if results.isEmpty && !keyword.isEmpty {
                    ContentUnavailableView.search(text: keyword)
                }
            }
        }
    }

    private func search(_ text: String) {
        guard text.count >= 1 else { results = []; return }
        isSearching = true
        Task {
            results = (try? await StockRepository.shared.search(keyword: text)) ?? []
            isSearching = false
        }
    }

    private func isInWatchlist(_ stock: Stock) -> Bool {
        watchlist.contains { $0.symbol == stock.symbol && $0.marketRaw == stock.market.rawValue }
    }

    private func addToWatchlist(_ stock: Stock) {
        let item = WatchlistItem(stock: stock, sortOrder: watchlist.count)
        modelContext.insert(item)
    }
}
