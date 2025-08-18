[![Tests](https://github.com/ordo-one/package-distributions/actions/workflows/Tests.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/Tests.yml)
[![Documentation](https://github.com/ordo-one/package-distributions/actions/workflows/Documentation.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/Documentation.yml)

The ***package-distributions*** library is a portable, Foundation-free library for working with statistical distributions in Swift, with a focus on efficient sampling and random number generation.

[documentation](https://swiftinit.org/docs/package-distributions) ·
[license](LICENSE)


## Requirements

The package-distributions library requires Swift 6.1 or later.


| Platform | Status |
| -------- | ------ |
| 🐧 Linux | [![Tests](https://github.com/ordo-one/package-distributions/actions/workflows/Tests.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/Tests.yml) |
| 🍏 Darwin | [![Tests](https://github.com/ordo-one/package-distributions/actions/workflows/Tests.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/Tests.yml) |
| 🍏 Darwin (iOS) | [![iOS](https://github.com/ordo-one/package-distributions/actions/workflows/iOS.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/iOS.yml) |
| 🍏 Darwin (tvOS) | [![tvOS](https://github.com/ordo-one/package-distributions/actions/workflows/tvOS.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/tvOS.yml) |
| 🍏 Darwin (visionOS) | [![visionOS](https://github.com/ordo-one/package-distributions/actions/workflows/visionOS.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/visionOS.yml) |
| 🍏 Darwin (watchOS) | [![watchOS](https://github.com/ordo-one/package-distributions/actions/workflows/watchOS.yml/badge.svg)](https://github.com/ordo-one/package-distributions/actions/workflows/watchOS.yml) |


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
