import SwiftUI

struct ColorGenerator {
    /// Generate a consistent pastel color from a UUID
    static func pastelColor(from id: UUID) -> Color {
        let hash = id.hashValue

        // Use hash to generate hue (0-360)
        let hue = Double(abs(hash) % 360) / 360.0

        // Pastel colors: high lightness, medium saturation
        let saturation = 0.4 + Double(abs(hash >> 8) % 20) / 100.0 // 0.4-0.6
        let brightness = 0.85 + Double(abs(hash >> 16) % 10) / 100.0 // 0.85-0.95

        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }

    /// Get a slightly darker version for borders/accents
    static func accentColor(from id: UUID) -> Color {
        let hash = id.hashValue
        let hue = Double(abs(hash) % 360) / 360.0
        let saturation = 0.5 + Double(abs(hash >> 8) % 20) / 100.0
        let brightness = 0.7 + Double(abs(hash >> 16) % 10) / 100.0

        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}

// Extension for EisenTask to easily access colors
extension EisenTask {
    var pastelColor: Color {
        ColorGenerator.pastelColor(from: id)
    }

    var accentColor: Color {
        ColorGenerator.accentColor(from: id)
    }
}
