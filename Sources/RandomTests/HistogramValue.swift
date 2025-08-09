/// Protocol for values that can be displayed in a histogram
protocol HistogramValue: Comparable {
    /// Format the value as a string for display
    func formattedString(width: Int) -> String
}

// Extend Double to conform to HistogramValue
extension HistogramValue where Self == Double {
    func formattedString(width: Int) -> String {
        self.decimal(places: 2).padding(left: width)
    }
}

extension Double: HistogramValue {}

// Extend Int64 to conform to HistogramValue
extension Int64: HistogramValue {
    func formattedString(width: Int) -> String {
        "\(self)".padding(right: width)
    }
}
