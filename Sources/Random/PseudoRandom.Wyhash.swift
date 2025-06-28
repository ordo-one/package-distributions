extension PseudoRandom {
    @frozen public struct Wyhash {
        @usableFromInline var state: UInt64

        @inlinable public init(seed: UInt64) {
            self.state = seed
        }
    }
}
extension PseudoRandom.Wyhash: RawRepresentable {
    @inlinable public init(rawValue: UInt64) { self.init(seed: rawValue) }
    @inlinable public var rawValue: UInt64 { self.state }
}
extension PseudoRandom.Wyhash: RandomNumberGenerator {
    @inlinable public mutating func next() -> UInt64 {
        self.state &+= 0x60bee2bee120fc15
        let x: UInt64 = state &* 0xa3b195354a39b70d
        let y: UInt64 = (x >> 32 ^ x) &* 0x1b03738712fad5c9
        return y >> 32 ^ y
    }
}
