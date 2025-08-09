import Random
import Testing

@Suite
struct NormalTests {
    private var random: PseudoRandom

    init() {
        self.random = .init(seed: 4)
    }
}

extension NormalTests {
    @Test(arguments: [
        (μ: 0, σ: 1),
        (μ: 5, σ: 2),
        (μ: 10, σ: 2),
        (μ: -5, σ: 3),
        (μ: 100, σ: 10),
        (μ: 0, σ: 0.1),
    ])
    mutating func Statistics2(_ μ: Double, _ σ: Double) {
        Normal[μ, σ].performStandardStatisticalTests(using: &self.random, visualize: true)
    }

    @Test(arguments: [
        (μ: 0, σ: 0.001),   // Very small variance
        (μ: 1e6, σ: 1e3),     // Very large mean
        (μ: -1e6, σ: 1e3),    // Very negative mean
        (μ: 0, σ: 0),     // Zero variance
    ])
    mutating func ExtremeValues(_ μ: Double, _ σ: Double) {
        Normal[μ, σ].performStandardStatisticalTests(using: &self.random, visualize: false)
    }
}
