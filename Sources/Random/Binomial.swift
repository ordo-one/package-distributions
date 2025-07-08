import RealModule

/// Binomial distribution implementation with optimizations for large n values
@frozen public struct Binomial {
    private static var iterations: Int { 200 }

    /// TODO: fine tune
    @inlinable static var normalApproximationThreshold: Double { 1_000_000 }

    public let n: Int64
    public let p: Double

    @inlinable init(n: Int64, p: Double) {
        self.n = n
        self.p = p
    }
}
extension Binomial {
    @inlinable public static subscript(n: Int64, p: Double) -> Self { .init(n: n, p: p) }
}
extension Binomial {
    @inlinable public func sample(using generator: inout some RandomNumberGenerator) -> Int64 {
        self.sample { .random(in: 0 ... 1, using: &generator) }
    }

    /// Sample from a binomial distribution using inverse transform sampling.
    @inlinable public func sample(U: () -> Double) -> Int64 {
        if self.p <= 0 { return 0 }
        if self.p >= 1 { return self.n }

        let q: Double = 1 - self.p
        let u: Double = U()

        // B(n, p) = n – B(n, 1 – p)
        return self.p < 0.5
            ?          Self.cdfInverse(u: u, n: self.n, p: self.p, q: q)
            : self.n - Self.cdfInverse(u: u, n: self.n, p: q, q: self.p)
    }

    // Theoretical binomial probability.
    @inlinable public func pdf(_ k: Int64) -> Double {
        let l: Double = .init(self.n - k)
        let n: Double = .init(self.n)
        let k: Double = .init(k)
        let q: Double = 1 - self.p
        let nCk: Double = .exp(
            Double.logGamma(n + 1) -
            Double.logGamma(k + 1) -
            Double.logGamma(l + 1)
        )
        return nCk * Double.pow(p, k) * Double.pow(q, l)
    }
}
extension Binomial {
    /// Find the binomial value using binary search on the CDF
    /// For large n, uses direct normal approximation for significant performance improvement
    @usableFromInline static func cdfInverse(
        u: Double,
        n: Int64,
        p: Double,
        q: Double
    ) -> Int64 {
        let n: (i: Int64, f: Double) = (n, Double.init(n))

        // Fast path for extreme cases
        if u <=     Double.pow(q, n.f) { return 0 }
        if u >= 1 - Double.pow(p, n.f) { return n.i }

        // Get approximate starting point using normal approximation
        let μ: Double = n.f * p
        let σ: Double = Double.sqrt(μ * q)

        // Use quantile function of normal distribution
        let z: Double = Normal.cdfInverse(u)
        let guess: Int64 = min(max(0, Int64.init((μ + z * σ).rounded())), n.i)

        // For very large n, if n*p*q > threshold, we can use the normal approximation directly
        // This is a significant optimization for large n values!
        if μ * q > Self.normalApproximationThreshold {
            return guess
        }

        // For smaller n, continue with binary search for greater accuracy
        // Start with our initial guess from normal approximation
        var y: Double = Self.cdf(n: n.i, k: guess, p: p, q: q)
        if abs(y - u) < 1e-10 {
            return guess
        }

        // Binary search
        var bound: (min: Int64, max: Int64) = u < y ? (0, guess) : (guess, n.i)

        // Actual binary search
        while bound.min + 1 < bound.max {
            let guess: Int64 = (bound.min + bound.max) / 2

            y = Self.cdf(n: n.i, k: guess, p: p, q: q)

            if  u <= y {
                bound.max = guess
            } else {
                bound.min = guess
            }
        }

        // Final check
        y = Self.cdf(n: n.i, k: bound.min, p: p, q: q)
        return u <= y ? bound.min : bound.max
    }

    /// Calculate the CDF of a binomial distribution
    /// Uses the relationship with the incomplete beta function
    private static func cdf(n: Int64, k: Int64, p: Double, q: Double) -> Double {
        if k < 0 { return 0 }
        if k >= n { return 1 }

        // The binomial CDF is related to the incomplete beta function:
        // CDF(k; n, p) = I_{1-p}(n-k, k+1)
        // where I_x(a,b) is the regularized incomplete beta function

        // We know `k + 1` will never overflow, because it is less than `n`.
        return Self.I(a: Double.init(n - k), b: Double.init(k + 1), p: p, q: q)
    }

    /// Compute the regularized incomplete beta function
    private static func I(a: Double, b: Double, p: Double, q: Double) -> Double {
        // Use continued fraction representation for numerical stability
        // First calculate the factor x^a * (1-x)^b / (a*Beta(a,b))
        let bt: Double = Double.exp(
            Double.logGamma(a + b) -
            Double.logGamma(a) -
            Double.logGamma(b) +
            Double.log(q) * a +
            Double.log(p) * b
        )

        if q < (a + 1.0) / (a + b + 2.0) {
            // Use continued fraction directly
            return     bt * Self.fraction(a: a, b: b, x: q) / a
        } else {
            // Use symmetry relation: I_x(a,b) = 1 - I_{1-x}(b,a)
            return 1 - bt * Self.fraction(a: b, b: a, x: p) / b
        }
    }

    /// Compute the continued fraction part of the incomplete beta function
    private static func fraction(a: Double, b: Double, x: Double) -> Double {
        // Implementation of the modified Lentz algorithm for continued fractions
        let fpmin: Double = 1e-30
        let ε: Double = 1e-15

        let qab: Double = a + b
        let qap: Double = a + 1
        let qam: Double = a - 1

        var c: Double = 1
        var d: Double = 1 - qab * x / qap
        if abs(d) < fpmin { d = fpmin }
        d = 1 / d
        var h: Double = d

        for m: Int in 1 ... Self.iterations {
            let m: (Void, Double, Double) = ((), Double.init(m), Double.init(m * 2))
            let aa: Double = m.1 * (b - m.1) * x / ((qam + m.2) * (a + m.2))

            // Even step
            d = 1 + aa * d
            if abs(d) < fpmin { d = fpmin }
            c = 1 + aa / c
            if abs(c) < fpmin { c = fpmin }
            d = 1 / d
            h *= d * c

            // Odd step
            let bb: Double = -(a + m.1) * (qab + m.1) * x / ((a + m.2) * (qap + m.2))

            d = 1 + bb * d
            if abs(d) < fpmin { d = fpmin }
            c = 1 + bb / c
            if abs(c) < fpmin { c = fpmin }
            d = 1 / d
            let del: Double = d * c
            h *= del

            // Check for convergence
            if abs(del - 1) <= ε {
                return h
            }
        }

        // If we reached here, we didn't converge - return best approximation
        return h
    }
}
