//
//  PAlert.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired alert/notification component with variants and animations.
//

import SwiftUI

// MARK: - Alert Variant

/// Visual variants for PAlert
public enum PAlertVariant: String, Equatable, Sendable, CaseIterable {
    /// Informational alert (blue)
    case info
    /// Success alert (green)
    case success
    /// Warning alert (orange/yellow)
    case warning
    /// Error/destructive alert (red)
    case error
}

// MARK: - Alert Style

/// Layout style for PAlert
public enum PAlertStyle: Equatable, Sendable {
    /// Standard horizontal layout
    case standard
    /// Compact layout for inline use
    case compact
    /// Banner style for top/bottom of screen
    case banner
}

// MARK: - PAlert Configuration

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PAlertConfiguration {
    var variant: PAlertVariant = .info
    var style: PAlertStyle = .standard
    var icon: String? = nil
    var useDefaultIcon: Bool = true
    var description: String? = nil
    var isDismissible: Bool = false
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    var onDismiss: (() -> Void)? = nil
}

// MARK: - PAlert

/// A customizable alert/notification component inspired by Family.co's design.
///
/// Basic usage:
/// ```swift
/// PAlert("Transaction Successful", variant: .success)
///
/// PAlert("Connection Lost", variant: .error)
///     .description("Please check your internet connection.")
///     .dismissible()
/// ```
///
/// With action button:
/// ```swift
/// PAlert("Update Available", variant: .info)
///     .action("Update Now") {
///         performUpdate()
///     }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PAlert: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - State
    
    @State private var isVisible = true
    @State private var isPressed = false
    
    // MARK: - Properties
    
    private let title: String
    private var config: PAlertConfiguration
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var alertConfig: AlertConfig {
        theme.components.alert
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[alertConfig.radius]
    }
    
    // MARK: - Variant Colors
    
    private var variantColor: Color {
        switch config.variant {
        case .info:
            return colors.primary
        case .success:
            return colors.success
        case .warning:
            return colors.warning
        case .error:
            return colors.destructive
        }
    }
    
    private var variantBackgroundColor: Color {
        variantColor.opacity(alertConfig.backgroundOpacity)
    }
    
    private var variantBorderColor: Color {
        variantColor.opacity(0.3)
    }
    
    private var variantIconName: String {
        if let customIcon = config.icon {
            return customIcon
        }
        
        switch config.variant {
        case .info:
            return "info.circle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }
    
    // MARK: - Animation
    
    private var springAnimation: Animation {
        reduceMotion
            ? .easeInOut(duration: 0.2)
            : .spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0)
    }
    
    // MARK: - Initializer
    
    /// Create an alert with a title
    /// - Parameters:
    ///   - title: The alert title/message
    ///   - variant: The visual variant (info, success, warning, error)
    public init(_ title: String, variant: PAlertVariant = .info) {
        self.title = title
        self.config = PAlertConfiguration(variant: variant)
    }
    
    // Private init for modifiers
    private init(title: String, config: PAlertConfiguration) {
        self.title = title
        self.config = config
    }
    
    // MARK: - Body
    
    public var body: some View {
        if isVisible {
            alertContent
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
        }
    }
    
    @ViewBuilder
    private var alertContent: some View {
        HStack(alignment: config.description != nil ? .top : .center, spacing: theme.spacing.md) {
            // Icon
            if config.useDefaultIcon || config.icon != nil {
                Image(systemName: variantIconName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(variantColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(.system(size: theme.typography.sizes.base, weight: .semibold))
                    .foregroundColor(colors.foreground)
                
                if let description = config.description {
                    Text(description)
                        .font(.system(size: theme.typography.sizes.sm))
                        .foregroundColor(colors.mutedForeground)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Action button
                if let actionTitle = config.actionTitle {
                    Button(action: {
                        config.action?()
                    }) {
                        Text(actionTitle)
                            .font(.system(size: theme.typography.sizes.sm, weight: .semibold))
                            .foregroundColor(variantColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, theme.spacing.xs)
                }
            }
            
            Spacer(minLength: 0)
            
            // Dismiss button
            if config.isDismissible {
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                        .padding(theme.spacing.xs)
                        .background(
                            Circle()
                                .fill(colors.muted.opacity(isPressed ? 0.8 : 0))
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in isPressed = true }
                        .onEnded { _ in isPressed = false }
                )
            }
        }
        .padding(alertPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .fill(variantBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .stroke(variantBorderColor, lineWidth: alertConfig.borderWidth)
        )
    }
    
    // MARK: - Sizing
    
    private var iconSize: CGFloat {
        switch config.style {
        case .compact:
            return 16
        case .standard, .banner:
            return 20
        }
    }
    
    private var alertPadding: CGFloat {
        switch config.style {
        case .compact:
            return theme.spacing.sm
        case .standard:
            return theme.spacing.md
        case .banner:
            return theme.spacing.lg
        }
    }
    
    // MARK: - Actions
    
    private func dismiss() {
        withAnimation(springAnimation) {
            isVisible = false
        }
        config.onDismiss?()
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PAlert {
    
    /// Set the alert variant
    func variant(_ variant: PAlertVariant) -> PAlert {
        var newConfig = config
        newConfig.variant = variant
        return PAlert(title: title, config: newConfig)
    }
    
    /// Set the alert style
    func style(_ style: PAlertStyle) -> PAlert {
        var newConfig = config
        newConfig.style = style
        return PAlert(title: title, config: newConfig)
    }
    
    /// Set a custom icon (SF Symbol name)
    func icon(_ systemName: String) -> PAlert {
        var newConfig = config
        newConfig.icon = systemName
        return PAlert(title: title, config: newConfig)
    }
    
    /// Hide the default icon
    func hideIcon() -> PAlert {
        var newConfig = config
        newConfig.useDefaultIcon = false
        newConfig.icon = nil
        return PAlert(title: title, config: newConfig)
    }
    
    /// Add a description text
    func description(_ text: String?) -> PAlert {
        var newConfig = config
        newConfig.description = text
        return PAlert(title: title, config: newConfig)
    }
    
    /// Make the alert dismissible
    func dismissible(_ isDismissible: Bool = true, onDismiss: (() -> Void)? = nil) -> PAlert {
        var newConfig = config
        newConfig.isDismissible = isDismissible
        newConfig.onDismiss = onDismiss
        return PAlert(title: title, config: newConfig)
    }
    
    /// Add an action button
    func action(_ title: String, action: @escaping () -> Void) -> PAlert {
        var newConfig = config
        newConfig.actionTitle = title
        newConfig.action = action
        return PAlert(title: title, config: newConfig)
    }
}

// MARK: - Alert Binding Modifier

/// A view modifier that shows an alert based on a binding
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AlertPresentationModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    let title: String
    let variant: PAlertVariant
    let description: String?
    
    public func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isPresented {
                PAlert(title, variant: variant)
                    .description(description)
                    .dismissible {
                        isPresented = false
                    }
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            content
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isPresented)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Present an alert banner at the top of the view
    func alertBanner(
        isPresented: Binding<Bool>,
        title: String,
        variant: PAlertVariant = .info,
        description: String? = nil
    ) -> some View {
        modifier(AlertPresentationModifier(
            isPresented: isPresented,
            title: title,
            variant: variant,
            description: description
        ))
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PAlert_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Variants
                Group {
                    Text("Variants")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("This is an informational message", variant: .info)
                    
                    PAlert("Transaction completed successfully", variant: .success)
                    
                    PAlert("Please review your settings", variant: .warning)
                    
                    PAlert("Connection failed", variant: .error)
                }
                
                Divider()
                
                // With descriptions
                Group {
                    Text("With Descriptions")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("Update Available", variant: .info)
                        .description("A new version of the app is available. Update now to get the latest features.")
                    
                    PAlert("Wallet Connected", variant: .success)
                        .description("Your wallet has been successfully connected to the app.")
                }
                
                Divider()
                
                // Dismissible
                Group {
                    Text("Dismissible")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("Network Warning", variant: .warning)
                        .description("You're connected to an unsecured network.")
                        .dismissible()
                    
                    PAlert("Session Expired", variant: .error)
                        .dismissible()
                }
                
                Divider()
                
                // With Actions
                Group {
                    Text("With Actions")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("Update Required", variant: .info)
                        .description("Please update the app to continue.")
                        .action("Update Now") {
                            print("Update tapped")
                        }
                    
                    PAlert("Transaction Failed", variant: .error)
                        .description("Your transaction could not be completed.")
                        .action("Retry") {
                            print("Retry tapped")
                        }
                        .dismissible()
                }
                
                Divider()
                
                // Custom Icons
                Group {
                    Text("Custom Icons")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("Backup Complete", variant: .success)
                        .icon("icloud.and.arrow.up.fill")
                        .description("Your wallet has been backed up to iCloud.")
                    
                    PAlert("Low Battery", variant: .warning)
                        .icon("battery.25")
                        .description("Connect your device to a charger.")
                }
                
                Divider()
                
                // Compact Style
                Group {
                    Text("Compact Style")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("Copied to clipboard", variant: .success)
                        .style(.compact)
                    
                    PAlert("Invalid address format", variant: .error)
                        .style(.compact)
                }
                
                Divider()
                
                // Without Icon
                Group {
                    Text("Without Icon")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAlert("Simple notification message", variant: .info)
                        .hideIcon()
                }
            }
            .padding()
        }
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode")
        
        ScrollView {
            VStack(spacing: 16) {
                PAlert("Wallet Connected", variant: .success)
                    .description("Your wallet is now ready to use.")
                    .dismissible()
                
                PAlert("Pending Transaction", variant: .warning)
                    .description("You have 1 pending transaction.")
                    .action("View") {}
                
                PAlert("Connection Lost", variant: .error)
                    .action("Retry") {}
                    .dismissible()
            }
            .padding()
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif

