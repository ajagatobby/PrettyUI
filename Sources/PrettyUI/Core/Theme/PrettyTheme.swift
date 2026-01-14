//
//  PrettyTheme.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// The main theme configuration for PrettyUI
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
///
/// Create a custom theme by extending `PrettyTheme`:
/// ```swift
/// extension PrettyTheme {
///     static let custom = PrettyTheme(
///         colors: .init(
///             primary: Color(hex: "#6366F1"),
///             // ... other colors
///         )
///     )
/// }
/// ```
///
/// Apply the theme to your app:
/// ```swift
/// @main
/// struct MyApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .prettyTheme(.custom)
///         }
///     }
/// }
/// ```
public struct PrettyTheme: Equatable, Sendable {
    
    // MARK: - Design Tokens
    
    /// Color palette for light mode
    public var colors: ColorTokens
    
    /// Color palette for dark mode (optional - falls back to colors if nil)
    public var darkColors: ColorTokens?
    
    /// Spacing scale
    public var spacing: SpacingTokens
    
    /// Border radius scale
    public var radius: RadiusTokens
    
    /// Typography settings
    public var typography: TypographyTokens
    
    /// Shadow styles
    public var shadows: ShadowTokens
    
    // MARK: - Component Configs
    
    /// Per-component configuration
    public var components: ComponentConfigs
    
    // MARK: - Initializer
    
    public init(
        colors: ColorTokens = .light,
        darkColors: ColorTokens? = .dark,
        spacing: SpacingTokens = .default,
        radius: RadiusTokens = .default,
        typography: TypographyTokens = .default,
        shadows: ShadowTokens = .default,
        components: ComponentConfigs = .default
    ) {
        self.colors = colors
        self.darkColors = darkColors
        self.spacing = spacing
        self.radius = radius
        self.typography = typography
        self.shadows = shadows
        self.components = components
    }
    
    // MARK: - Default Theme
    
    /// Default PrettyUI theme with neutral colors
    public static let `default` = PrettyTheme()
    
    // MARK: - Color Access
    
    /// Get colors for the current color scheme
    public func colors(for colorScheme: ColorScheme) -> ColorTokens {
        switch colorScheme {
        case .dark:
            return darkColors ?? colors
        case .light:
            return colors
        @unknown default:
            return colors
        }
    }
}

// MARK: - Preset Themes

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PrettyTheme {
    
    /// Family.co inspired theme with vibrant cyan-blue, soft shadows, and friendly aesthetics
    ///
    /// This theme captures Family's design language:
    /// - Vibrant cyan-blue primary color (#1DA1F2)
    /// - Soft, light backgrounds
    /// - Generous spacing and pill-shaped buttons
    /// - Smooth spring animations
    public static let family = PrettyTheme(
        colors: ColorTokens(
            // Primary - Vibrant cyan-blue for CTAs
            primary: Color(hex: "#1DA1F2"),
            primaryForeground: Color(hex: "#FFFFFF"),
            // Secondary - Subtle gray for secondary actions
            secondary: Color(hex: "#F4F4F5"),
            secondaryForeground: Color(hex: "#1D1D1F"),
            // Accent
            accent: Color(hex: "#1DA1F2"),
            accentForeground: Color(hex: "#FFFFFF"),
            // Semantic colors
            destructive: Color(hex: "#FF3B30"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#34C759"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#FF9500"),
            warningForeground: Color(hex: "#1D1D1F"),
            // Background layers
            background: Color(hex: "#F8F9FA"),
            foreground: Color(hex: "#1D1D1F"),
            // Muted elements
            muted: Color(hex: "#F4F4F5"),
            mutedForeground: Color(hex: "#6E6E73"),
            // Card/Surface
            card: Color(hex: "#FFFFFF"),
            cardForeground: Color(hex: "#1D1D1F"),
            // Borders
            border: Color(hex: "#E8EAED"),
            input: Color(hex: "#E8EAED"),
            ring: Color(hex: "#1DA1F2")
        ),
        darkColors: ColorTokens(
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
        ),
        radius: RadiusTokens(
            none: 0,
            sm: 6,
            md: 10,
            lg: 14,
            xl: 20,
            xxl: 28,
            full: 9999
        ),
        shadows: ShadowTokens(
            none: ShadowStyle(color: .clear, radius: 0, x: 0, y: 0),
            sm: ShadowStyle(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2),
            md: ShadowStyle(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4),
            lg: ShadowStyle(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 8),
            xl: ShadowStyle(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 12),
            xxl: ShadowStyle(color: Color.black.opacity(0.16), radius: 48, x: 0, y: 16)
        ),
        components: ComponentConfigs(
            button: ButtonConfig(
                defaultVariant: .primary,
                defaultSize: .lg,
                radius: .full,
                animationDuration: 0.25,
                showPressAnimation: true
            ),
            card: CardConfig(
                radius: .xl,
                shadow: .sm,
                padding: .md,
                showBorder: false,
                borderWidth: 0
            ),
            textField: TextFieldConfig(
                radius: .lg,
                defaultSize: .md,
                borderWidth: 1,
                focusRingWidth: 2,
                animationDuration: 0.2
            ),
            tooltip: TooltipConfig(
                radius: .md,
                padding: .sm,
                arrowSize: 6,
                animationDuration: 0.15,
                showDelay: 0.5
            ),
            accordion: AccordionConfig(
                defaultVariant: .standard,
                defaultExpansionMode: .multiple,
                radius: .xl,
                springResponse: 0.35,
                springDamping: 0.7,
                chevronRotation: 180,
                showDividers: true,
                hapticFeedback: true
            )
        )
    )
    
    /// A theme with vibrant purple/indigo accent colors
    public static let indigo = PrettyTheme(
        colors: ColorTokens(
            primary: Color(hex: "#6366F1"),
            primaryForeground: Color(hex: "#FFFFFF"),
            secondary: Color(hex: "#E0E7FF"),
            secondaryForeground: Color(hex: "#3730A3"),
            accent: Color(hex: "#8B5CF6"),
            accentForeground: Color(hex: "#FFFFFF"),
            destructive: Color(hex: "#EF4444"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#22C55E"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#F59E0B"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#FFFFFF"),
            foreground: Color(hex: "#1E1B4B"),
            muted: Color(hex: "#F5F3FF"),
            mutedForeground: Color(hex: "#6B7280"),
            card: Color(hex: "#FFFFFF"),
            cardForeground: Color(hex: "#1E1B4B"),
            border: Color(hex: "#E5E7EB"),
            input: Color(hex: "#E5E7EB"),
            ring: Color(hex: "#6366F1")
        ),
        darkColors: ColorTokens(
            primary: Color(hex: "#818CF8"),
            primaryForeground: Color(hex: "#1E1B4B"),
            secondary: Color(hex: "#312E81"),
            secondaryForeground: Color(hex: "#E0E7FF"),
            accent: Color(hex: "#A78BFA"),
            accentForeground: Color(hex: "#1E1B4B"),
            destructive: Color(hex: "#DC2626"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#16A34A"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#D97706"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#0F0D1A"),
            foreground: Color(hex: "#F5F3FF"),
            muted: Color(hex: "#1E1B4B"),
            mutedForeground: Color(hex: "#A5B4FC"),
            card: Color(hex: "#1E1B4B"),
            cardForeground: Color(hex: "#F5F3FF"),
            border: Color(hex: "#312E81"),
            input: Color(hex: "#312E81"),
            ring: Color(hex: "#818CF8")
        )
    )
    
    /// A theme with teal/emerald accent colors
    public static let emerald = PrettyTheme(
        colors: ColorTokens(
            primary: Color(hex: "#10B981"),
            primaryForeground: Color(hex: "#FFFFFF"),
            secondary: Color(hex: "#D1FAE5"),
            secondaryForeground: Color(hex: "#065F46"),
            accent: Color(hex: "#14B8A6"),
            accentForeground: Color(hex: "#FFFFFF"),
            destructive: Color(hex: "#EF4444"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#22C55E"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#F59E0B"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#FFFFFF"),
            foreground: Color(hex: "#064E3B"),
            muted: Color(hex: "#ECFDF5"),
            mutedForeground: Color(hex: "#6B7280"),
            card: Color(hex: "#FFFFFF"),
            cardForeground: Color(hex: "#064E3B"),
            border: Color(hex: "#D1D5DB"),
            input: Color(hex: "#D1D5DB"),
            ring: Color(hex: "#10B981")
        ),
        darkColors: ColorTokens(
            primary: Color(hex: "#34D399"),
            primaryForeground: Color(hex: "#064E3B"),
            secondary: Color(hex: "#065F46"),
            secondaryForeground: Color(hex: "#D1FAE5"),
            accent: Color(hex: "#2DD4BF"),
            accentForeground: Color(hex: "#064E3B"),
            destructive: Color(hex: "#DC2626"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#16A34A"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#D97706"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#022C22"),
            foreground: Color(hex: "#ECFDF5"),
            muted: Color(hex: "#064E3B"),
            mutedForeground: Color(hex: "#6EE7B7"),
            card: Color(hex: "#064E3B"),
            cardForeground: Color(hex: "#ECFDF5"),
            border: Color(hex: "#065F46"),
            input: Color(hex: "#065F46"),
            ring: Color(hex: "#34D399")
        )
    )
    
    /// A theme with orange/amber accent colors
    public static let amber = PrettyTheme(
        colors: ColorTokens(
            primary: Color(hex: "#F59E0B"),
            primaryForeground: Color(hex: "#18181B"),
            secondary: Color(hex: "#FEF3C7"),
            secondaryForeground: Color(hex: "#92400E"),
            accent: Color(hex: "#FB923C"),
            accentForeground: Color(hex: "#18181B"),
            destructive: Color(hex: "#EF4444"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#22C55E"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#F59E0B"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#FFFBEB"),
            foreground: Color(hex: "#78350F"),
            muted: Color(hex: "#FEF3C7"),
            mutedForeground: Color(hex: "#92400E"),
            card: Color(hex: "#FFFFFF"),
            cardForeground: Color(hex: "#78350F"),
            border: Color(hex: "#FDE68A"),
            input: Color(hex: "#FDE68A"),
            ring: Color(hex: "#F59E0B")
        ),
        darkColors: ColorTokens(
            primary: Color(hex: "#FBBF24"),
            primaryForeground: Color(hex: "#18181B"),
            secondary: Color(hex: "#78350F"),
            secondaryForeground: Color(hex: "#FEF3C7"),
            accent: Color(hex: "#FB923C"),
            accentForeground: Color(hex: "#18181B"),
            destructive: Color(hex: "#DC2626"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#16A34A"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#D97706"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#1C1917"),
            foreground: Color(hex: "#FFFBEB"),
            muted: Color(hex: "#78350F"),
            mutedForeground: Color(hex: "#FCD34D"),
            card: Color(hex: "#292524"),
            cardForeground: Color(hex: "#FFFBEB"),
            border: Color(hex: "#92400E"),
            input: Color(hex: "#92400E"),
            ring: Color(hex: "#FBBF24")
        )
    )
}

