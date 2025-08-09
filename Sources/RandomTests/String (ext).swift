extension String {
    // Left-aligned padding (adds to the right)
    func padding(left length: Int, with pad: String = " ") -> String {
        if self.count >= length {
            return self
        }
        let paddingNeeded: Int = length - self.count
        return self + .init(repeating: pad, count: paddingNeeded)
    }

    // Right-aligned padding (adds to the left)
    func padding(right length: Int, with pad: String = " ") -> String {
        if self.count >= length {
            return self
        }
        let paddingNeeded: Int = length - self.count
        return .init(repeating: pad, count: paddingNeeded) + self
    }
}
