# ValueScope（价值视界）实现计划

## 架构概览

```
┌─────────────────────────────────────────────────────────┐
│                    iOS App (SwiftUI)                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐  │
│  │ 行情看板  │  │ 估值分析  │  │ 选股策略  │  │ 自选股  │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───┬────┘  │
│       │              │              │             │       │
│  ┌────┴──────────────┴──────────────┴─────────────┴──┐   │
│  │              DataService Layer                      │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────┐  │   │
│  │  │ RealtimeAPI │  │ ValuationAPI │  │ LocalCache│  │   │
│  │  │(东方财富/Yahoo)│  │(GitHub Pages)│  │(SwiftData)│  │   │
│  │  └─────────────┘  └──────────────┘  └──────────┘  │   │
│  └────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                          │                    ▲
                          ▼                    │
┌─────────────────────────────────────────────────────────┐
│              GitHub Actions (定时任务)                     │
│  每日收盘后抓取 → PE/PB/ROE/股息率 → 存为 JSON            │
│  推送到 GitHub Pages 作为静态 API                         │
└─────────────────────────────────────────────────────────┘
```

## 技术选型

| 层级 | 技术 | 说明 |
|------|------|------|
| UI | SwiftUI + Swift Charts | iOS 17+，原生图表 |
| 数据持久化 | SwiftData | 自选股、缓存、设置 |
| 实时行情 | 东方财富 API (A股/港股) + Yahoo Finance (美股) | 免费无需 Key |
| 估值数据 | GitHub Actions 定时抓取 → GitHub Pages JSON | 每日更新 |
| 架构模式 | MVVM + Repository Pattern | 清晰分层 |
| 网络层 | async/await + URLSession | 原生方案 |
| 依赖管理 | Swift Package Manager | 无第三方依赖 |

## 数据源方案

### 实时行情（客户端直连）
- **A 股/港股**：东方财富 HTTP API（无需 Key，公开接口）
  - 实时报价：`http://push2.eastmoney.com/api/qt/stock/get`
  - K 线数据：`http://push2his.eastmoney.com/api/qt/stock/kline/get`
  - 搜索：`http://searchapi.eastmoney.com/api/suggest/get`
- **美股**：Yahoo Finance API（无需 Key）
  - 实时报价：`https://query1.finance.yahoo.com/v8/finance/chart/{symbol}`

### 估值数据（GitHub Actions 定时更新）
- GitHub Actions 每日收盘后运行 Python 脚本
- 抓取 PE/PB/ROE/股息率/市值等基本面数据
- 生成 JSON 文件推送到 GitHub Pages
- App 读取静态 JSON 作为估值数据源

## 实现步骤

### Phase 1: 项目骨架与数据层
1. 创建 Xcode 项目结构（SPM，SwiftUI App）
2. 定义核心 Model（Stock, Quote, Valuation, KLine）
3. 实现网络层（APIClient, 东方财富/Yahoo 适配器）
4. 实现 SwiftData 本地缓存层
5. 实现 Repository 层统一数据访问

### Phase 2: 核心视图
6. TabView 主框架（行情/估值/策略/自选）
7. 自选股列表（实时价格刷新）
8. 股票详情页（报价 + K 线图）
9. K 线图表（Swift Charts，支持日/周/月）
10. 搜索添加股票

### Phase 3: 估值分析
11. 估值仪表盘（PE/PB 百分位、历史对比）
12. 估值详情页（多指标雷达图）
13. GitHub Actions 数据抓取脚本
14. GitHub Pages 静态 JSON API

### Phase 4: 选股策略
15. 预设策略（低估值、高股息、高 ROE）
16. 自定义筛选条件
17. 策略回测简单展示

### Phase 5: 体验优化
18. Widget 小组件（自选股价格）
19. 价格提醒（本地通知）
20. 深色模式适配

## 文件结构

```
ValueScope/
├── ValueScopeApp.swift
├── Models/
│   ├── Stock.swift              # 股票基础模型
│   ├── Quote.swift              # 实时报价
│   ├── KLineData.swift          # K线数据
│   └── Valuation.swift          # 估值数据
├── Services/
│   ├── APIClient.swift          # 网络基础层
│   ├── EastMoneyAPI.swift       # 东方财富 API
│   ├── YahooFinanceAPI.swift    # Yahoo Finance API
│   ├── ValuationDataAPI.swift   # GitHub Pages 估值数据
│   └── StockRepository.swift    # 统一数据仓库
├── Storage/
│   ├── WatchlistStore.swift     # 自选股 SwiftData
│   └── CacheStore.swift         # 缓存管理
├── ViewModels/
│   ├── WatchlistViewModel.swift
│   ├── QuoteViewModel.swift
│   ├── KLineViewModel.swift
│   ├── ValuationViewModel.swift
│   └── StrategyViewModel.swift
├── Views/
│   ├── MainTabView.swift
│   ├── Watchlist/
│   │   ├── WatchlistView.swift
│   │   └── StockRowView.swift
│   ├── Quote/
│   │   ├── StockDetailView.swift
│   │   └── KLineChartView.swift
│   ├── Valuation/
│   │   ├── ValuationDashboard.swift
│   │   └── ValuationDetailView.swift
│   ├── Strategy/
│   │   ├── StrategyListView.swift
│   │   └── StrategyResultView.swift
│   └── Search/
│       └── StockSearchView.swift
├── Extensions/
│   └── Number+Format.swift
└── Resources/
    └── Assets.xcassets

.github/
└── workflows/
    └── fetch-valuation.yml      # 定时抓取估值数据

scripts/
└── fetch_valuation.py           # Python 抓取脚本

docs/                            # GitHub Pages 静态 JSON
├── valuation/
│   ├── a-share.json
│   ├── hk-share.json
│   └── us-share.json
└── index.html
```

## 关键设计决策

1. **零成本**：不使用任何付费服务，东方财富/Yahoo 公开 API + GitHub 免费额度
2. **离线优先**：SwiftData 缓存所有数据，无网络时展示缓存
3. **最小依赖**：不引入第三方库，全部使用 Apple 原生框架
4. **渐进实现**：Phase 1-2 为 MVP，后续逐步增强
