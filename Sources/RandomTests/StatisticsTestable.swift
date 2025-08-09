import Random
import Testing

protocol StatisticsTestable {
    associatedtype Value: Hashable, Comparable

    var μ: Double { get }
    var σ²: Double { get }

    static var estimatedParameters: Int { get }

    func sample(using generator: inout PseudoRandom.Wyhash) -> Value
    func pdf(_ value: Value) -> Double

    func chiSquareBins(from samples: [Value], sampleCount: Int) -> [ChiSquareTest.Bin]
    func validate(actual: (μ: Double, σ²: Double), sampleCount: Int)
    func visualize(histogram: [Value: Int], sampleCount: Int)

    static func statistics(from samples: [Value]) -> (μ: Double, σ²: Double)
}
extension StatisticsTestable {
    func performStandardStatisticalTests(
        sampleCount: Int = 1_000_000,
        using random: inout PseudoRandom,
        visualize: Bool = false
    ) {
        print("Performing statistical tests for \(type(of: self))...")
        // 1. Generate samples
        let samples: [Value] = (0 ..< sampleCount).map { _ in
            self.sample(using: &random.generator)
        }

        print(
            """
                Generated \(samples.count) samples.
            """
        )
        // 2. Calculate statistics
        let actualStats: (μ: Double, σ²: Double) = Self.statistics(from: samples)

        // 3. Print Header
        print("\(type(of: self))(\(self)) Test:")
        print(
            """
                Expected: μ = \(self.μ), σ² = \(self.σ²)
            """
        )
        print(
            """
                Actual:   μ = \(actualStats.μ), σ² = \(actualStats.σ²)
            """
        )

        // 4. Check for errors
        self.validate(actual: actualStats, sampleCount: sampleCount)

        // 5. Perform Chi-Square Test
        let bins: [ChiSquareTest.Bin] = self.chiSquareBins(
            from: samples,
            sampleCount: sampleCount
        )
        let (chiSquare, df, pValue): (Double, Int, Double) = ChiSquareTest.perform(
            on: bins,
            estimatedParameters: Self.estimatedParameters
        )

        print(
            """
                Chi-square: \(chiSquare.decimal(places: 3)) \
                (df=\(df), p-value≈\(pValue.decimal(places: 3)))
            """
        )
        print(
            """
                Distribution fit: \(pValue > 0.05 ? "GOOD" : "NEEDS REVIEW")
            """
        )

        #expect(pValue > 0.05)

        // 6. Optional Visualization
        if visualize {
            let histogram: [Self.Value: Int] = samples.reduce(into: [:]) {
                $0[$1, default: 0] += 1
            }
            self.visualize(histogram: histogram, sampleCount: sampleCount)
        }
    }
}
