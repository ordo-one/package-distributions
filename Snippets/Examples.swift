import Random

var random: PseudoRandom = .init(seed: 13)

let binomial: (Int64, Int64, Int64, Int64) = (
    Binomial[10, 0.2].sample(using: &random.generator),
    Binomial[10, 0.2].sample(using: &random.generator),
    Binomial[10, 0.2].sample(using: &random.generator),
    Binomial[10, 0.2].sample(using: &random.generator),
)
print("Generated binomial samples: \(binomial)")

let normal: (Double, Double, Double, Double) = (
    Normal[0, 1].sample(using: &random.generator),
    Normal[0, 1].sample(using: &random.generator),
    Normal[0, 1].sample(using: &random.generator),
    Normal[0, 1].sample(using: &random.generator),
)

print("Generated normal samples: \(normal)")
