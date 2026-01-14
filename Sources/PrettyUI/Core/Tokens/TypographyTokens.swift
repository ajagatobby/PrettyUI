//
//  TypographyTokens.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// Typography tokens for consistent text styling
public struct TypographyTokens: Equatable, Sendable {
    
    /// Default font family
    public var fontFamily: FontFamily
    
    /// Monospace font family (for code)
    public var monoFontFamily: FontFamily
    
    /// Font sizes
    public var sizes: FontSizes
    
    /// Font weights
    public var weights: FontWeights
    
    /// Line heights
    public var lineHeights: LineHeights
    
    /// Letter spacing
    public var letterSpacing: LetterSpacing
    
    // MARK: - Initializer
    
    public init(
        fontFamily: FontFamily = .system,
        monoFontFamily: FontFamily = .system,
        sizes: FontSizes = .default,
        weights: FontWeights = .default,
        lineHeights: LineHeights = .default,
        letterSpacing: LetterSpacing = .default
    ) {
        self.fontFamily = fontFamily
        self.monoFontFamily = monoFontFamily
        self.sizes = sizes
        self.weights = weights
        self.lineHeights = lineHeights
        self.letterSpacing = letterSpacing
    }
    
    // MARK: - Default
    
    public static let `default` = TypographyTokens()
}

// MARK: - Font Family

public enum FontFamily: Equatable, Sendable {
    case system
    case custom(String)
    
    public var name: String? {
        switch self {
        case .system: return nil
        case .custom(let name): return name
        }
    }
}

// MARK: - Font Sizes

public struct FontSizes: Equatable, Sendable {
    public var xs: CGFloat      // 12
    public var sm: CGFloat      // 14
    public var base: CGFloat    // 16
    public var lg: CGFloat      // 18
    public var xl: CGFloat      // 20
    public var xxl: CGFloat     // 24
    public var xxxl: CGFloat    // 30
    public var display: CGFloat // 36
    
    public init(
        xs: CGFloat = 12,
        sm: CGFloat = 14,
        base: CGFloat = 16,
        lg: CGFloat = 18,
        xl: CGFloat = 20,
        xxl: CGFloat = 24,
        xxxl: CGFloat = 30,
        display: CGFloat = 36
    ) {
        self.xs = xs
        self.sm = sm
        self.base = base
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
        self.display = display
    }
    
    public static let `default` = FontSizes()
    
    public subscript(_ size: TextSize) -> CGFloat {
        switch size {
        case .xs: return xs
        case .sm: return sm
        case .base: return base
        case .lg: return lg
        case .xl: return xl
        case .xxl: return xxl
        case .xxxl: return xxxl
        case .display: return display
        case .custom(let value): return value
        }
    }
}

public enum TextSize: Equatable, Sendable {
    case xs
    case sm
    case base
    case lg
    case xl
    case xxl
    case xxxl
    case display
    case custom(CGFloat)
}

// MARK: - Font Weights

public struct FontWeights: Equatable, Sendable {
    public var thin: Font.Weight
    public var light: Font.Weight
    public var regular: Font.Weight
    public var medium: Font.Weight
    public var semibold: Font.Weight
    public var bold: Font.Weight
    public var heavy: Font.Weight
    
    public init(
        thin: Font.Weight = .thin,
        light: Font.Weight = .light,
        regular: Font.Weight = .regular,
        medium: Font.Weight = .medium,
        semibold: Font.Weight = .semibold,
        bold: Font.Weight = .bold,
        heavy: Font.Weight = .heavy
    ) {
        self.thin = thin
        self.light = light
        self.regular = regular
        self.medium = medium
        self.semibold = semibold
        self.bold = bold
        self.heavy = heavy
    }
    
    public static let `default` = FontWeights()
}

// MARK: - Line Heights

public struct LineHeights: Equatable, Sendable {
    public var tight: CGFloat     // 1.25
    public var normal: CGFloat    // 1.5
    public var relaxed: CGFloat   // 1.75
    public var loose: CGFloat     // 2.0
    
    public init(
        tight: CGFloat = 1.25,
        normal: CGFloat = 1.5,
        relaxed: CGFloat = 1.75,
        loose: CGFloat = 2.0
    ) {
        self.tight = tight
        self.normal = normal
        self.relaxed = relaxed
        self.loose = loose
    }
    
    public static let `default` = LineHeights()
}

// MARK: - Letter Spacing

public struct LetterSpacing: Equatable, Sendable {
    public var tighter: CGFloat   // -0.05em
    public var tight: CGFloat     // -0.025em
    public var normal: CGFloat    // 0
    public var wide: CGFloat      // 0.025em
    public var wider: CGFloat     // 0.05em
    public var widest: CGFloat    // 0.1em
    
    public init(
        tighter: CGFloat = -0.8,
        tight: CGFloat = -0.4,
        normal: CGFloat = 0,
        wide: CGFloat = 0.4,
        wider: CGFloat = 0.8,
        widest: CGFloat = 1.6
    ) {
        self.tighter = tighter
        self.tight = tight
        self.normal = normal
        self.wide = wide
        self.wider = wider
        self.widest = widest
    }
    
    public static let `default` = LetterSpacing()
}

