@frozen public struct PseudoRandom {
    @usableFromInline var wyhash: Wyhash

    @inlinable public init(seed: UInt64 = 12345) {
        self.wyhash = .init(seed: seed)
    }
}
extension PseudoRandom: RawRepresentable {
    @inlinable public init(rawValue: UInt64) {
        self.wyhash = .init(rawValue: rawValue)
    }
    @inlinable public var rawValue: UInt64 {
        self.wyhash.rawValue
    }
}
extension PseudoRandom {
    @inlinable public var generator: Wyhash {
        get { self.wyhash }
        set { self.wyhash = newValue }
    }
}
extension PseudoRandom {
    @inlinable public mutating func roll(_ n: Int64, _ d: Int64) -> Bool {
        n <= 0 ? false : n < d ? self.int64(in: 0 ..< d) < n : true
    }

    @inlinable public mutating func int64() -> Int64 {
        .init(bitPattern: self.wyhash.next())
    }

    @inlinable public mutating func int64(in range: Range<Int64>) -> Int64 {
        .random(in: range, using: &self.wyhash)
    }

    @inlinable public mutating func int64(in range: ClosedRange<Int64>) -> Int64 {
        .random(in: range, using: &self.wyhash)
    }
}
