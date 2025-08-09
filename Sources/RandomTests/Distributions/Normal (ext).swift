import Random
import Testing

extension Normal: StatisticsTestable {
    typealias Value = Double

    // MARK: Protocol Requirements

    var σ²: Double { self.σ * self.σ }

    static var estimatedParameters: Int { 2 }

    static func statistics(from samples: [Double]) -> (μ: Double, σ²: Double) {
        let n: Double = .init(samples.count)
        let stats: (sum: Double, sumSquares: Double) = samples.reduce(into: (0, 0)) {
            $0.sum += $1
            $0.sumSquares += $1 * $1
        }
        let mean: Double = stats.sum / n
        let variance: Double = (stats.sumSquares - (stats.sum * stats.sum) / n) / (n - 1)
        return (μ: mean, σ²: variance)
    }

    func chiSquareBins(from samples: [Double], sampleCount: Int) -> [ChiSquareTest.Bin] {
        if self.σ <= 0 { return [] }

        let chiSquareBins: Int = 20
        let testRange: (min: Double, max: Double) = (min: self.μ - 4 * self.σ, max: self.μ + 4 * self.σ)
        let binWidth: Double = (testRange.max - testRange.min) / Double.init(chiSquareBins)

        var observedCounts: [Int] = .init(repeating: 0, count: chiSquareBins)
        for sample: Double in samples {
            if sample >= testRange.min, sample < testRange.max {
                let binIndex: Int = .init((sample - testRange.min) / binWidth)
                if binIndex >= 0, binIndex < chiSquareBins {
                    observedCounts[binIndex] += 1
                }
            }
        }

        return (0 ..< chiSquareBins).map {
            let binMin: Double = testRange.min + Double.init($0) * binWidth
            let binMax: Double = binMin + binWidth
            let expectedProbability: Double = self.cdf(binMax) - self.cdf(binMin)
            return .init(observed: observedCounts[$0], expected: Double.init(sampleCount) * expectedProbability)
        }
    }

    func validate(actual: (μ: Double, σ²: Double), sampleCount: Int) {
        let meanStandardError: Double = self.σ / .sqrt(.init(sampleCount))
        let error: (z: Double, σ²: Double) = (
            z: self.σ > 0 ? abs((actual.μ - self.μ) / meanStandardError) : 0,
            σ²: self.σ² > 0 ? abs((actual.σ² - self.σ²) / self.σ²) : abs(actual.σ²)
        )

        print(
            """
                Error:    z = \(error.z.decimal()) σ, σ² = \(error.σ².percent)
            """
        )

        #expect(error.z < 3.0)
        #expect(error.σ² < 0.05)
    }

    func visualize(histogram: [Double: Int], sampleCount: Int) {
        let bins: Int = 40

        let valueRange: (min: Double, max: Double) = histogram.keys.reduce(
            into: (.infinity, -.infinity)
        ) {
            $0.min = min($0.min, $1)
            $0.max = max($0.max, $1)
        }

        guard valueRange.max > valueRange.min else {
            print("No valid range for histogram visualization.")
            return
        }

        let binWidth: Double = (valueRange.max - valueRange.min) / .init(bins)

        var binnedHistogram: [(midpoint: Double, count: Int)] = (0..<bins).map { i in
            let midpoint: Double = valueRange.min + (Double(i) + 0.5) * binWidth
            return (midpoint: midpoint, count: 0)
        }

        // Populate the counts for the bins
        for (sample, count): (Double, Int) in histogram {
            let i: Int = min(bins - 1, max(0, .init((sample - valueRange.min) / binWidth)))
            binnedHistogram[i].count += count
        }

        // Now, visualize the correctly binned data
        HistogramVisualization.visualizeContinuousHistogram(
            histogram: binnedHistogram,
            sampleCount: sampleCount,
            expectedDensity: { self.pdf($0) },
            binWidth: binWidth
        )
    }
}
