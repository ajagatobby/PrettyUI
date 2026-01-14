//
//  PText.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired typography component with preset styles.
//

import SwiftUI

// MARK: - Text Style

/// Preset text styles matching the Family.co type scale
public enum PTextStyle: String, Equatable, Sendable, CaseIterable {
    /// Display text (36pt, Bold)
    case display
    /// Headline text (28pt, Bold)
    case headline
    /// Title text (22pt, Semibold)
    case title
    /// Body large text (18pt, Regular)
    case bodyLarge
    /// Body text (16pt, Regular) - default
    case body
    /// Caption text (14pt, Regular)
    case caption
    /// Small text (12pt, Medium)
    case small
}

// MARK: - Text Color

/// Color options for PText
public enum PTextColor: Equatable, Sendable {
    /// Primary foreground color
    case primary
    /// Secondary/muted foreground color
    case secondary
    /// Muted foreground color
    case muted
    /// Destructive/error color
    case destructive
    /// Success color
    case success
    /// Warning color
    case warning
    /// Accent/primary brand color
    case accent
    /// Custom color
    case custom(Color)
}

// MARK: - Underline Style

/// Configuration for underline styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTextUnderlineStyle: Sendable {
    var isActive: Bool
    var pattern: Text.LineStyle.Pattern
    var color: Color?
    
    public init(isActive: Bool = false, pattern: Text.LineStyle.Pattern = .solid, color: Color? = nil) {
        self.isActive = isActive
        self.pattern = pattern
        self.color = color
    }
}

// MARK: - Strikethrough Style

/// Configuration for strikethrough styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTextStrikethroughStyle: Sendable {
    var isActive: Bool
    var pattern: Text.LineStyle.Pattern
    var color: Color?
    
    public init(isActive: Bool = false, pattern: Text.LineStyle.Pattern = .solid, color: Color? = nil) {
        self.isActive = isActive
        self.pattern = pattern
        self.color = color
    }
}

// MARK: - PText Configuration

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTextConfiguration {
    var style: PTextStyle = .body
    var color: PTextColor = .primary
    var colorToken: ColorToken? = nil
    var customColor: Color? = nil
    var weight: Font.Weight? = nil
    var fontDesign: Font.Design? = nil
    var fontSize: CGFloat? = nil
    var isMonospace: Bool = false
    var lineSpacing: CGFloat? = nil
    var kerning: CGFloat? = nil
    var alignment: TextAlignment = .leading
    var lineLimit: Int? = nil
    var truncationMode: Text.TruncationMode = .tail
    
    // Font override
    var customFont: Font? = nil
    
    // Text decorations
    var isBold: Bool = false
    var isItalic: Bool = false
    var underline: PTextUnderlineStyle = PTextUnderlineStyle()
    var strikethrough: PTextStrikethroughStyle = PTextStrikethroughStyle()
    var baselineOffset: CGFloat? = nil
    var tracking: CGFloat? = nil
    
    // Additional text modifiers
    var textCase: Text.Case? = nil
    var minimumScaleFactor: CGFloat = 1.0
    var allowsTightening: Bool = false
}

// MARK: - PText

/// A customizable text component inspired by Family.co's typography system.
///
/// Uses a fluent modifier API for configuration:
/// ```swift
/// PText("Create Wallet")
///     .style(.headline)
///     .color(PTextColor.primary)
///
/// PText("0x1234...5678")
///     .style(.caption)
///     .mono()
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PText: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    
    private let text: String
    private var config: PTextConfiguration
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var typography: TypographyTokens {
        theme.typography
    }
    
    // MARK: - Initializer
    
    /// Create a styled text view
    /// - Parameter text: The text content to display
    public init(_ text: String) {
        self.text = text
        self.config = PTextConfiguration()
    }
    
    // Private init for modifiers
    private init(text: String, config: PTextConfiguration) {
        self.text = text
        self.config = config
    }
    
    // MARK: - Body
    
    public var body: some View {
        styledText
            .lineSpacing(resolvedLineSpacing)
            .multilineTextAlignment(config.alignment)
            .lineLimit(config.lineLimit)
            .truncationMode(config.truncationMode)
            .minimumScaleFactor(config.minimumScaleFactor)
            .allowsTightening(config.allowsTightening)
            .textCase(config.textCase)
    }
    
    /// Returns the styled Text view with all text-specific modifiers applied
    /// This allows for Text concatenation and composition
    public var styledText: Text {
        var textView = Text(text)
        
        // Apply font (custom or resolved)
        // When using custom font via .font() modifier, use it directly
        // Otherwise use resolved font which has weight/design baked in
        textView = textView.font(config.customFont ?? resolvedFont)
        
        // Apply weight only for custom font families (which can't embed weight)
        // System fonts already have weight baked in via resolvedFont
        if config.customFont == nil && usesCustomFontFamily {
            textView = textView.fontWeight(resolvedWeight)
        }
        
        // Apply bold if set (in addition to weight)
        if config.isBold {
            textView = textView.bold()
        }
        
        // Apply italic
        if config.isItalic {
            textView = textView.italic()
        }
        
        // Apply foreground color
        textView = textView.foregroundColor(resolvedColor)
        
        // Apply kerning
        textView = textView.kerning(resolvedKerning)
        
        // Apply tracking if set
        if let tracking = config.tracking {
            textView = textView.tracking(tracking)
        }
        
        // Apply baseline offset
        if let offset = config.baselineOffset {
            textView = textView.baselineOffset(offset)
        }
        
        // Apply underline
        if config.underline.isActive {
            textView = textView.underline(true, pattern: config.underline.pattern, color: config.underline.color)
        }
        
        // Apply strikethrough
        if config.strikethrough.isActive {
            textView = textView.strikethrough(true, pattern: config.strikethrough.pattern, color: config.strikethrough.color)
        }
        
        return textView
    }
    
    // MARK: - Resolved Values
    
    private var resolvedFont: Font {
        let size = resolvedFontSize
        let design = resolvedDesign
        let weight = resolvedWeight
        
        if config.isMonospace {
            if let fontName = typography.monoFontFamily.name {
                return .custom(fontName, size: size)
            } else {
                return .system(size: size, weight: weight, design: .monospaced)
            }
        }
        
        if let fontName = typography.fontFamily.name {
            return .custom(fontName, size: size)
        } else {
            return .system(size: size, weight: weight, design: design)
        }
    }
    
    private var resolvedDesign: Font.Design {
        config.fontDesign ?? .default
    }
    
    /// Whether we're using a custom font family from typography (vs system font)
    private var usesCustomFontFamily: Bool {
        if config.isMonospace {
            return typography.monoFontFamily.name != nil
        }
        return typography.fontFamily.name != nil
    }
    
    private var resolvedFontSize: CGFloat {
        // Custom font size takes precedence
        if let customSize = config.fontSize {
            return customSize
        }
        return styleFontSize
    }
    
    private var styleFontSize: CGFloat {
        switch config.style {
        case .display:
            return typography.sizes.display
        case .headline:
            return typography.sizes.xxxl - 2 // 28pt
        case .title:
            return typography.sizes.xxl - 2 // 22pt
        case .bodyLarge:
            return typography.sizes.lg
        case .body:
            return typography.sizes.base
        case .caption:
            return typography.sizes.sm
        case .small:
            return typography.sizes.xs
        }
    }
    
    private var resolvedWeight: Font.Weight {
        if let customWeight = config.weight {
            return customWeight
        }
        
        switch config.style {
        case .display, .headline:
            return .bold
        case .title:
            return .semibold
        case .bodyLarge, .body, .caption:
            return .regular
        case .small:
            return .medium
        }
    }
    
    private var resolvedColor: Color {
        // Priority: customColor > colorToken > PTextColor
        if let customColor = config.customColor {
            return customColor
        }
        
        if let token = config.colorToken {
            return token.resolve(from: colors)
        }
        
        switch config.color {
        case .primary:
            return colors.foreground
        case .secondary:
            return colors.secondaryForeground
        case .muted:
            return colors.mutedForeground
        case .destructive:
            return colors.destructive
        case .success:
            return colors.success
        case .warning:
            return colors.warning
        case .accent:
            return colors.primary
        case .custom(let color):
            return color
        }
    }
    
    private var resolvedKerning: CGFloat {
        if let customKerning = config.kerning {
            return customKerning
        }
        
        // Family.co uses tight letter spacing for headlines
        switch config.style {
        case .display:
            return typography.letterSpacing.tighter
        case .headline:
            return typography.letterSpacing.tight
        case .title:
            return typography.letterSpacing.tight
        case .small:
            return typography.letterSpacing.wide
        default:
            return typography.letterSpacing.normal
        }
    }
    
    private var resolvedLineSpacing: CGFloat {
        if let customSpacing = config.lineSpacing {
            return customSpacing
        }
        
        // Calculate line spacing based on style
        let lineHeight: CGFloat
        switch config.style {
        case .display:
            lineHeight = typography.lineHeights.tight
        case .headline, .title:
            lineHeight = typography.lineHeights.tight
        case .bodyLarge, .body:
            lineHeight = typography.lineHeights.normal
        case .caption:
            lineHeight = typography.lineHeights.normal
        case .small:
            lineHeight = typography.lineHeights.tight
        }
        
        // Convert line height multiplier to actual spacing
        return (lineHeight - 1) * resolvedFontSize * 0.5
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PText {
    
    /// Set the text style
    func style(_ style: PTextStyle) -> PText {
        var newConfig = config
        newConfig.style = style
        return PText(text: text, config: newConfig)
    }
    
    /// Set the text color using PTextColor presets
    /// - Parameter color: PTextColor preset (.primary, .secondary, .muted, etc.)
    func color(_ color: PTextColor) -> PText {
        var newConfig = config
        newConfig.color = color
        newConfig.colorToken = nil
        newConfig.customColor = nil
        return PText(text: text, config: newConfig)
    }
    
    /// Set the text color using a ColorToken
    /// - Parameter token: ColorToken that resolves from the current theme
    ///
    /// Example:
    /// ```swift
    /// PText("Muted Text")
    ///     .color(.mutedForeground)
    ///
    /// PText("Primary Color")
    ///     .color(.primary)
    /// ```
    func color(_ token: ColorToken) -> PText {
        var newConfig = config
        newConfig.colorToken = token
        newConfig.customColor = nil
        return PText(text: text, config: newConfig)
    }
    
    /// Set the text color using any SwiftUI Color
    /// - Parameter color: Any SwiftUI Color
    ///
    /// Example:
    /// ```swift
    /// PText("Custom Color")
    ///     .foregroundColor(Color.blue)
    /// ```
    func foregroundColor(_ color: Color) -> PText {
        var newConfig = config
        newConfig.customColor = color
        return PText(text: text, config: newConfig)
    }
    
    /// Set the font weight
    func weight(_ weight: Font.Weight) -> PText {
        var newConfig = config
        newConfig.weight = weight
        return PText(text: text, config: newConfig)
    }
    
    /// Set the font weight (SwiftUI-style modifier name)
    /// - Parameter weight: The font weight to apply
    func fontWeight(_ weight: Font.Weight) -> PText {
        self.weight(weight)
    }
    
    /// Set the font design
    /// - Parameter design: The font design (default, rounded, serif, monospaced)
    ///
    /// Example:
    /// ```swift
    /// PText("Rounded Design")
    ///     .fontDesign(.rounded)
    /// ```
    func fontDesign(_ design: Font.Design) -> PText {
        var newConfig = config
        newConfig.fontDesign = design
        return PText(text: text, config: newConfig)
    }
    
    /// Set a custom font size
    /// - Parameter size: The font size in points
    ///
    /// This overrides the size from the text style while keeping other style properties.
    func fontSize(_ size: CGFloat) -> PText {
        var newConfig = config
        newConfig.fontSize = size
        return PText(text: text, config: newConfig)
    }
    
    /// Configure font with size, weight, and design in one call
    /// - Parameters:
    ///   - size: The font size in points
    ///   - weight: The font weight (optional)
    ///   - design: The font design (optional)
    ///
    /// Example:
    /// ```swift
    /// PText("Custom Font")
    ///     .systemFont(size: 28, weight: .semibold, design: .rounded)
    /// ```
    func systemFont(size: CGFloat, weight: Font.Weight? = nil, design: Font.Design? = nil) -> PText {
        var newConfig = config
        newConfig.fontSize = size
        if let weight = weight {
            newConfig.weight = weight
        }
        if let design = design {
            newConfig.fontDesign = design
        }
        return PText(text: text, config: newConfig)
    }
    
    /// Use monospace font (for code, addresses, etc.)
    func mono(_ isMonospace: Bool = true) -> PText {
        var newConfig = config
        newConfig.isMonospace = isMonospace
        return PText(text: text, config: newConfig)
    }
    
    /// Set custom line spacing
    func lineSpacing(_ spacing: CGFloat) -> PText {
        var newConfig = config
        newConfig.lineSpacing = spacing
        return PText(text: text, config: newConfig)
    }
    
    /// Set custom letter spacing (kerning)
    func kerning(_ kerning: CGFloat) -> PText {
        var newConfig = config
        newConfig.kerning = kerning
        return PText(text: text, config: newConfig)
    }
    
    /// Set text alignment
    func alignment(_ alignment: TextAlignment) -> PText {
        var newConfig = config
        newConfig.alignment = alignment
        return PText(text: text, config: newConfig)
    }
    
    /// Set maximum number of lines
    func lineLimit(_ limit: Int?) -> PText {
        var newConfig = config
        newConfig.lineLimit = limit
        return PText(text: text, config: newConfig)
    }
    
    /// Set truncation mode
    func truncationMode(_ mode: Text.TruncationMode) -> PText {
        var newConfig = config
        newConfig.truncationMode = mode
        return PText(text: text, config: newConfig)
    }
    
    // MARK: - Font Modifier
    
    /// Override the font entirely with a custom SwiftUI Font
    /// - Parameter font: The custom font to use (overrides style-based font)
    func font(_ font: Font) -> PText {
        var newConfig = config
        newConfig.customFont = font
        return PText(text: text, config: newConfig)
    }
    
    // MARK: - Text Style Modifiers
    
    /// Make the text bold
    func bold(_ isActive: Bool = true) -> PText {
        var newConfig = config
        newConfig.isBold = isActive
        return PText(text: text, config: newConfig)
    }
    
    /// Make the text italic
    func italic(_ isActive: Bool = true) -> PText {
        var newConfig = config
        newConfig.isItalic = isActive
        return PText(text: text, config: newConfig)
    }
    
    /// Add underline to the text
    /// - Parameters:
    ///   - isActive: Whether the underline is visible
    ///   - pattern: The line pattern (solid, dash, dot, etc.)
    ///   - color: Optional custom color for the underline
    func underline(_ isActive: Bool = true, pattern: Text.LineStyle.Pattern = .solid, color: Color? = nil) -> PText {
        var newConfig = config
        newConfig.underline = PTextUnderlineStyle(isActive: isActive, pattern: pattern, color: color)
        return PText(text: text, config: newConfig)
    }
    
    /// Add strikethrough to the text
    /// - Parameters:
    ///   - isActive: Whether the strikethrough is visible
    ///   - pattern: The line pattern (solid, dash, dot, etc.)
    ///   - color: Optional custom color for the strikethrough
    func strikethrough(_ isActive: Bool = true, pattern: Text.LineStyle.Pattern = .solid, color: Color? = nil) -> PText {
        var newConfig = config
        newConfig.strikethrough = PTextStrikethroughStyle(isActive: isActive, pattern: pattern, color: color)
        return PText(text: text, config: newConfig)
    }
    
    /// Set the baseline offset for the text
    /// - Parameter offset: The vertical offset (positive = up, negative = down)
    func baselineOffset(_ offset: CGFloat) -> PText {
        var newConfig = config
        newConfig.baselineOffset = offset
        return PText(text: text, config: newConfig)
    }
    
    /// Set the tracking (character spacing) for the text
    /// - Parameter tracking: The tracking amount in points
    func tracking(_ tracking: CGFloat) -> PText {
        var newConfig = config
        newConfig.tracking = tracking
        return PText(text: text, config: newConfig)
    }
    
    // MARK: - Text Case Modifiers
    
    /// Set the text case transformation
    /// - Parameter textCase: The case transformation to apply
    func textCase(_ textCase: Text.Case?) -> PText {
        var newConfig = config
        newConfig.textCase = textCase
        return PText(text: text, config: newConfig)
    }
    
    /// Transform text to uppercase
    func uppercase() -> PText {
        textCase(.uppercase)
    }
    
    /// Transform text to lowercase
    func lowercase() -> PText {
        textCase(.lowercase)
    }
    
    // MARK: - Scaling Modifiers
    
    /// Set the minimum scale factor for text fitting
    /// - Parameter factor: The minimum scale factor (0.0 to 1.0)
    func minimumScaleFactor(_ factor: CGFloat) -> PText {
        var newConfig = config
        newConfig.minimumScaleFactor = factor
        return PText(text: text, config: newConfig)
    }
    
    /// Allow text to tighten character spacing to fit
    /// - Parameter allows: Whether tightening is allowed
    func allowsTightening(_ allows: Bool = true) -> PText {
        var newConfig = config
        newConfig.allowsTightening = allows
        return PText(text: text, config: newConfig)
    }
}

// MARK: - Convenience Initializers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PText {
    
    /// Create a display text
    static func display(_ text: String) -> PText {
        PText(text).style(.display)
    }
    
    /// Create a headline text
    static func headline(_ text: String) -> PText {
        PText(text).style(.headline)
    }
    
    /// Create a title text
    static func title(_ text: String) -> PText {
        PText(text).style(.title)
    }
    
    /// Create body text
    static func body(_ text: String) -> PText {
        PText(text).style(.body)
    }
    
    /// Create caption text
    static func caption(_ text: String) -> PText {
        PText(text).style(.caption)
    }
    
    /// Create small text
    static func small(_ text: String) -> PText {
        PText(text).style(.small)
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PText_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Type Scale
                Group {
                    Text("Type Scale")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PText("Display Text")
                            .style(.display)
                        
                        PText("Headline Text")
                            .style(.headline)
                        
                        PText("Title Text")
                            .style(.title)
                        
                        PText("Body Large Text")
                            .style(.bodyLarge)
                        
                        PText("Body Text")
                            .style(.body)
                        
                        PText("Caption Text")
                            .style(.caption)
                        
                        PText("Small Text")
                            .style(.small)
                    }
                }
                
                Divider()
                
                // Colors
                Group {
                    Text("Colors")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("Primary Color")
                            .color(PTextColor.primary)
                        
                        PText("Secondary Color")
                            .color(PTextColor.secondary)
                        
                        PText("Muted Color")
                            .color(PTextColor.muted)
                        
                        PText("Accent Color")
                            .color(PTextColor.accent)
                        
                        PText("Destructive Color")
                            .color(PTextColor.destructive)
                        
                        PText("Success Color")
                            .color(PTextColor.success)
                        
                        PText("Warning Color")
                            .color(PTextColor.warning)
                    }
                }
                
                Divider()
                
                // Text Decorations
                Group {
                    Text("Text Decorations")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("Bold Text")
                            .bold()
                        
                        PText("Italic Text")
                            .italic()
                        
                        PText("Bold & Italic")
                            .bold()
                            .italic()
                        
                        PText("Underlined Text")
                            .underline()
                        
                        PText("Dashed Underline")
                            .underline(pattern: .dash, color: .blue)
                        
                        PText("Strikethrough Text")
                            .strikethrough()
                        
                        PText("Strikethrough with Color")
                            .strikethrough(color: .red)
                    }
                }
                
                Divider()
                
                // Font Override
                Group {
                    Text("Custom Font Override")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("Custom System Font")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                        
                        PText("Serif Design")
                            .font(.system(size: 18, design: .serif))
                        
                        PText("Large Title Font")
                            .font(.largeTitle)
                            .color(PTextColor.accent)
                    }
                }
                
                Divider()
                
                // Font Design & Weight
                Group {
                    Text("Font Design & Weight Modifiers")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("Rounded Design")
                            .fontDesign(.rounded)
                            .fontSize(24)
                            .fontWeight(.semibold)
                        
                        PText("Serif Design")
                            .fontDesign(.serif)
                            .fontSize(20)
                        
                        PText("System Font Helper")
                            .systemFont(size: 28, weight: .semibold, design: .rounded)
                        
                        PText("Custom Size with Style")
                            .style(.headline)
                            .fontSize(32)
                            .fontDesign(.rounded)
                        
                        PText("Font Weight Modifier")
                            .fontWeight(.heavy)
                    }
                }
                
                Divider()
                
                // Text Case
                Group {
                    Text("Text Case")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("uppercase text")
                            .uppercase()
                        
                        PText("LOWERCASE TEXT")
                            .lowercase()
                    }
                }
                
                Divider()
                
                // Monospace
                Group {
                    Text("Monospace")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("0x1234...abcd")
                            .style(.caption)
                            .mono()
                            .color(PTextColor.muted)
                        
                        PText("func createWallet() { }")
                            .style(.body)
                            .mono()
                    }
                }
                
                Divider()
                
                // Tracking & Baseline
                Group {
                    Text("Tracking & Baseline")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText("Wide Tracking")
                            .tracking(4)
                        
                        PText("Tight Tracking")
                            .tracking(-1)
                        
                        HStack(alignment: .firstTextBaseline) {
                            PText("Normal")
                            PText("Raised")
                                .baselineOffset(8)
                                .style(.small)
                                .color(PTextColor.accent)
                        }
                    }
                }
                
                Divider()
                
                // Static Initializers
                Group {
                    Text("Static Initializers")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        PText.headline("Headline Helper")
                        PText.caption("Caption Helper")
                            .color(PTextColor.muted)
                    }
                }
                
                Divider()
                
                // Family-style example
                Group {
                    Text("Family Style Example")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        PText("Create a New Wallet")
                            .style(.title)
                        
                        PText("Secure your assets with a new wallet. It only takes a minute to set up.")
                            .style(.body)
                            .color(PTextColor.muted)
                            .lineLimit(2)
                    }
                }
            }
            .padding()
        }
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode")
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PText("Welcome Back")
                    .style(.display)
                
                PText("Your wallet is ready")
                    .style(.body)
                    .color(PTextColor.muted)
                
                PText("$12,345.67")
                    .style(.headline)
                    .mono()
                    .bold()
                
                PText("Limited Time Offer")
                    .style(.caption)
                    .uppercase()
                    .tracking(2)
                    .color(PTextColor.accent)
            }
            .padding()
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif


