import Benchmark
import Random

let benchmarks: @Sendable () -> Void = {
    // MARK: - PseudoRandom Generator Benchmarks

    Benchmark("PseudoRandom.int64") { benchmark in
        var random = PseudoRandom(seed: 42)
        for _ in benchmark.scaledIterations {
            blackHole(random.int64())
        }
    }

    Benchmark("PseudoRandom.int64(in: Range)") { benchmark in
        var random = PseudoRandom(seed: 42)
        for _ in benchmark.scaledIterations {
            blackHole(random.int64(in: 0..<1000))
        }
    }

    Benchmark("PseudoRandom.roll") { benchmark in
        var random = PseudoRandom(seed: 42)
        for _ in benchmark.scaledIterations {
            blackHole(random.roll(3, 6))  // 3d6 roll
        }
    }

    // MARK: - Normal Distribution Benchmarks

    Benchmark("Normal.sample - Standard (μ=0, σ=1)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Normal[0, 1]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Normal.sample - Custom (μ=100, σ=15)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Normal[100, 15]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Normal.pdf") { benchmark in
        let distribution = Normal[0, 1]
        var x = -3.0
        for _ in benchmark.scaledIterations {
            blackHole(distribution.pdf(x))
            x += 0.01
            if x > 3.0 { x = -3.0 }
        }
    }

    Benchmark("Normal.cdf") { benchmark in
        let distribution = Normal[0, 1]
        var x = -3.0
        for _ in benchmark.scaledIterations {
            blackHole(distribution.cdf(x))
            x += 0.01
            if x > 3.0 { x = -3.0 }
        }
    }

    Benchmark("Normal.cdfInverse") { benchmark in
        let distribution = Normal[0, 1]
        var p = 0.001
        for _ in benchmark.scaledIterations {
            blackHole(distribution.cdfInverse(p))
            p += 0.001
            if p > 0.999 { p = 0.001 }
        }
    }

    // MARK: - Binomial Distribution Benchmarks

    Benchmark("Binomial.sample - Small (n=10, p=0.5)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[10, 0.5]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Binomial.sample - Medium (n=100, p=0.3)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[100, 0.3]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Binomial.sample - Large (n=10000, p=0.5)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[10000, 0.5]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Binomial.sample - Very Large (n=1000000, p=0.2)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[1_000_000, 0.2]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Binomial.sample - Edge case (p≈0)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[1000, 0.001]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Binomial.sample - Edge case (p≈1)") { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[1000, 0.999]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark("Binomial.pdf - Small n") { benchmark in
        let distribution = Binomial[20, 0.5]
        for k in benchmark.scaledIterations {
            blackHole(distribution.pdf(Int64(k % 21)))
        }
    }

    Benchmark("Binomial.pdf - Large n") { benchmark in
        let distribution = Binomial[1000, 0.3]
        for k in benchmark.scaledIterations {
            blackHole(distribution.pdf(Int64(k % 1001)))
        }
    }

    // MARK: - Comparative Benchmarks

    Benchmark(
        "Generate 1000 Normal samples",
        configuration: .init(scalingFactor: .kilo)
    ) { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Normal[0, 1]
        for _ in benchmark.scaledIterations {
            for _ in 0..<1000 {
                blackHole(distribution.sample(using: &random.generator))
            }
        }
    }

    Benchmark(
        "Generate 1000 Binomial samples (n=50)",
        configuration: .init(scalingFactor: .kilo)
    ) { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[50, 0.5]
        for _ in benchmark.scaledIterations {
            for _ in 0..<1000 {
                blackHole(distribution.sample(using: &random.generator))
            }
        }
    }

    // MARK: - Memory and Threading Benchmarks

    Benchmark(
        "Normal sampling with memory tracking",
        configuration: .init(metrics: [.wallClock, .throughput, .mallocCountTotal])
    ) { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Normal[0, 1]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    Benchmark(
        "Binomial sampling with memory tracking",
        configuration: .init(metrics: [.wallClock, .throughput, .mallocCountTotal])
    ) { benchmark in
        var random = PseudoRandom(seed: 42)
        let distribution = Binomial[100, 0.5]
        for _ in benchmark.scaledIterations {
            blackHole(distribution.sample(using: &random.generator))
        }
    }

    // MARK: - Concurrent Sampling Benchmarks

    Benchmark(
        "Concurrent Normal sampling",
        configuration: .init(metrics: [.wallClock, .cpuTotal, .throughput])
    ) { benchmark in
        benchmark.startMeasurement()
        Task {
            await withTaskGroup(of: Void.self) { taskGroup in
                for _ in 0..<10 {
                    taskGroup.addTask {
                        var random = PseudoRandom(seed: UInt64.random(in: 0...UInt64.max))
                        let distribution = Normal[0, 1]
                        for _ in 0..<100 {
                            blackHole(distribution.sample(using: &random.generator))
                        }
                    }
                }
            }
        }
        benchmark.stopMeasurement()
    }
}
