import Random
import Testing

@Suite struct BinomialTests {
    private var random: PseudoRandom

    init() {
        self.random = .init(seed: 3)
    }
}
extension BinomialTests {
    @Test(
        arguments: [
            (n: 10, p: 0.5),
            (n: 20, p: 0.5),
            (n: 50, p: 0.5),
            (n: 100, p: 0.5),
            (n: 200, p: 0.5),
            (n: 500, p: 0.5),
            (n: 500, p: 0.1),
            (n: 500, p: 0.01),
            (n: 5_000, p: 0.01),
            (n: 50_000, p: 0.001),
        ]
    ) mutating func Statistics(_ n: Int64, _ p: Double) {
        Binomial[n, p].performStandardStatisticalTests(
            sampleCount: 2_000_000,
            using: &self.random,
            visualize: true
        )
    }

    @Test(
        arguments: [
            (n: 1_000, p: 0.01),
            (n: 10_000, p: 0.01),
            (n: 100_000, p: 0.01),
            (n: 1_000_000, p: 0.01),
            (n: 10_000_000, p: 0.01),
            (n: 100_000_000, p: 0.01),
        ]
    ) mutating func LoyaltyE2(_ n: Int64, _ p: Double) {
        Binomial[n, p].performStandardStatisticalTests(
            sampleCount: 1_000_000,
            using: &self.random,
            visualize: Double.init(n) * p < 1_000
        )
    }
    @Test(
        arguments: [
            (n: 1_000, p: 0.001),
            (n: 10_000, p: 0.001),
            (n: 100_000, p: 0.001),
            (n: 1_000_000, p: 0.001),
            (n: 10_000_000, p: 0.001),
            (n: 100_000_000, p: 0.001),
        ]
    ) mutating func LoyaltyE3(_ n: Int64, _ p: Double) {
        Binomial[n, p].performStandardStatisticalTests(
            sampleCount: 1_000_000,
            using: &self.random,
            visualize: Double.init(n) * p < 1_000
        )
    }

    @Test(
        arguments: [
            (n: 1_000_000, p: 0.0001),    // Very large n, very small p
            (n: 10_000_000, p: 0.00001),  // Extremely large n, extremely small p
            (n: 100_000, p: 0.9999),      // Large n, p close to 1
            (n: 5_000_000, p: 0.5),       // Very large n, balanced p
        ]
    ) mutating func ExtremeValues(_ n: Int64, _ p: Double) {
        Binomial[n, p].performStandardStatisticalTests(
            sampleCount: 1_000_000,
            using: &self.random,
            visualize: false
        )
    }
}
