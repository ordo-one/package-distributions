import RealModule

/// Normal distribution sampler using inverse-CDF
@frozen public struct Normal {
    public let μ: Double // mean
    public let σ: Double // standard deviation

    @inlinable init(μ: Double, σ: Double) {
        self.μ = μ
        self.σ = σ
    }
}
extension Normal {
    @inlinable public static subscript(μ: Double, σ: Double) -> Self { .init(μ: μ, σ: σ) }
}
extension Normal {
    @inlinable public func sample(using generator: inout some RandomNumberGenerator) -> Double {
        self.sample { .random(in: 0 ... 1, using: &generator) }
    }

    /// Sample from a normal distribution using inverse transform sampling.
    @inlinable public func sample(U: () -> Double) -> Double {
        // Handle edge case
        if self.σ <= 0 { return self.μ }

        // Generate uniform random value
        let u: Double = U()

        // Calculate standard normal quantile (inverse CDF) and transform to N(μ,σ)
        return self.μ + self.σ * Self.cdfInverse(u)
    }

    @inlinable public func pdf(_ x: Double) -> Double {
        let exponent: Double = -0.5 * Double.pow((x - self.μ) / self.σ, 2)
        return Double.exp(exponent) / (self.σ * Double.sqrt(2 * .pi))
    }

    @inlinable public func cdf(_ x: Double) -> Double {
        Self.cdf(μ: self.μ, σ: self.σ, x: x)
    }

    @inlinable public func cdfInverse(_ p: Double) -> Double {
        self.μ + self.σ * Self.cdfInverse(p)
    }
}
extension Normal {
    @inlinable static func cdf(μ: Double, σ: Double, x: Double) -> Double {
        0.5 * (1 + Double.erf((x - μ) / (σ * Double.sqrt(2))))
    }

    /// Abramowitz and Stegun approximation of the standard normal quantile function (inverse
    /// CDF), valid for 0.001 < p < 0.999. Uses a simple approximation outside that range.
    @inlinable static func cdfInverse(_ p: Double) -> Double {
        // Handle edge cases
        if p <= 0.0 { return -Double.infinity }
        if p >= 1.0 { return  Double.infinity }

        let x: Double
        let q: Double = p < 0.5 ? p : 1 - p
        if  q < 0.001 {
            // For extreme tails, use the standard form
            let t: Double = Double.sqrt(-2 * Double.log(q))

            // Use a simplified formula similar to the main branch
            // but optimized for the extreme tails
            let numerator: Double = 2.30753 + 0.27061 * t
            let denominator: Double = 1 + 0.99229 * t + 0.04481 * t * t

            x = t - numerator / denominator
        } else {
            // Coefficients for the approximation
            let c: (Double, Double, Double) = (2.515517, 0.802853, 0.010328)
            let d: (Void, Double, Double, Double) = ((), 1.432788, 0.189269, 0.001308)

            // Calculate t
            let t: Double = Double.sqrt(-2 * Double.log(q))

            // Calculate the approximation
            let numerator: Double = c.0 + t * (c.1 + t * c.2)
            let denominator: Double = 1 + t * (d.1 + t * (d.2 + t * d.3))

            x = t - numerator / denominator
        }

        return p < 0.5 ? -x : x
    }
}
