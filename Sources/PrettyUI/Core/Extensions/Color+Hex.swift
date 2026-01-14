//
//  Color+Hex.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Color {
    /// Create a color from a hex string
    ///
    /// Supports formats:
    /// - `#RGB`
    /// - `#RRGGBB`
    /// - `#RRGGBBAA`
    /// - `RGB`
    /// - `RRGGBB`
    /// - `RRGGBBAA`
    ///
    /// ```swift
    /// let purple = Color(hex: "#6366F1")
    /// let red = Color(hex: "EF4444")
    /// let semiTransparent = Color(hex: "#00000080")
    /// ```
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RRGGBBAA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert color to hex string
    public var hexString: String? {
        guard let components = cgColor?.components, components.count >= 3 else {
            return nil
        }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        if components.count >= 4 && components[3] < 1 {
            let a = Int(components[3] * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Color Manipulation

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Color {
    /// Lighten the color by a percentage (0-1)
    public func lighter(by percentage: CGFloat = 0.1) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    /// Darken the color by a percentage (0-1)
    public func darker(by percentage: CGFloat = 0.1) -> Color {
        return self.adjust(by: -abs(percentage))
    }
    
    private func adjust(by percentage: CGFloat) -> Color {
        guard let components = cgColor?.components, components.count >= 3 else {
            return self
        }
        
        let r = min(max(components[0] + percentage, 0), 1)
        let g = min(max(components[1] + percentage, 0), 1)
        let b = min(max(components[2] + percentage, 0), 1)
        let a = components.count >= 4 ? components[3] : 1.0
        
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
    
    /// Get the luminance of the color (0-1)
    public var luminance: CGFloat {
        guard let components = cgColor?.components, components.count >= 3 else {
            return 0
        }
        
        // Using relative luminance formula
        return 0.299 * components[0] + 0.587 * components[1] + 0.114 * components[2]
    }
    
    /// Returns true if the color is considered "light"
    public var isLight: Bool {
        luminance > 0.5
    }
    
    /// Returns a contrasting color (black or white) for text
    public var contrastingColor: Color {
        isLight ? .black : .white
    }
}

