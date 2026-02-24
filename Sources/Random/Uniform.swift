import RealModule

/// Uniform distribution implementation with stochastic rounding.
@frozen public struct Uniform {
    public let n: Int64
    public let p: Double

    @inlinable init(n: Int64, p: Double) {
        self.n = n
        self.p = p
    }
}
extension Uniform {
    /// Create a uniform distribution with the given parameters. Using values of ``p`` greater
    /// than 0.5 is not recommended, as it could distort the mean of the distribution.
    @inlinable public static subscript(n: Int64, p: Double) -> Self { .init(n: n, p: p) }
}
extension Uniform {
    @inlinable public func sample(using generator: inout some RandomNumberGenerator) -> Int64 {
        let n: Double = .init(self.n)
        let x: Double = .random(in: 0 ... 2 * n * self.p, using: &generator)
        let i: Int64 = .init(x)
        let f: Double = x - Double.init(i)
        let r: Int64 = Double.random(in: 0 ..< 1, using: &generator) < f ? 1 : 0
        return min(self.n, i + r)
    }
}
