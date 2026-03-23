<div align="center">

🃏 &nbsp; **distributions** &nbsp; 🃏

a portable, Foundation-free library for working with statistical distributions in Swift, with a focus on efficient sampling and random number generation

[documentation](https://swiftinit.org/docs/package-distributions) ·
[license](LICENSE)

</div>


## Requirements

The package-distributions library requires Swift 6.1 or later.


<!-- DO NOT EDIT BELOW! AUTOSYNC CONTENT [STATUS TABLE] -->
<!-- DO NOT EDIT ABOVE! AUTOSYNC CONTENT [STATUS TABLE] -->

[Check deployment minimums](https://swiftinit.org/docs/package-distributions#ss:platform-requirements)


## Examples

```swift
import Random

var random: PseudoRandom = .init(seed: 13)

let binomial: (Int64, Int64, Int64, Int64) = (
    Binomial[10, 0.2].sample(using: &random.generator),
    Binomial[10, 0.2].sample(using: &random.generator),
    Binomial[10, 0.2].sample(using: &random.generator),
    Binomial[10, 0.2].sample(using: &random.generator),
)

// Generated binomial samples: (1, 4, 2, 4)

let normal: (Double, Double, Double, Double) = (
    Normal[0, 1].sample(using: &random.generator),
    Normal[0, 1].sample(using: &random.generator),
    Normal[0, 1].sample(using: &random.generator),
    Normal[0, 1].sample(using: &random.generator),
)

// Generated normal samples: (1.031, 1.201, -1.607, -0.243)
```
