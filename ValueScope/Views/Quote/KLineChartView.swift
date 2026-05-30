import SwiftUI
import Charts

struct KLineChartView: View {
    let data: [KLinePoint]
    let period: KLinePeriod

    var body: some View {
        if data.isEmpty {
            ContentUnavailableView("暂无数据", systemImage: "chart.xyaxis.line")
        } else {
            Chart(data) { point in
                // 蜡烛图：用 RectangleMark 表示实体
                RectangleMark(
                    x: .value("日期", point.date),
                    yStart: .value("开盘", point.open),
                    yEnd: .value("收盘", point.close),
                    width: 4
                )
                .foregroundStyle(point.isUp ? .red : .green)

                // 影线
                RuleMark(
                    x: .value("日期", point.date),
                    yStart: .value("最低", point.low),
                    yEnd: .value("最高", point.high)
                )
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(point.isUp ? .red : .green)
            }
            .chartYScale(domain: yDomain)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
        }
    }

    private var yDomain: ClosedRange<Double> {
        let lows = data.map(\.low)
        let highs = data.map(\.high)
        let minVal = (lows.min() ?? 0) * 0.98
        let maxVal = (highs.max() ?? 100) * 1.02
        return minVal...maxVal
    }
}
