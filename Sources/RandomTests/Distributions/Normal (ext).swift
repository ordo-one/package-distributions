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

        // Use the THEORETICAL range for consistent binning
        let range: Range<Double> = self.μ - 4 * self.σ ..< self.μ + 4 * self.σ
        let binWidth: Double = (range.upperBound - range.lowerBound) / .init(bins)

        var histogram: [(midpoint: Double, count: Int)] = (0 ..< bins).map {
            (
                midpoint: range.lowerBound + (Double.init($0) + 0.5) * binWidth,
                count: 0
            )
        }

        // Populate the counts for the bins using the actual samples
        for (sample, count): (Double, Int) in histogram {
            if range ~= sample {
                let i: Int = Int.init((sample - range.lowerBound) / binWidth)
                histogram[max(0, min(i, bins - 1))].count += count
            }
        }

        // Pre-calculate ACCURATE expected probabilities using CDF
        let expectedProbabilities: [Double] = (0 ..< bins).map {
            let binMin: Double = range.lowerBound + Double.init($0) * binWidth
            let binMax: Double = binMin + binWidth
            // Use CDF difference for exact probability
            return self.cdf(binMax) - self.cdf(binMin)
        }

        // Visualize with accurate expected probabilities
        HistogramVisualization.visualizeContinuousHistogram(
            histogram: histogram,
            sampleCount: sampleCount,
            expectedProbabilities: expectedProbabilities
        )
    }
}
