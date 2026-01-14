//
//  PTextField.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired text field component with fluent modifier API.
//

import SwiftUI

// MARK: - Scale Button Style

/// A button style with scale feedback for micro-interactions (~0.1s)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.spring(response: 0.1, dampingFraction: 0.9), value: configuration.isPressed)
    }
}

// MARK: - TextField Configuration

/// Configuration for PTextField styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTextFieldConfiguration {
    var variant: PTextFieldVariant = .outlined
    var size: PTextFieldSize = .md
    var radius: RadiusSize = .lg
    var isSecure: Bool = false
    var floatingLabel: Bool = true
    var showClearButton: Bool = true
    var maxCharacters: Int? = nil
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var errorMessage: String? = nil
    var helperText: String? = nil
    var successMessage: String? = nil
    var isDisabled: Bool = false
    #if os(iOS) || os(tvOS)
    var autocapitalization: TextInputAutocapitalization = .sentences
    var keyboardType: UIKeyboardType = .default
    #endif
    var submitLabel: SubmitLabel = .done
    
    // Custom colors
    var customFocusColor: Color? = nil
    var customBackgroundColor: Color? = nil
    var customForegroundColor: Color? = nil
    var customPlaceholderColor: Color? = nil
}

/// Text field variants
public enum PTextFieldVariant: String, Equatable, Sendable, CaseIterable {
    /// Outlined style with border (default Family style)
    case outlined
    /// Filled background style
    case filled
    /// Underline only style
    case underlined
}

// MARK: - PTextField

/// A customizable text field component inspired by Family.co's design system.
///
/// Features a floating label animation, smooth transitions, and comprehensive states.
///
/// Basic usage:
/// ```swift
/// @State private var email = ""
///
/// PTextField("Email", text: $email)
///     .leadingIcon("envelope")
/// ```
///
/// With validation:
/// ```swift
/// PTextField("Password", text: $password)
///     .secure()
///     .leadingIcon("lock")
///     .error("Password must be at least 8 characters")
/// ```
///
/// Filled variant:
/// ```swift
/// PTextField("Search", text: $query)
///     .variant(.filled)
///     .leadingIcon("magnifyingglass")
///     .clearButton()
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTextField: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    private let label: String
    @Binding private var text: String
    private var config: PTextFieldConfiguration
    private var onSubmit: (() -> Void)?
    
    // MARK: - State
    
    @FocusState private var isFocused: Bool
    @State private var isSecureTextVisible = false
    @State private var isHovered = false
    
    // MARK: - Computed Properties
    
    private var textFieldConfig: TextFieldConfig {
        theme.components.textField
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
    private var hasError: Bool {
        config.errorMessage != nil
    }
    
    private var hasSuccess: Bool {
        config.successMessage != nil && !hasError
    }
    
    private var isFloating: Bool {
        isFocused || !text.isEmpty
    }
    
    private var isFieldDisabled: Bool {
        !isEnabled || config.isDisabled
    }
    
    // MARK: - Animation (max 0.3s for micro-interactions)
    
    /// Standard spring for field transitions (~0.2s)
    private var springAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.8)
    }
    
    /// Quick animation for micro-interactions (~0.15s)
    private var quickAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.15, dampingFraction: 0.9)
    }
    
    /// Floating label animation (~0.25s with slight bounce)
    private var floatAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.75)
    }
    
    // MARK: - Initializer
    
    /// Create a text field with a label
    /// - Parameters:
    ///   - label: Placeholder/floating label text
    ///   - text: Binding to the text value
    public init(_ label: String, text: Binding<String>) {
        self.label = label
        self._text = text
        self.config = PTextFieldConfiguration()
    }
    
    // Private init for modifiers
    private init(label: String, text: Binding<String>, config: PTextFieldConfiguration, onSubmit: (() -> Void)? = nil) {
        self.label = label
        self._text = text
        self.config = config
        self.onSubmit = onSubmit
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Main input container
            fieldContainer
            
            // Helper text, error, success, or character count
            bottomContent
        }
        .opacity(isFieldDisabled ? 0.6 : 1)
        .animation(springAnimation, value: isFieldDisabled)
    }
    
    // MARK: - Field Container
    
    @ViewBuilder
    private var fieldContainer: some View {
            HStack(spacing: theme.spacing.sm) {
                // Leading icon
            if let iconName = config.leadingIcon {
                leadingIconView(iconName)
            }
            
            // Text input with floating label
            textInputArea
            
            // Trailing elements
            trailingElements
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(minHeight: minHeight)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
        .overlay(borderOverlay)
        .animation(quickAnimation, value: isFocused)
        .animation(quickAnimation, value: hasError)
        .animation(quickAnimation, value: hasSuccess)
        #if os(macOS)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        #endif
    }
    
    // MARK: - Leading Icon
    
    @ViewBuilder
    private func leadingIconView(_ iconName: String) -> some View {
        Image(systemName: iconName)
            .font(.system(size: iconSize, weight: .medium))
            .foregroundColor(leadingIconColor)
            .frame(width: iconSize + 4, height: iconSize + 4)
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .animation(quickAnimation, value: isFocused)
            .animation(quickAnimation, value: hasError)
            .animation(quickAnimation, value: hasSuccess)
    }
    
    private var leadingIconColor: Color {
        if hasError {
            return colors.destructive
        } else if hasSuccess {
            return colors.success
        } else if isFocused {
            return config.customFocusColor ?? colors.primary
        }
        return config.customPlaceholderColor ?? colors.mutedForeground
    }
    
    // MARK: - Text Input Area
    
    @ViewBuilder
    private var textInputArea: some View {
        ZStack(alignment: .leading) {
            // Floating label
            if config.floatingLabel {
                floatingLabelView
            }
            
            // Actual text field
                Group {
                if config.isSecure && !isSecureTextVisible {
                    SecureField(config.floatingLabel ? "" : label, text: $text)
                        .onSubmit { onSubmit?() }
                    } else {
                    TextField(config.floatingLabel ? "" : label, text: $text)
                        #if os(iOS) || os(tvOS)
                        .textInputAutocapitalization(config.autocapitalization)
                        .keyboardType(config.keyboardType)
                        #endif
                        .submitLabel(config.submitLabel)
                        .onSubmit { onSubmit?() }
                    }
                }
            .focused($isFocused)
            .font(.system(size: fontSize, weight: .regular))
            .foregroundColor(config.customForegroundColor ?? colors.foreground)
            .tint(config.customFocusColor ?? colors.primary)
            .offset(y: config.floatingLabel && isFloating ? 6 : 0)
            .animation(floatAnimation, value: isFloating)
        }
    }
    
    // MARK: - Floating Label
    
    @ViewBuilder
    private var floatingLabelView: some View {
        Text(label)
            .font(.system(size: isFloating ? floatingLabelSize : fontSize, weight: isFloating ? .medium : .regular))
            .foregroundColor(floatingLabelColor)
            .offset(y: isFloating ? -floatingLabelOffset : 0)
            .scaleEffect(isFloating ? 0.85 : 1, anchor: .leading)
            .animation(floatAnimation, value: isFloating)
            .allowsHitTesting(false)
    }
    
    private var floatingLabelColor: Color {
        if hasError {
            return colors.destructive
        } else if hasSuccess {
            return colors.success
        } else if isFocused {
            return config.customFocusColor ?? colors.primary
        }
        return config.customPlaceholderColor ?? colors.mutedForeground
    }
    
    private var floatingLabelSize: CGFloat {
        switch config.size {
        case .sm: return theme.typography.sizes.xs
        case .md: return theme.typography.sizes.xs
        case .lg: return theme.typography.sizes.sm
        }
    }
    
    private var floatingLabelOffset: CGFloat {
        switch config.size {
        case .sm: return 10
        case .md: return 12
        case .lg: return 14
        }
    }
    
    // MARK: - Trailing Elements
    
    @ViewBuilder
    private var trailingElements: some View {
        HStack(spacing: theme.spacing.xs) {
            // Character count
            if let maxChars = config.maxCharacters {
                characterCountView(maxChars)
            }
            
            // Clear button
            if config.showClearButton && !text.isEmpty && !config.isSecure {
                clearButton
            }
            
            // Secure toggle
            if config.isSecure {
                secureToggleButton
            }
            
            // Status icon
            if hasError || hasSuccess {
                statusIcon
            } else if let iconName = config.trailingIcon {
                trailingIconView(iconName)
            }
        }
    }
    
    @ViewBuilder
    private func characterCountView(_ maxChars: Int) -> some View {
        let isOverLimit = text.count > maxChars
        Text("\(text.count)/\(maxChars)")
            .font(.system(size: theme.typography.sizes.xs, weight: .medium))
            .foregroundColor(isOverLimit ? colors.destructive : colors.mutedForeground)
            .monospacedDigit()
    }
    
    @ViewBuilder
    private var clearButton: some View {
        Button {
            withAnimation(quickAnimation) {
                text = ""
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: iconSize - 2))
                .foregroundColor(colors.mutedForeground.opacity(0.7))
        }
        .buttonStyle(ScaleButtonStyle())
        .transition(.asymmetric(
            insertion: .scale(scale: 0.5).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        ))
    }
    
    @ViewBuilder
    private var secureToggleButton: some View {
        Button {
            withAnimation(quickAnimation) {
                isSecureTextVisible.toggle()
            }
        } label: {
            Image(systemName: isSecureTextVisible ? "eye.slash.fill" : "eye.fill")
                .font(.system(size: iconSize - 2, weight: .medium))
                .foregroundColor(colors.mutedForeground)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        Group {
            if hasError {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(colors.destructive)
            } else if hasSuccess {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(colors.success)
            }
        }
        .font(.system(size: iconSize, weight: .medium))
        .transition(.asymmetric(
            insertion: .scale(scale: 0.3).combined(with: .opacity),
            removal: .scale(scale: 0.8).combined(with: .opacity)
        ))
    }
    
    @ViewBuilder
    private func trailingIconView(_ iconName: String) -> some View {
                    Image(systemName: iconName)
            .font(.system(size: iconSize, weight: .medium))
                        .foregroundColor(colors.mutedForeground)
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var backgroundView: some View {
        if let customBg = config.customBackgroundColor {
            customBg
        } else {
            switch config.variant {
            case .outlined:
                colors.card
            case .filled:
                isFocused ? colors.card : colors.muted
            case .underlined:
                Color.clear
            }
        }
    }
    
    // MARK: - Border
    
    @ViewBuilder
    private var borderOverlay: some View {
        switch config.variant {
        case .outlined:
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .stroke(borderColor, lineWidth: isFocused ? textFieldConfig.focusRingWidth : textFieldConfig.borderWidth)
        case .filled:
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .stroke(isFocused ? borderColor : Color.clear, lineWidth: textFieldConfig.focusRingWidth)
        case .underlined:
            VStack {
                Spacer()
                Rectangle()
                    .fill(borderColor)
                    .frame(height: isFocused ? 2 : 1)
            }
        }
    }
    
    private var borderColor: Color {
        if hasError {
            return colors.destructive
        } else if hasSuccess {
            return colors.success
        } else if isFocused {
            return config.customFocusColor ?? colors.ring
        } else if isHovered {
            return colors.border.opacity(0.8)
        }
        return colors.input
    }
    
    // MARK: - Bottom Content
    
    @ViewBuilder
    private var bottomContent: some View {
        HStack {
            Group {
                if let error = config.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(.system(size: theme.typography.sizes.xs, weight: .medium))
                        .foregroundColor(colors.destructive)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else if let success = config.successMessage {
                    Label(success, systemImage: "checkmark.circle.fill")
                        .font(.system(size: theme.typography.sizes.xs, weight: .medium))
                        .foregroundColor(colors.success)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else if let helper = config.helperText {
                    Text(helper)
                        .font(.system(size: theme.typography.sizes.xs))
                        .foregroundColor(colors.mutedForeground)
                }
            }
            .animation(quickAnimation, value: config.errorMessage)
            .animation(quickAnimation, value: config.successMessage)
            
            Spacer()
        }
    }
    
    // MARK: - Sizing
    
    private var fontSize: CGFloat {
        switch config.size {
        case .sm: return theme.typography.sizes.sm
        case .md: return theme.typography.sizes.base
        case .lg: return theme.typography.sizes.lg
        }
    }
    
    private var iconSize: CGFloat {
        switch config.size {
        case .sm: return 16
        case .md: return 18
        case .lg: return 20
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch config.size {
        case .sm: return theme.spacing.sm
        case .md: return theme.spacing.md
        case .lg: return theme.spacing.md
        }
    }
    
    private var verticalPadding: CGFloat {
        let basePadding: CGFloat
        switch config.size {
        case .sm: basePadding = theme.spacing.sm
        case .md: basePadding = theme.spacing.sm + 2
        case .lg: basePadding = theme.spacing.md
        }
        // Add extra padding for floating label
        return config.floatingLabel ? basePadding + 4 : basePadding
    }
    
    private var minHeight: CGFloat {
        switch config.size {
        case .sm: return config.floatingLabel ? 48 : 40
        case .md: return config.floatingLabel ? 56 : 48
        case .lg: return config.floatingLabel ? 64 : 56
        }
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PTextField {
    
    /// Set the text field variant
    func variant(_ variant: PTextFieldVariant) -> PTextField {
        var newConfig = config
        newConfig.variant = variant
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set the text field size
    func size(_ size: PTextFieldSize) -> PTextField {
        var newConfig = config
        newConfig.size = size
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set the corner radius
    func radius(_ radius: RadiusSize) -> PTextField {
        var newConfig = config
        newConfig.radius = radius
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Make this a secure/password field
    func secure(_ isSecure: Bool = true) -> PTextField {
        var newConfig = config
        newConfig.isSecure = isSecure
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Enable or disable floating label
    func floatingLabel(_ enabled: Bool = true) -> PTextField {
        var newConfig = config
        newConfig.floatingLabel = enabled
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Show a clear button when text is present
    func clearButton(_ show: Bool = true) -> PTextField {
        var newConfig = config
        newConfig.showClearButton = show
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set maximum character limit with counter
    func maxCharacters(_ limit: Int) -> PTextField {
        var newConfig = config
        newConfig.maxCharacters = limit
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Add a leading icon
    func leadingIcon(_ systemName: String) -> PTextField {
        var newConfig = config
        newConfig.leadingIcon = systemName
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Add a trailing icon
    func trailingIcon(_ systemName: String) -> PTextField {
        var newConfig = config
        newConfig.trailingIcon = systemName
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set error state with message
    func error(_ message: String?) -> PTextField {
        var newConfig = config
        newConfig.errorMessage = message
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set success state with message
    func success(_ message: String?) -> PTextField {
        var newConfig = config
        newConfig.successMessage = message
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set helper text below the field
    func helper(_ text: String?) -> PTextField {
        var newConfig = config
        newConfig.helperText = text
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Disable the text field
    func disabled(_ isDisabled: Bool = true) -> PTextField {
        var newConfig = config
        newConfig.isDisabled = isDisabled
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    #if os(iOS) || os(tvOS)
    /// Set text autocapitalization
    func autocapitalization(_ type: TextInputAutocapitalization) -> PTextField {
        var newConfig = config
        newConfig.autocapitalization = type
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set keyboard type
    func keyboard(_ type: UIKeyboardType) -> PTextField {
        var newConfig = config
        newConfig.keyboardType = type
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    #endif
    
    /// Set submit button label
    func submitLabel(_ label: SubmitLabel) -> PTextField {
        var newConfig = config
        newConfig.submitLabel = label
        return PTextField(label: self.label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Action to perform on submit
    func onSubmit(_ action: @escaping () -> Void) -> PTextField {
        return PTextField(label: label, text: $text, config: config, onSubmit: action)
    }
    
    // MARK: - Custom Colors
    
    /// Set custom focus/ring color
    func focusColor(_ color: Color) -> PTextField {
        var newConfig = config
        newConfig.customFocusColor = color
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set custom background color
    func backgroundColor(_ color: Color) -> PTextField {
        var newConfig = config
        newConfig.customBackgroundColor = color
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set custom foreground/text color
    func foregroundColor(_ color: Color) -> PTextField {
        var newConfig = config
        newConfig.customForegroundColor = color
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set custom placeholder/label color
    func placeholderColor(_ color: Color) -> PTextField {
        var newConfig = config
        newConfig.customPlaceholderColor = color
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
    
    /// Set all custom colors at once
    func colors(
        focus: Color? = nil,
        background: Color? = nil,
        foreground: Color? = nil,
        placeholder: Color? = nil
    ) -> PTextField {
        var newConfig = config
        if let focus { newConfig.customFocusColor = focus }
        if let background { newConfig.customBackgroundColor = background }
        if let foreground { newConfig.customForegroundColor = foreground }
        if let placeholder { newConfig.customPlaceholderColor = placeholder }
        return PTextField(label: label, text: $text, config: newConfig, onSubmit: onSubmit)
    }
}

// MARK: - PLabeledTextField

/// A text field with a static label above it (non-floating)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PLabeledTextField: View {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let label: String
    private let placeholder: String
    @Binding private var text: String
    private let isRequired: Bool
    private var textField: PTextField
    
    public init(
        _ label: String,
        placeholder: String = "",
        text: Binding<String>,
        isRequired: Bool = false
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isRequired = isRequired
        self.textField = PTextField(placeholder, text: text)
            .floatingLabel(false)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.system(size: theme.typography.sizes.sm, weight: .semibold))
                    .foregroundColor(theme.colors(for: colorScheme).foreground)
                
                if isRequired {
                    Text("*")
                        .foregroundColor(theme.colors(for: colorScheme).destructive)
                }
            }
            
            textField
        }
    }
}

// MARK: - Search Field

/// A pre-configured search field with Family styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSearchField: View {
    @Environment(\.prettyTheme) private var theme
    
    private let placeholder: String
    @Binding private var text: String
    private var onSubmit: (() -> Void)?
    
    public init(
        _ placeholder: String = "Search",
        text: Binding<String>,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        PTextField(placeholder, text: $text)
            .variant(.filled)
            .leadingIcon("magnifyingglass")
            .floatingLabel(false)
            .clearButton(true)
            .radius(.full)
            .onSubmit { onSubmit?() }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PTextField_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var email = ""
        @State private var password = ""
        @State private var name = "John Doe"
        @State private var bio = ""
        @State private var search = ""
        @State private var username = ""
        
        var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    // Family Style
                    Group {
                        Text("Family Style")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            #if os(iOS) || os(tvOS)
                            PTextField("Email address", text: $email)
                                .leadingIcon("envelope")
                                .keyboard(.emailAddress)
                                .autocapitalization(.never)
                            #else
                            PTextField("Email address", text: $email)
                                .leadingIcon("envelope")
                            #endif
                            
                            PTextField("Password", text: $password)
                                .secure()
                                .leadingIcon("lock")
                        }
                    }
                    
                    Divider()
                    
                    // Variants
                    Group {
                        Text("Variants")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            PTextField("Outlined (default)", text: $email)
                                .variant(.outlined)
                            
                            PTextField("Filled", text: $email)
                                .variant(.filled)
                            
                            PTextField("Underlined", text: $email)
                                .variant(.underlined)
                        }
                    }
                    
                    Divider()
                    
                    // Sizes
                    Group {
                        Text("Sizes")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            PTextField("Small", text: $email)
                                .size(.sm)
                            
                            PTextField("Medium", text: $email)
                                .size(.md)
                            
                            PTextField("Large", text: $email)
                                .size(.lg)
                        }
                    }
                    
                    Divider()
                    
                    // With Icons
                    Group {
                        Text("With Icons")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                        PTextField("Search", text: $search)
                            .leadingIcon("magnifyingglass")
                                .clearButton()
                            
                            PTextField("Website", text: $email)
                                .leadingIcon("globe")
                                .trailingIcon("arrow.up.right")
                        }
                    }
                    
                    Divider()
                    
                    // Validation States
                    Group {
                        Text("Validation States")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            PTextField("Email", text: $email)
                                .leadingIcon("envelope")
                                .helper("We'll never share your email")
                            
                            PTextField("Email", text: .constant("invalid-email"))
                            .leadingIcon("envelope")
                                .error("Please enter a valid email address")
                            
                            PTextField("Username", text: $name)
                                .leadingIcon("person")
                                .success("Username is available!")
                        }
                    }
                    
                    Divider()
                    
                    // Character Count
                    Group {
                        Text("Character Count")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PTextField("Bio", text: $bio)
                            .maxCharacters(100)
                            .helper("Tell us about yourself")
                    }
                    
                    Divider()
                    
                    // Search Field
                    Group {
                        Text("Search Field")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PSearchField("Search wallets...", text: $search)
                    }
                    
                    Divider()
                    
                    // Non-floating label
                    Group {
                        Text("Without Floating Label")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PTextField("Enter your name", text: $username)
                            .floatingLabel(false)
                            .size(.lg)
                    }
                    
                    Divider()
                    
                    // Custom Colors
                    Group {
                        Text("Custom Colors")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            PTextField("Purple focus", text: $email)
                                .focusColor(Color(hex: "#8B5CF6"))
                            
                            PTextField("Custom themed", text: $email)
                                .colors(
                                    focus: Color(hex: "#10B981"),
                                    background: Color(hex: "#ECFDF5"),
                                    foreground: Color(hex: "#064E3B"),
                                    placeholder: Color(hex: "#6EE7B7")
                                )
                            
                            PTextField("Dark field", text: $email)
                                .backgroundColor(Color(hex: "#1C1C1E"))
                                .foregroundColor(.white)
                                .placeholderColor(Color(hex: "#8E8E93"))
                                .focusColor(Color(hex: "#FF9500"))
                        }
                    }
                    
                    Divider()
                    
                    // Disabled
                    Group {
                        Text("Disabled")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        PTextField("Disabled field", text: .constant("Cannot edit"))
                            .disabled(true)
                    }
                }
                .padding(20)
            }
            .background(Color(hex: "#F8F9FA"))
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .prettyTheme(.family)
            .previewDisplayName("Light Mode - Family Theme")
        
        PreviewWrapper()
            .prettyTheme(.family)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode - Family Theme")
    }
}
#endif
