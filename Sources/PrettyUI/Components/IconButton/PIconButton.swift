//
//  PIconButton.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired circular icon button component with fluent modifier API.
//

import SwiftUI

// MARK: - Icon Button Configuration

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PIconButtonConfiguration {
    var variant: PButtonVariant = .ghost
    var size: PIconButtonSize = .md
    var isDisabled: Bool = false
    var hapticFeedback: Bool = true
    var customBackground: Color? = nil
    var customForeground: Color? = nil
    var backgroundToken: ColorToken? = nil
    var foregroundToken: ColorToken? = nil
    var customSize: CGFloat? = nil
    var fontWeight: Font.Weight = .medium
    
    public enum PIconButtonSize {
        case sm   // 32pt
        case md   // 40pt
        case lg   // 48pt
        case xl   // 56pt
        case custom(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .sm: return 32
            case .md: return 40
            case .lg: return 48
            case .xl: return 56
            case .custom(let size): return size
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .sm: return 14
            case .md: return 17
            case .lg: return 20
            case .xl: return 24
            case .custom(let size): return size * 0.45
            }
        }
    }
}

// MARK: - Icon-Only Button

/// A circular icon button component inspired by Family.co's design system.
///
/// Uses a fluent modifier API for configuration:
/// ```swift
/// PIconButton("plus")
///     .variant(.primary)
///     .size(.lg)
/// ```
///
/// Common patterns:
/// ```swift
/// // Close button
/// PIconButton("xmark")
///     .variant(.ghost)
///
/// // Settings button
/// PIconButton("gearshape")
///     .variant(.secondary)
///
/// // Add button
/// PIconButton("plus")
///     .variant(.primary)
///     .size(.lg)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PIconButton: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let systemName: String
    private let action: () -> Void
    private var config: PIconButtonConfiguration
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    // MARK: - Initializer
    
    public init(_ systemName: String, action: @escaping () -> Void = {}) {
        self.systemName = systemName
        self.action = action
        self.config = PIconButtonConfiguration()
    }
    
    private init(systemName: String, action: @escaping () -> Void, config: PIconButtonConfiguration) {
        self.systemName = systemName
        self.action = action
        self.config = config
    }
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var isButtonDisabled: Bool {
        !isEnabled || config.isDisabled
    }
    
    private var pressAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: handleAction) {
            Image(systemName: systemName)
                .font(.system(size: config.size.iconSize, weight: config.fontWeight))
                .foregroundColor(foregroundColor)
                .frame(width: buttonSize, height: buttonSize)
                .background(background)
                .clipShape(Circle())
                .overlay(borderOverlay)
                .scaleEffect(isPressed ? 0.92 : 1.0)
                .brightness(brightnessEffect)
                .opacity(isButtonDisabled ? 0.95 : 1)
                .animation(pressAnimation, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isButtonDisabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressed { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
        #if os(macOS)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        #endif
    }
    
    // MARK: - Sizing
    
    private var buttonSize: CGFloat {
        config.customSize ?? config.size.value
    }
    
    // MARK: - Colors
    
    private var backgroundColor: Color {
        // Priority: customBackground > backgroundToken > variant default
        if let custom = config.customBackground {
            return custom
        }
        if let token = config.backgroundToken {
            return token.resolve(from: colors)
        }
        switch config.variant {
        case .primary: return colors.primary
        case .secondary: return colors.secondary
        case .destructive: return colors.destructive
        case .outline: return colors.card
        case .ghost, .link: return .clear
        }
    }
    
    private var foregroundColor: Color {
        // Priority: customForeground > foregroundToken > variant default
        if let custom = config.customForeground {
            return custom
        }
        if let token = config.foregroundToken {
            return token.resolve(from: colors)
        }
        switch config.variant {
        case .primary: return colors.primaryForeground
        case .secondary: return colors.secondaryForeground
        case .destructive: return colors.destructiveForeground
        case .outline, .ghost: return colors.foreground
        case .link: return colors.primary
        }
    }
    
    /// Whether a custom background (Color or Token) is set
    private var hasCustomBackground: Bool {
        config.customBackground != nil || config.backgroundToken != nil
    }
    
    @ViewBuilder
    private var background: some View {
        // Use resolved backgroundColor which handles custom/token/variant
        if hasCustomBackground {
            if isPressed {
                backgroundColor.opacity(0.85)
            } else {
                backgroundColor
            }
        } else if isPressed {
            switch config.variant {
            case .ghost:
                colors.muted.opacity(0.6)
            case .link:
                Color.clear
            default:
                backgroundColor.opacity(0.85)
            }
        } else if isHovered {
            switch config.variant {
            case .ghost:
                colors.muted.opacity(0.4)
            default:
                backgroundColor
            }
        } else {
            switch config.variant {
            case .ghost, .link:
                Color.clear
            default:
                backgroundColor
            }
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        if config.variant == .outline {
            Circle().stroke(colors.border, lineWidth: 1.5)
        }
    }
    
    private var brightnessEffect: Double {
        #if os(macOS)
        return isHovered && !isPressed ? 0.05 : 0
        #else
        return 0
        #endif
    }
    
    // MARK: - Actions
    
    private func handleAction() {
        #if os(iOS)
        if config.hapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        #endif
        action()
    }
}

// MARK: - PIconButton Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PIconButton {
    
    /// Set the button variant
    func variant(_ variant: PButtonVariant) -> PIconButton {
        var newConfig = config
        newConfig.variant = variant
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set the button size
    func size(_ size: PIconButtonConfiguration.PIconButtonSize) -> PIconButton {
        var newConfig = config
        newConfig.size = size
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Disable the button
    func disabled() -> PIconButton {
        var newConfig = config
        newConfig.isDisabled = true
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Enable the button
    func enabled() -> PIconButton {
        var newConfig = config
        newConfig.isDisabled = false
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set custom background color
    func background(_ color: Color) -> PIconButton {
        var newConfig = config
        newConfig.customBackground = color
        newConfig.backgroundToken = nil
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set background color using a ColorToken
    func background(_ token: ColorToken) -> PIconButton {
        var newConfig = config
        newConfig.backgroundToken = token
        newConfig.customBackground = nil
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set custom foreground (icon) color
    func foreground(_ color: Color) -> PIconButton {
        var newConfig = config
        newConfig.customForeground = color
        newConfig.foregroundToken = nil
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set foreground color using a ColorToken
    func foreground(_ token: ColorToken) -> PIconButton {
        var newConfig = config
        newConfig.foregroundToken = token
        newConfig.customForeground = nil
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set custom colors using Color
    func colors(background: Color, foreground: Color) -> PIconButton {
        var newConfig = config
        newConfig.customBackground = background
        newConfig.customForeground = foreground
        newConfig.backgroundToken = nil
        newConfig.foregroundToken = nil
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set colors using ColorTokens
    func colors(background: ColorToken, foreground: ColorToken) -> PIconButton {
        var newConfig = config
        newConfig.backgroundToken = background
        newConfig.foregroundToken = foreground
        newConfig.customBackground = nil
        newConfig.customForeground = nil
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set custom button size
    func frame(_ size: CGFloat) -> PIconButton {
        var newConfig = config
        newConfig.customSize = size
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Set font weight for the icon
    func fontWeight(_ weight: Font.Weight) -> PIconButton {
        var newConfig = config
        newConfig.fontWeight = weight
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
    
    /// Enable or disable haptic feedback
    func haptics(_ enabled: Bool) -> PIconButton {
        var newConfig = config
        newConfig.hapticFeedback = enabled
        return PIconButton(systemName: systemName, action: action, config: newConfig)
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PIconButton_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Variants
                Group {
                    Text("Variants")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            PIconButton("plus") {}.variant(.primary)
                            Text("Primary").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("gearshape") {}.variant(.secondary)
                            Text("Secondary").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("heart.fill") {}.variant(.outline)
                            Text("Outline").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("xmark") {}.variant(.ghost)
                            Text("Ghost").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("trash") {}.variant(.destructive)
                            Text("Destructive").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // Sizes
                Group {
                    Text("Sizes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            PIconButton("star.fill") {}.size(.sm).variant(.primary)
                            Text("SM (32)").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("star.fill") {}.size(.md).variant(.primary)
                            Text("MD (40)").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("star.fill") {}.size(.lg).variant(.primary)
                            Text("LG (48)").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("star.fill") {}.size(.xl).variant(.primary)
                            Text("XL (56)").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // Custom Colors
                Group {
                    Text("Custom Colors")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        PIconButton("bell.fill") {}
                            .background(Color.purple)
                            .foreground(.white)
                        
                        PIconButton("bookmark.fill") {}
                            .background(Color.orange)
                            .foreground(.white)
                        
                        PIconButton("leaf.fill") {}
                            .background(Color.green)
                            .foreground(.white)
                        
                        PIconButton("bolt.fill") {}
                            .background(Color.yellow)
                            .foreground(.black)
                    }
                }
                
                Divider()
                
                // Common Patterns
                Group {
                    Text("Common Patterns")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 24) {
                        VStack(spacing: 4) {
                            PIconButton("xmark") {}.variant(.ghost)
                            Text("Close").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("chevron.left") {}.variant(.ghost)
                            Text("Back").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("ellipsis") {}.variant(.ghost)
                            Text("More").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("square.and.arrow.up") {}.variant(.ghost)
                            Text("Share").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // States
                Group {
                    Text("States")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            PIconButton("heart.fill") {}.variant(.primary)
                            Text("Normal").font(.caption)
                        }
                        VStack(spacing: 4) {
                            PIconButton("heart.fill") {}.variant(.primary).disabled()
                            Text("Disabled").font(.caption)
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F8F9FA"))
        .prettyTheme(.sky)
        .previewDisplayName("Icon Buttons")
    }
}
#endif

