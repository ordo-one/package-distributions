import Random
import Testing

extension Binomial: StatisticsTestable {
    typealias Value = Int64

    var μ: Double { .init(self.n) * self.p }
    var σ²: Double { .init(self.n) * self.p * (1 - self.p) }

    static var estimatedParameters: Int { 0 }

    static func statistics(from samples: [Int64]) -> (μ: Double, σ²: Double) {
        let histogram: [Int64: Int] = samples.reduce(into: [:]) { $0[$1, default: 0] += 1 }

        let stats: (n: Int128, sum: Int128, sumSquares: Int128) = histogram.reduce(
            into: (0, 0, 0)
        ) {
            let occurrences: Int128 = .init($1.value)
            let value: Int128 = .init($1.key)
            $0.n += occurrences
            $0.sum += value * occurrences
            $0.sumSquares += value * value * occurrences
        }

        let n: Double = .init(stats.n)
        let sum: Double = .init(stats.sum)
        let sumSquared: Double = .init(stats.sum * stats.sum)
        let sumSquares: Double = .init(stats.sumSquares)

        return (μ: sum / n, σ²: (sumSquares - sumSquared / n) / (n - 1))
    }

    func chiSquareBins(from samples: [Int64], sampleCount: Int) -> [ChiSquareTest.Bin] {
        let histogram: [Int64: Int] = samples.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        let range: ClosedRange<Int64> = max(0, .init(self.μ - 4 * .sqrt(self.σ²)))
            ... min(self.n, .init(self.μ + 4 * .sqrt(self.σ²)))

        return range.map {
            .init(
                observed: histogram[$0, default: 0],
                expected: Double(sampleCount) * self.pdf($0)
            )
        }
    }

    func validate(actual: (μ: Double, σ²: Double), sampleCount: Int) {
        let error: (μ: Double, σ²: Double) = (
            μ: abs((actual.μ - self.μ) / self.μ),
            σ²: abs((actual.σ² - self.σ²) / self.σ²)
        )

        print(
            """
                Error:    μ = \(error.μ.percent), σ² = \(error.σ².percent)
            """
        )

        #expect(error.μ < 0.01)
        #expect(error.σ² < 0.01)
    }

    func visualize(histogram: [Int64: Int], sampleCount: Int) {
        let rangeMin: Int64 = max(0, .init(self.μ - 4 * .sqrt(self.σ²)))
        let rangeMax: Int64 = min(self.n, .init(self.μ + 4 * .sqrt(self.σ²)))

        HistogramVisualization.visualizeDiscreteHistogram(
            histogram: histogram,
            sampleCount: sampleCount,
            expectedProbability: { self.pdf($0) },
            valueRange: rangeMin...rangeMax
        )
    }
}
