//
//  PButton.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired button component with fluent modifier API.
//  Uses ButtonStyle for proper scroll support with bouncy press animations.
//

import SwiftUI

// MARK: - Button Configuration

/// Configuration for PButton styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PButtonConfiguration {
    var variant: PButtonVariant = .primary
    var size: PButtonSize = .lg
    var radius: RadiusSize = .full
    var isFullWidth: Bool = false
    var isLoading: Bool = false
    var loadingText: String? = nil
    var loadingPosition: LoadingPosition = .leading
    var hideTextWhenLoading: Bool = false
    var hapticFeedback: Bool = true
    var icon: String? = nil
    var iconPosition: IconPosition = .leading
    var isDisabled: Bool = false
    
    // Custom styling
    var customBackground: Color? = nil
    var customForeground: Color? = nil
    var customWidth: CGFloat? = nil
    var customHeight: CGFloat? = nil
    var fontWeight: Font.Weight = .semibold
    var spinnerStyle: PSpinnerStyle = .circular
    var spinnerSize: PSpinnerSize? = nil
    
    public enum IconPosition {
        case leading
        case trailing
    }
    
    public enum LoadingPosition {
        case leading
        case trailing
        case replace
    }
}

// MARK: - Button Animation Constants

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
fileprivate struct PButtonAnimationConfig {
    static let scaleEffect: CGFloat = 0.96
    static let pressResponse: Double = 0.2
    static let pressDamping: Double = 0.7
    static let releaseResponse: Double = 0.35
    static let releaseDamping: Double = 0.55
    static let minimumPressDuration: Double = 0.08
}

// MARK: - PButton Button Style

/// Custom button style that provides Family.co-style press animations with proper scroll support.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
fileprivate struct PButtonStyle: ButtonStyle {
    let theme: PrettyTheme
    let colorScheme: ColorScheme
    let config: PButtonConfiguration
    let reduceMotion: Bool
    let showPressAnimation: Bool
    @Binding var isHovered: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        PButtonContent(
            theme: theme,
            colorScheme: colorScheme,
            config: config,
            reduceMotion: reduceMotion,
            showPressAnimation: showPressAnimation,
            isSystemPressed: configuration.isPressed,
            isHovered: isHovered,
            label: configuration.label
        )
    }
}

/// Internal view that manages button animation state with minimum press duration.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
fileprivate struct PButtonContent<Label: View>: View {
    let theme: PrettyTheme
    let colorScheme: ColorScheme
    let config: PButtonConfiguration
    let reduceMotion: Bool
    let showPressAnimation: Bool
    let isSystemPressed: Bool
    let isHovered: Bool
    let label: Label
    
    // Track visual press state separately to implement minimum duration
    @State private var isVisuallyPressed = false
    @State private var pressStartTime: Date?
    @State private var releaseTask: Task<Void, Never>?
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
    // MARK: - Animations
    
    private var pressAnimation: Animation {
        .spring(response: PButtonAnimationConfig.pressResponse, dampingFraction: PButtonAnimationConfig.pressDamping)
    }
    
    private var releaseAnimation: Animation {
        .spring(response: PButtonAnimationConfig.releaseResponse, dampingFraction: PButtonAnimationConfig.releaseDamping)
    }
    
    // MARK: - Visual Effects
    
    private var scaleEffect: CGFloat {
        guard showPressAnimation else { return 1 }
        return isVisuallyPressed ? PButtonAnimationConfig.scaleEffect : 1.0
    }
    
    private var brightnessEffect: Double {
        #if os(macOS)
        return isHovered && !isVisuallyPressed ? 0.05 : 0
        #else
        return 0
        #endif
    }
    
    var body: some View {
        label
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
            .overlay(border)
            .scaleEffect(scaleEffect)
            .brightness(brightnessEffect)
            .animation(isVisuallyPressed ? pressAnimation : releaseAnimation, value: isVisuallyPressed)
            .onChange(of: isSystemPressed) { pressed in
                handlePressChange(pressed)
            }
    }
    
    // MARK: - Press State Management
    
    private func handlePressChange(_ pressed: Bool) {
        // Cancel any pending release
        releaseTask?.cancel()
        releaseTask = nil
        
        if pressed {
            // Finger down - immediately show pressed state
            pressStartTime = Date()
            if !reduceMotion && showPressAnimation {
                withAnimation(pressAnimation) {
                    isVisuallyPressed = true
                }
            }
        } else {
            // Finger up
            let startTime = pressStartTime ?? Date()
            pressStartTime = nil
            
            if reduceMotion || !showPressAnimation {
                isVisuallyPressed = false
                return
            }
            
            // Calculate remaining time to meet minimum duration
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = max(0, PButtonAnimationConfig.minimumPressDuration - elapsed)
            
            if remaining > 0 {
                // Delay release to ensure minimum visible duration
                releaseTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    withAnimation(releaseAnimation) {
                        isVisuallyPressed = false
                    }
                }
            } else {
                // Already met minimum duration
                withAnimation(releaseAnimation) {
                    isVisuallyPressed = false
                }
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundColor: Color {
        if let custom = config.customBackground {
            return custom
        }
        switch config.variant {
        case .primary:
            return colors.primary
        case .secondary:
            return colors.secondary
        case .destructive:
            return colors.destructive
        case .outline:
            return colors.card
        case .ghost, .link:
            return .clear
        }
    }
    
    @ViewBuilder
    private var background: some View {
        if isVisuallyPressed && showPressAnimation {
            switch config.variant {
            case .ghost:
                colors.muted.opacity(0.5)
            case .link:
                Color.clear
            default:
                backgroundColor.opacity(0.9)
            }
        } else if isHovered {
            switch config.variant {
            case .ghost:
                colors.muted.opacity(0.3)
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
    private var border: some View {
        switch config.variant {
        case .outline:
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .stroke(colors.border, lineWidth: 1.5)
        default:
            EmptyView()
        }
    }
}

// MARK: - PButton

/// A customizable button component inspired by Family.co's design system.
/// Uses ButtonStyle for proper scroll support with bouncy press animations.
///
/// Uses a fluent modifier API for configuration:
/// ```swift
/// PButton("Create Wallet")
///     .variant(.primary)
///     .icon("plus.circle.fill")
///     .fullWidth()
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PButton: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    private let title: String
    private let action: () -> Void
    private var config: PButtonConfiguration
    
    // MARK: - State
    
    @State private var isHovered = false
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var buttonConfig: ButtonConfig {
        theme.components.button
    }
    
    // MARK: - Initializer
    
    /// Create a button with a title
    /// - Parameters:
    ///   - title: Button text
    ///   - action: Closure to execute on tap
    public init(_ title: String, action: @escaping () -> Void = {}) {
        self.title = title
        self.action = action
        self.config = PButtonConfiguration()
    }
    
    // Private init for modifiers
    private init(title: String, action: @escaping () -> Void, config: PButtonConfiguration) {
        self.title = title
        self.action = action
        self.config = config
    }
    
    // MARK: - Body
    
    private var isButtonDisabled: Bool {
        !isEnabled || config.isLoading || config.isDisabled
    }
    
    public var body: some View {
        Button(action: handleAction) {
            labelContent
        }
        .buttonStyle(PButtonStyle(
            theme: theme,
            colorScheme: colorScheme,
            config: config,
            reduceMotion: reduceMotion,
            showPressAnimation: buttonConfig.showPressAnimation,
            isHovered: $isHovered
        ))
        .disabled(isButtonDisabled)
        .opacity(isButtonDisabled ? 0.6 : 1)
        #if os(macOS)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        #endif
    }
    
    @ViewBuilder
    private var labelContent: some View {
        HStack(spacing: 8) {
            // Leading loading spinner
            if config.isLoading && config.loadingPosition == .leading {
                loadingSpinner
            }
            
            // Leading icon (hidden during loading if position is replace)
            if let icon = config.icon, config.iconPosition == .leading {
                if !config.isLoading || config.loadingPosition != .replace {
                    Image(systemName: icon)
                }
            }
            
            // Text content
            if config.isLoading && config.loadingPosition == .replace {
                // Replace mode: show spinner instead of text
                loadingSpinner
            } else if !config.hideTextWhenLoading || !config.isLoading {
                Text(displayText)
            }
            
            // Trailing icon (hidden during loading if position is replace)
            if let icon = config.icon, config.iconPosition == .trailing {
                if !config.isLoading || config.loadingPosition != .replace {
                    Image(systemName: icon)
                }
            }
            
            // Trailing loading spinner
            if config.isLoading && config.loadingPosition == .trailing {
                loadingSpinner
            }
        }
        .font(font)
        .fontWeight(config.fontWeight)
        .foregroundColor(config.customForeground ?? foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(width: config.customWidth, height: config.customHeight)
        .frame(maxWidth: config.isFullWidth ? .infinity : nil)
        .frame(minWidth: config.customWidth ?? minWidth, minHeight: config.customHeight ?? minHeight)
    }
    
    private var displayText: String {
        if config.isLoading, let loadingText = config.loadingText {
            return loadingText
        }
        return title
    }
    
    @ViewBuilder
    private var loadingSpinner: some View {
        PSpinner()
            .size(config.spinnerSize ?? theme.components.button.defaultSpinnerSize)
            .style(config.spinnerStyle)
            .color(config.customForeground ?? foregroundColor)
    }
    
    // MARK: - Color Styling
    
    private var foregroundColor: Color {
        switch config.variant {
        case .primary:
            return colors.primaryForeground
        case .secondary:
            return colors.secondaryForeground
        case .destructive:
            return colors.destructiveForeground
        case .outline, .ghost:
            return colors.foreground
        case .link:
            return colors.primary
        }
    }
    
    // MARK: - Typography
    
    private var font: Font {
        switch config.size {
        case .sm:
            return .system(size: 15)
        case .md:
            return .system(size: 17)
        case .lg:
            return .system(size: 19)
        case .icon:
            return .system(size: 17)
        }
    }
    
    // MARK: - Sizing
    
    private var horizontalPadding: CGFloat {
        switch config.size {
        case .sm: return theme.spacing.md
        case .md: return theme.spacing.lg
        case .lg: return theme.spacing.lg
        case .icon: return theme.spacing.sm
        }
    }
    
    private var verticalPadding: CGFloat {
        switch config.size {
        case .sm: return theme.spacing.xs
        case .md: return theme.spacing.sm
        case .lg: return theme.spacing.sm
        case .icon: return theme.spacing.xs
        }
    }
    
    private var minWidth: CGFloat {
        config.size == .icon ? minHeight : 0
    }
    
    private var minHeight: CGFloat {
        switch config.size {
        case .sm: return 36
        case .md: return 44
        case .lg: return 52
        case .icon: return 40
        }
    }
    
    private var progressScale: CGFloat {
        switch config.size {
        case .sm: return 0.6
        case .md: return 0.7
        case .lg: return 0.8
        case .icon: return 0.7
        }
    }
    
    // MARK: - Actions
    
    private func handleAction() {
        guard !config.isLoading else { return }
        
        #if os(iOS)
        if config.hapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        #endif
        
        action()
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PButton {
    
    /// Set the button variant
    func variant(_ variant: PButtonVariant) -> PButton {
        var newConfig = config
        newConfig.variant = variant
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set the button size
    func size(_ size: PButtonSize) -> PButton {
        var newConfig = config
        newConfig.size = size
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set the corner radius
    func radius(_ radius: RadiusSize) -> PButton {
        var newConfig = config
        newConfig.radius = radius
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Make the button full width
    func fullWidth(_ isFullWidth: Bool = true) -> PButton {
        var newConfig = config
        newConfig.isFullWidth = isFullWidth
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set loading state
    func loading(_ isLoading: Bool = true) -> PButton {
        var newConfig = config
        newConfig.isLoading = isLoading
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set loading state with custom loading text
    func loading(_ isLoading: Bool = true, text: String) -> PButton {
        var newConfig = config
        newConfig.isLoading = isLoading
        newConfig.loadingText = text
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set the loading spinner position
    func loadingPosition(_ position: PButtonConfiguration.LoadingPosition) -> PButton {
        var newConfig = config
        newConfig.loadingPosition = position
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Hide button text when loading (show only spinner)
    func hideTextWhenLoading(_ hide: Bool = true) -> PButton {
        var newConfig = config
        newConfig.hideTextWhenLoading = hide
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set the spinner style (circular, dots, track, minimal, orbit)
    func spinnerStyle(_ style: PSpinnerStyle) -> PButton {
        var newConfig = config
        newConfig.spinnerStyle = style
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set spinner size (sm, md, lg, xl)
    func spinnerSize(_ size: PSpinnerSize) -> PButton {
        var newConfig = config
        newConfig.spinnerSize = size
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Disable the button
    func disabled() -> PButton {
        var newConfig = config
        newConfig.isDisabled = true
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Enable the button
    func enabled() -> PButton {
        var newConfig = config
        newConfig.isDisabled = false
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Add an icon to the button
    func icon(_ systemName: String) -> PButton {
        var newConfig = config
        newConfig.icon = systemName
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set the icon position
    func iconPosition(_ position: PButtonConfiguration.IconPosition) -> PButton {
        var newConfig = config
        newConfig.iconPosition = position
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Enable or disable haptic feedback
    func haptics(_ enabled: Bool = true) -> PButton {
        var newConfig = config
        newConfig.hapticFeedback = enabled
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set custom background color
    func background(_ color: Color) -> PButton {
        var newConfig = config
        newConfig.customBackground = color
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set custom foreground (text/icon) color
    func foreground(_ color: Color) -> PButton {
        var newConfig = config
        newConfig.customForeground = color
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set custom colors for background and foreground
    func colors(background: Color, foreground: Color) -> PButton {
        var newConfig = config
        newConfig.customBackground = background
        newConfig.customForeground = foreground
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set custom width
    func width(_ width: CGFloat) -> PButton {
        var newConfig = config
        newConfig.customWidth = width
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set custom height
    func height(_ height: CGFloat) -> PButton {
        var newConfig = config
        newConfig.customHeight = height
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set custom frame size
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> PButton {
        var newConfig = config
        if let w = width { newConfig.customWidth = w }
        if let h = height { newConfig.customHeight = h }
        return PButton(title: title, action: action, config: newConfig)
    }
    
    /// Set font weight
    func fontWeight(_ weight: Font.Weight) -> PButton {
        var newConfig = config
        newConfig.fontWeight = weight
        return PButton(title: title, action: action, config: newConfig)
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PButton_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Family-Style Onboarding Buttons
                Group {
                    Text("Family Style")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        PButton("Create a New Wallet") {}
                            .variant(.primary)
                            .icon("plus")
                            .fullWidth()
                        
                        PButton("Add an Existing Wallet") {}
                            .variant(.outline)
                            .fullWidth()
                    }
                }
                
                Divider()
                
                // Variants
                Group {
                    Text("Variants")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                    HStack(spacing: 12) {
                            PButton("Primary") {}.variant(.primary)
                            PButton("Secondary") {}.variant(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                            PButton("Destructive") {}.variant(.destructive)
                            PButton("Outline") {}.variant(.outline)
                    }
                    
                    HStack(spacing: 12) {
                            PButton("Ghost") {}.variant(.ghost)
                            PButton("Link") {}.variant(.link)
                        }
                    }
                }
                
                Divider()
                
                // Sizes
                Group {
                    Text("Sizes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        PButton("Small") {}.size(.sm)
                        PButton("Medium") {}.size(.md)
                        PButton("Large") {}.size(.lg)
                    }
                }
                
                Divider()
                
                // States
                Group {
                    Text("States")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            PButton("Disabled") {}.disabled()
                            PButton("Loading") {}.loading()
                        }
                        
                        // Loading with different spinner styles
                        PButton("Importing")
                            .loading()
                            .loadingPosition(.trailing)
                            .spinnerStyle(.dots)
                            .background(Color(hex: "#7DDFBD"))
                            .foreground(.white)
                            .fullWidth()
                        
                        PButton("Processing")
                            .loading(true, text: "Please wait...")
                            .loadingPosition(.leading)
                            .spinnerStyle(.circular)
                            .variant(.primary)
                            .fullWidth()
                        
                        PButton("Syncing")
                            .loading()
                            .loadingPosition(.trailing)
                            .spinnerStyle(.minimal)
                            .spinnerSize(.sm)
                            .variant(.outline)
                            .fullWidth()
                        
                        PButton("Uploading")
                            .loading()
                            .loadingPosition(.trailing)
                            .spinnerStyle(.orbit)
                            .variant(.outline)
                            .fullWidth()
                        
                        PButton("Verifying")
                            .loading()
                            .loadingPosition(.trailing)
                            .spinnerStyle(.minimal)
                            .variant(.ghost)
                            .fullWidth()
                        
                        HStack(spacing: 12) {
                            PButton("Save")
                                .loading()
                                .loadingPosition(.replace)
                                .spinnerSize(.md)
                                .variant(.primary)
                            
                            PButton("Submit")
                                .loading()
                                .hideTextWhenLoading()
                                .variant(.outline)
                        }
                    }
                }
                
                Divider()
                
                // With Icons
                Group {
                    Text("With Icons")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        PButton("Create Wallet") {}
                            .icon("plus.circle.fill")
                            .variant(.primary)
                        
                        PButton("Continue") {}
                            .icon("arrow.right")
                            .iconPosition(.trailing)
                            .variant(.outline)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F8F9FA"))
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode - Sky Theme")
        
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    PButton("Create a New Wallet") {}
                        .variant(.primary)
                        .icon("plus")
                        .fullWidth()
                    
                    PButton("Add an Existing Wallet") {}
                        .variant(.outline)
                        .fullWidth()
                }
            }
            .padding(20)
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode - Sky Theme")
    }
}
#endif
