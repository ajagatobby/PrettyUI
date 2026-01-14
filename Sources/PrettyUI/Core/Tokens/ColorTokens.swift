//
//  ColorTokens.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// Color tokens that define the color palette for your app
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ColorTokens: Equatable, Sendable {
    
    // MARK: - Primary Colors
    
    /// Primary brand color - used for primary buttons, links, focus states
    public var primary: Color
    
    /// Text/icon color on primary backgrounds
    public var primaryForeground: Color
    
    // MARK: - Secondary Colors
    
    /// Secondary brand color - used for secondary actions
    public var secondary: Color
    
    /// Text/icon color on secondary backgrounds
    public var secondaryForeground: Color
    
    // MARK: - Accent Colors
    
    /// Accent color for highlights and emphasis
    public var accent: Color
    
    /// Text/icon color on accent backgrounds
    public var accentForeground: Color
    
    // MARK: - Semantic Colors
    
    /// Destructive actions (delete, remove, error)
    public var destructive: Color
    
    /// Text/icon color on destructive backgrounds
    public var destructiveForeground: Color
    
    /// Success states
    public var success: Color
    
    /// Text/icon color on success backgrounds
    public var successForeground: Color
    
    /// Warning states
    public var warning: Color
    
    /// Text/icon color on warning backgrounds
    public var warningForeground: Color
    
    // MARK: - Background Colors
    
    /// Main background color
    public var background: Color
    
    /// Primary text color on background
    public var foreground: Color
    
    /// Muted/subtle background (cards, inputs)
    public var muted: Color
    
    /// Text on muted backgrounds
    public var mutedForeground: Color
    
    /// Card background color
    public var card: Color
    
    /// Text on card backgrounds
    public var cardForeground: Color
    
    // MARK: - Border & Ring
    
    /// Default border color
    public var border: Color
    
    /// Input/element border color
    public var input: Color
    
    /// Focus ring color
    public var ring: Color
    
    // MARK: - Initializer
    
    public init(
        primary: Color,
        primaryForeground: Color,
        secondary: Color,
        secondaryForeground: Color,
        accent: Color,
        accentForeground: Color,
        destructive: Color,
        destructiveForeground: Color,
        success: Color,
        successForeground: Color,
        warning: Color,
        warningForeground: Color,
        background: Color,
        foreground: Color,
        muted: Color,
        mutedForeground: Color,
        card: Color,
        cardForeground: Color,
        border: Color,
        input: Color,
        ring: Color
    ) {
        self.primary = primary
        self.primaryForeground = primaryForeground
        self.secondary = secondary
        self.secondaryForeground = secondaryForeground
        self.accent = accent
        self.accentForeground = accentForeground
        self.destructive = destructive
        self.destructiveForeground = destructiveForeground
        self.success = success
        self.successForeground = successForeground
        self.warning = warning
        self.warningForeground = warningForeground
        self.background = background
        self.foreground = foreground
        self.muted = muted
        self.mutedForeground = mutedForeground
        self.card = card
        self.cardForeground = cardForeground
        self.border = border
        self.input = input
        self.ring = ring
    }
}

// MARK: - Default Light Theme

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ColorTokens {
    
    /// Default light theme colors
    public static let light = ColorTokens(
        primary: Color(hex: "#18181B"),
        primaryForeground: Color(hex: "#FAFAFA"),
        secondary: Color(hex: "#F4F4F5"),
        secondaryForeground: Color(hex: "#18181B"),
        accent: Color(hex: "#F4F4F5"),
        accentForeground: Color(hex: "#18181B"),
        destructive: Color(hex: "#EF4444"),
        destructiveForeground: Color(hex: "#FAFAFA"),
        success: Color(hex: "#22C55E"),
        successForeground: Color(hex: "#FAFAFA"),
        warning: Color(hex: "#F59E0B"),
        warningForeground: Color(hex: "#18181B"),
        background: Color(hex: "#FFFFFF"),
        foreground: Color(hex: "#09090B"),
        muted: Color(hex: "#F4F4F5"),
        mutedForeground: Color(hex: "#71717A"),
        card: Color(hex: "#FFFFFF"),
        cardForeground: Color(hex: "#09090B"),
        border: Color(hex: "#E4E4E7"),
        input: Color(hex: "#E4E4E7"),
        ring: Color(hex: "#18181B")
    )
    
    /// Default dark theme colors
    public static let dark = ColorTokens(
        primary: Color(hex: "#FAFAFA"),
        primaryForeground: Color(hex: "#18181B"),
        secondary: Color(hex: "#27272A"),
        secondaryForeground: Color(hex: "#FAFAFA"),
        accent: Color(hex: "#27272A"),
        accentForeground: Color(hex: "#FAFAFA"),
        destructive: Color(hex: "#DC2626"),
        destructiveForeground: Color(hex: "#FAFAFA"),
        success: Color(hex: "#16A34A"),
        successForeground: Color(hex: "#FAFAFA"),
        warning: Color(hex: "#D97706"),
        warningForeground: Color(hex: "#18181B"),
        background: Color(hex: "#09090B"),
        foreground: Color(hex: "#FAFAFA"),
        muted: Color(hex: "#27272A"),
        mutedForeground: Color(hex: "#A1A1AA"),
        card: Color(hex: "#09090B"),
        cardForeground: Color(hex: "#FAFAFA"),
        border: Color(hex: "#27272A"),
        input: Color(hex: "#27272A"),
        ring: Color(hex: "#D4D4D8")
    )
}

// MARK: - Family Theme Colors

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension ColorTokens {
    
    /// Family.co inspired light theme with vibrant cyan-blue primary
    public static let familyLight = ColorTokens(
        primary: Color(hex: "#1DA1F2"),
        primaryForeground: Color(hex: "#FFFFFF"),
        secondary: Color(hex: "#F4F4F5"),
        secondaryForeground: Color(hex: "#1D1D1F"),
        accent: Color(hex: "#1DA1F2"),
        accentForeground: Color(hex: "#FFFFFF"),
        destructive: Color(hex: "#FF3B30"),
        destructiveForeground: Color(hex: "#FFFFFF"),
        success: Color(hex: "#34C759"),
        successForeground: Color(hex: "#FFFFFF"),
        warning: Color(hex: "#FF9500"),
        warningForeground: Color(hex: "#1D1D1F"),
        background: Color(hex: "#F8F9FA"),
        foreground: Color(hex: "#1D1D1F"),
        muted: Color(hex: "#F4F4F5"),
        mutedForeground: Color(hex: "#6E6E73"),
        card: Color(hex: "#FFFFFF"),
        cardForeground: Color(hex: "#1D1D1F"),
        border: Color(hex: "#E8EAED"),
        input: Color(hex: "#E8EAED"),
        ring: Color(hex: "#1DA1F2")
    )
    
    /// Family.co inspired dark theme
    public static let familyDark = ColorTokens(
        primary: Color(hex: "#1DA1F2"),
        primaryForeground: Color(hex: "#FFFFFF"),
        secondary: Color(hex: "#2C2C2E"),
        secondaryForeground: Color(hex: "#FFFFFF"),
        accent: Color(hex: "#1DA1F2"),
        accentForeground: Color(hex: "#FFFFFF"),
        destructive: Color(hex: "#FF453A"),
        destructiveForeground: Color(hex: "#FFFFFF"),
        success: Color(hex: "#30D158"),
        successForeground: Color(hex: "#FFFFFF"),
        warning: Color(hex: "#FFD60A"),
        warningForeground: Color(hex: "#1D1D1F"),
        background: Color(hex: "#0D0D0D"),
        foreground: Color(hex: "#FFFFFF"),
        muted: Color(hex: "#2C2C2E"),
        mutedForeground: Color(hex: "#8E8E93"),
        card: Color(hex: "#1C1C1E"),
        cardForeground: Color(hex: "#FFFFFF"),
        border: Color(hex: "#38383A"),
        input: Color(hex: "#38383A"),
        ring: Color(hex: "#1DA1F2")
    )
}

