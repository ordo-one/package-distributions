import Random
import RealModule

/// A utility to perform a Chi-Square goodness-of-fit test.
struct ChiSquareTest {
    /// Represents a single bin for the Chi-Square test, containing observed and expected frequencies.
    struct Bin {
        let observed: Int
        let expected: Double
    }

    /// Calculates the Chi-Square statistic, degrees of freedom, and p-value.
    /// - Parameters:
    ///   - bins: An array of `Bin` structures representing the data.
    ///   - estimatedParameters: The number of parameters estimated from the data (e.g., mean, variance).
    /// - Returns: A tuple containing the Chi-Square statistic, degrees of freedom, and the calculated p-value.
    static func perform(
        on bins: [Bin],
        estimatedParameters: Int
    ) -> (statistic: Double, df: Int, p: Double) {
        var statistic: Double = 0
        var validBins: Int = 0

        for bin: Bin in bins {
            if bin.expected >= 5 {
                let difference: Double = Double.init(bin.observed) - bin.expected
                statistic += (difference * difference) / bin.expected
                validBins += 1
            }
        }

        // Correctly calculate degrees of freedom.
        let df: Int = max(1, validBins - 1 - estimatedParameters)
        return (statistic, df, Self.p(statistic, df: df))
    }

    private static func p(_ x: Double, df: Int) -> Double {
        guard df > 0, x > 0 else {
            return 1
        }

        let df_double: Double = .init(df)

        // Wilson-Hilferty approximation:
        let term1: Double = .pow(x / df_double, 1.0 / 3.0)
        let term2: Double = 1.0 - (2.0 / (9.0 * df_double))
        let term3: Double = .sqrt(2.0 / (9.0 * df_double))

        let z: Double = (term1 - term2) / term3

        return 1 - Normal[0, 1].cdf(z)
    }
}
