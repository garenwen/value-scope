import SwiftUI
import SwiftData

struct WatchlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WatchlistItem.sortOrder) private var items: [WatchlistItem]
    @State private var viewModel = WatchlistViewModel()
    @State private var showSearch = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && viewModel.quotes.isEmpty {
                    ProgressView("加载中...")
                        .frame(maxWidth: .infinity)
                } else if let error = viewModel.error {
                    Text(error).foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.quotes) { quote in
                        NavigationLink(value: quote.stock) {
                            StockRowView(quote: quote)
                        }
                    }
                    .onDelete(perform: deleteItems)
                    .onMove(perform: moveItems)
                }
            }
            .navigationTitle("自选股")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSearch = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showSearch) {
                StockSearchView()
            }
            .navigationDestination(for: Stock.self) { stock in
                StockDetailView(stock: stock)
            }
            .onAppear {
                viewModel.startAutoRefresh(items: items)
            }
            .onDisappear {
                viewModel.stopAutoRefresh()
            }
            .onChange(of: items.count) {
                viewModel.loadQuotes(items: items)
            }
            .refreshable {
                viewModel.loadQuotes(items: items)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        var sorted = items.sorted(by: { $0.sortOrder < $1.sortOrder })
        sorted.move(fromOffsets: source, toOffset: destination)
        for (i, item) in sorted.enumerated() {
            item.sortOrder = i
        }
    }
}
