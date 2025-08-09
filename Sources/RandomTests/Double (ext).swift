extension Double {
    // Helper function for fixed precision percentage
    var percent: String {
        let percentage: Double = self * 100
        if percentage < 0.00001 {
            return "<0.00001%"
        }
        let stringValue: String = "\(percentage)"
        if stringValue.count > 8 {
            return stringValue.prefix(8) + "%"
        }
        return stringValue + "%"
    }

    func percent(places: Int = 2) -> String {
        (self * 100).decimal(places: places) + "%"
    }

    func decimal(places: Int = 2) -> String {
        var result: String = "\(self)"

        // Find decimal point position
        if let dotIndex: String.Index = result.firstIndex(of: ".") {
            let decimals: Int = result.distance(from: dotIndex, to: result.endIndex) - 1

            if decimals > places {
                // Truncate to specified decimal places
                let endIndex: String.Index = result.index(dotIndex, offsetBy: places + 1)
                result = .init(result[..<endIndex])
            } else if decimals < places {
                // Add zeros if needed
                result += .init(repeating: "0", count: places - decimals)
            }
        } else {
            // No decimal point, add one with zeros
            result += "." + .init(repeating: "0", count: places)
        }

        return result
    }
}
