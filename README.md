# ValueScope（价值视界）

免费、无服务器的 iOS 股票分析 App，支持 A股/港股/美股。

## 架构

```
客户端直连（实时行情）     GitHub Actions（每日估值）
  东方财富 API ──┐            ┌── Python 抓取脚本
  Yahoo Finance ─┤  iOS App   ├── GitHub Pages JSON
  SwiftData 缓存 ┘            └── 静态文件托管
```

## 功能

- **自选股看板**：实时行情、自动刷新、拖拽排序
- **K线图表**：日/周/月 K线，Swift Charts 原生渲染
- **估值分析**：PE/PB 百分位、ROE、股息率、估值等级
- **选股策略**：低估值、高股息、高ROE、成长型预设策略
- **价格提醒**：本地通知，目标价触发
- **Widget**：桌面小组件快速查看

## 数据源

| 市场 | 实时行情 | 估值数据 |
|------|---------|---------|
| A股（沪深） | 东方财富 API | GitHub Actions 每日抓取 |
| 港股 | 东方财富 API | GitHub Actions 每日抓取 |
| 美股 | Yahoo Finance | GitHub Actions 每日抓取 |

## 开始使用

1. 用 Xcode 15+ 打开项目
2. 选择 iOS 17+ 模拟器或真机
3. Build & Run

### 启用估值数据

1. Fork 本仓库
2. 在 Settings → Pages 中启用 GitHub Pages（source: `docs/`）
3. GitHub Actions 会每日自动更新估值数据
4. 修改 `ValuationDataAPI.swift` 中的 `baseURL` 为你的 Pages 地址

## 技术栈

- SwiftUI + Swift Charts（iOS 17+）
- SwiftData 本地持久化
- async/await 并发
- GitHub Actions + GitHub Pages
- 零第三方依赖

## 项目结构

```
ValueScope/
├── Models/          # 数据模型
├── Services/        # API 适配器、数据仓库
├── Storage/         # SwiftData 持久化
├── ViewModels/      # MVVM ViewModel
├── Views/           # SwiftUI 视图
├── Widget/          # 桌面小组件
└── Extensions/      # 工具扩展

.github/workflows/   # GitHub Actions 定时任务
scripts/             # Python 数据抓取脚本
docs/                # GitHub Pages 静态数据
```
