import Foundation

extension Double {
    /// 格式化为价格字符串
    var priceText: String {
        String(format: "%.2f", self)
    }

    /// 格式化为百分比
    var percentText: String {
        String(format: "%+.2f%%", self)
    }

    /// 格式化为成交量（万/亿）
    var volumeText: String {
        if self >= 1_0000_0000 {
            return String(format: "%.2f亿", self / 1_0000_0000)
        } else if self >= 1_0000 {
            return String(format: "%.2f万", self / 1_0000)
        }
        return String(format: "%.0f", self)
    }
}
