//
//  PList.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired list component for settings and wallet lists.
//

import SwiftUI

// MARK: - List Style

/// List style variants
public enum PListStyle: String, Equatable, Sendable, CaseIterable {
    /// Grouped list with card background
    case grouped
    /// Inset grouped with rounded corners and margins
    case insetGrouped
    /// Plain list without card styling
    case plain
}

// MARK: - Divider Style

/// Divider style for list items
public enum PListDividerStyle: Equatable, Sendable {
    /// Full-width divider
    case full
    /// Inset divider (aligned with content after leading)
    case inset
    /// No divider
    case none
}

// MARK: - Trailing Accessory

/// Trailing accessory types for list items
public enum PListAccessory: Equatable, Sendable {
    /// Chevron arrow indicating navigation
    case chevron
    /// Checkmark for selection
    case checkmark
    /// Custom SF Symbol icon
    case icon(String)
    /// Badge with text
    case badge(String)
    /// No accessory
    case none
}

// MARK: - PList

/// A styled list container inspired by Family.co
///
/// Basic usage:
/// ```swift
/// PList {
///     PListItem("Settings")
///     PListItem("Profile")
/// }
/// ```
///
/// With header:
/// ```swift
/// PList("Account") {
///     PListItem("Email", subtitle: "john@example.com")
///     PListItem("Password", accessory: .chevron)
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PList<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    
    private let header: String?
    private let footer: String?
    private let style: PListStyle
    private let content: Content
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var listRadius: CGFloat {
        switch style {
        case .grouped, .insetGrouped:
            return theme.radius.xl
        case .plain:
            return 0
        }
    }
    
    // MARK: - Initializers
    
    /// Create a list with optional header
    public init(
        _ header: String? = nil,
        footer: String? = nil,
        style: PListStyle = .insetGrouped,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.style = style
        self.content = content()
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Header
            if let header = header {
                Text(header.uppercased())
                    .font(.system(size: theme.typography.sizes.xs, weight: .medium))
                    .foregroundColor(colors.mutedForeground)
                    .tracking(0.5)
                    .padding(.horizontal, style == .insetGrouped ? theme.spacing.md : theme.spacing.sm)
                    .padding(.bottom, theme.spacing.xs)
            }
            
            // Content
            VStack(spacing: 0) {
                content
            }
            .background(style != .plain ? colors.card : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: listRadius))
            .overlay(
                RoundedRectangle(cornerRadius: listRadius)
                    .stroke(style != .plain ? colors.border : Color.clear, lineWidth: style != .plain ? 1 : 0)
            )
            
            // Footer
            if let footer = footer {
                Text(footer)
                    .font(.system(size: theme.typography.sizes.xs))
                    .foregroundColor(colors.mutedForeground)
                    .padding(.horizontal, style == .insetGrouped ? theme.spacing.md : theme.spacing.sm)
                    .padding(.top, theme.spacing.xs)
            }
        }
    }
}

// MARK: - PListItem

/// A styled list item with leading, title, subtitle, and trailing content
///
/// Basic usage:
/// ```swift
/// PListItem("Settings")
/// ```
///
/// With icon and subtitle:
/// ```swift
/// PListItem("Notifications", subtitle: "Enabled", icon: "bell.fill")
///     .accessory(.chevron)
/// ```
///
/// With custom leading content:
/// ```swift
/// PListItem("John Doe", subtitle: "Online") {
///     PAvatar(name: "John Doe")
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PListItem<Leading: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - State
    
    @State private var isPressed = false
    
    // MARK: - Properties
    
    private let title: String
    private let subtitle: String?
    private let leading: Leading?
    private let icon: String?
    private let iconColor: Color?
    
    // Configuration
    private var accessory: PListAccessory = .none
    private var dividerStyle: PListDividerStyle = .inset
    private var showDivider: Bool = true
    private var isDestructive: Bool = false
    private var action: (() -> Void)? = nil
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var titleColor: Color {
        isDestructive ? colors.destructive : colors.foreground
    }
    
    private var pressAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.1)
    }
    
    private var hasAction: Bool {
        action != nil
    }
    
    // MARK: - Initializers
    
    /// Create a list item with title
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        @ViewBuilder leading: () -> Leading
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.leading = leading()
    }
    
    // Private init for modifiers
    private init(
        title: String,
        subtitle: String?,
        icon: String?,
        iconColor: Color?,
        leading: Leading?,
        accessory: PListAccessory,
        dividerStyle: PListDividerStyle,
        showDivider: Bool,
        isDestructive: Bool,
        action: (() -> Void)?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.leading = leading
        self.accessory = accessory
        self.dividerStyle = dividerStyle
        self.showDivider = showDivider
        self.isDestructive = isDestructive
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                // Leading content (icon or custom view)
                if let leading = leading {
                    leading
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor ?? colors.primary)
                        .frame(width: 28, height: 28)
                }
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: theme.typography.sizes.base))
                        .foregroundColor(titleColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: theme.typography.sizes.sm))
                            .foregroundColor(colors.mutedForeground)
                    }
                }
                
                Spacer()
                
                // Trailing accessory
                trailingAccessory
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm + 2)
            .background(backgroundColor)
            .contentShape(Rectangle())
            .if(hasAction) { view in
                view.simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed { isPressed = true }
                        }
                        .onEnded { _ in
                            isPressed = false
                            action?()
                        }
                )
            }
            
            // Divider
            if showDivider {
                divider
            }
        }
        .animation(pressAnimation, value: isPressed)
    }
    
    @ViewBuilder
    private var backgroundColor: some View {
        if isPressed && hasAction {
            colors.muted.opacity(0.5)
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private var trailingAccessory: some View {
        switch accessory {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.mutedForeground.opacity(0.6))
        case .checkmark:
            Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(colors.primary)
        case .icon(let name):
            Image(systemName: name)
                .font(.system(size: 16))
                .foregroundColor(colors.mutedForeground)
        case .badge(let text):
            Text(text)
                .font(.system(size: theme.typography.sizes.xs, weight: .medium))
                .foregroundColor(colors.primaryForeground)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xxs)
                .background(colors.primary)
                .clipShape(Capsule())
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var divider: some View {
        switch dividerStyle {
        case .full:
            Divider()
        case .inset:
            HStack(spacing: 0) {
                Color.clear
                    .frame(width: theme.spacing.md + (icon != nil || leading != nil ? 28 + theme.spacing.md : 0))
                Divider()
            }
        case .none:
            EmptyView()
        }
    }
}

// MARK: - PListItem Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PListItem {
    
    /// Set the trailing accessory
    public func accessory(_ accessory: PListAccessory) -> PListItem {
        PListItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            leading: leading,
            accessory: accessory,
            dividerStyle: dividerStyle,
            showDivider: showDivider,
            isDestructive: isDestructive,
            action: action
        )
    }
    
    /// Set the divider style
    public func divider(_ style: PListDividerStyle) -> PListItem {
        PListItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            leading: leading,
            accessory: accessory,
            dividerStyle: style,
            showDivider: showDivider,
            isDestructive: isDestructive,
            action: action
        )
    }
    
    /// Hide the divider
    public func hideDivider() -> PListItem {
        PListItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            leading: leading,
            accessory: accessory,
            dividerStyle: dividerStyle,
            showDivider: false,
            isDestructive: isDestructive,
            action: action
        )
    }
    
    /// Mark as destructive action
    public func destructive(_ isDestructive: Bool = true) -> PListItem {
        PListItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            leading: leading,
            accessory: accessory,
            dividerStyle: dividerStyle,
            showDivider: showDivider,
            isDestructive: isDestructive,
            action: action
        )
    }
    
    /// Add tap action
    public func onTap(_ action: @escaping () -> Void) -> PListItem {
        PListItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            leading: leading,
            accessory: accessory,
            dividerStyle: dividerStyle,
            showDivider: showDivider,
            isDestructive: isDestructive,
            action: action
        )
    }
}

// MARK: - PListItem Convenience Initializers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PListItem where Leading == EmptyView {
    
    /// Create a list item with title and optional icon
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.leading = nil
    }
}

// MARK: - PListSection

/// A section within a list with optional header and footer
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PListSection<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let header: String?
    private let footer: String?
    private let content: Content
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public init(
        _ header: String? = nil,
        footer: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let header = header {
                Text(header.uppercased())
                    .font(.system(size: theme.typography.sizes.xs, weight: .medium))
                    .foregroundColor(colors.mutedForeground)
                    .tracking(0.5)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.top, theme.spacing.md)
            }
            
            content
            
            if let footer = footer {
                Text(footer)
                    .font(.system(size: theme.typography.sizes.xs))
                    .foregroundColor(colors.mutedForeground)
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.bottom, theme.spacing.sm)
            }
        }
    }
}

// MARK: - PListToggleItem

/// A list item with a toggle switch
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PListToggleItem: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let title: String
    private let subtitle: String?
    private let icon: String?
    private let iconColor: Color?
    @Binding private var isOn: Bool
    
    private var showDivider: Bool = true
    private var dividerStyle: PListDividerStyle = .inset
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        isOn: Binding<Bool>
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self._isOn = isOn
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor ?? colors.primary)
                        .frame(width: 28, height: 28)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: theme.typography.sizes.base))
                        .foregroundColor(colors.foreground)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: theme.typography.sizes.sm))
                            .foregroundColor(colors.mutedForeground)
                    }
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(colors.primary)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm + 2)
            
            if showDivider {
                switch dividerStyle {
                case .full:
                    Divider()
                case .inset:
                    HStack(spacing: 0) {
                        Color.clear
                            .frame(width: theme.spacing.md + (icon != nil ? 28 + theme.spacing.md : 0))
                        Divider()
                    }
                case .none:
                    EmptyView()
                }
            }
        }
    }
    
    public func hideDivider() -> PListToggleItem {
        var item = self
        item.showDivider = false
        return item
    }
    
    public func divider(_ style: PListDividerStyle) -> PListToggleItem {
        var item = self
        item.dividerStyle = style
        return item
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PList_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Settings-style list
                PList("Account") {
                    PListItem("Profile", subtitle: "John Doe", icon: "person.fill")
                        .accessory(.chevron)
                        .onTap { print("Profile tapped") }
                    
                    PListItem("Email", subtitle: "john@example.com", icon: "envelope.fill")
                        .accessory(.chevron)
                        .onTap { print("Email tapped") }
                    
                    PListItem("Password", icon: "lock.fill")
                        .accessory(.chevron)
                        .hideDivider()
                        .onTap { print("Password tapped") }
                }
                
                // Notifications list with toggles
                PList("Notifications") {
                    PListToggleItem("Push Notifications", icon: "bell.fill", isOn: .constant(true))
                    PListToggleItem("Email Notifications", icon: "envelope.fill", isOn: .constant(false))
                    PListToggleItem("Sound", icon: "speaker.wave.2.fill", isOn: .constant(true))
                        .hideDivider()
                }
                
                // Wallet list
                PList("Wallets") {
                    PListItem("Main Wallet", subtitle: "0x1234...5678")
                        .accessory(.badge("Primary"))
                        .onTap {}
                    
                    PListItem("Trading Wallet", subtitle: "0xabcd...efgh")
                        .accessory(.chevron)
                        .onTap {}
                    
                    PListItem("Add Wallet", icon: "plus.circle.fill")
                        .hideDivider()
                        .onTap {}
                }
                
                // Danger zone
                PList(footer: "This action cannot be undone.") {
                    PListItem("Delete Account", icon: "trash.fill", iconColor: .red)
                        .destructive()
                        .hideDivider()
                        .onTap { print("Delete tapped") }
                }
            }
            .padding()
        }
        .background(Color(hex: "#F8F9FA"))
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode")
        
        ScrollView {
            VStack(spacing: 24) {
                PList("Account") {
                    PListItem("Profile", subtitle: "John Doe", icon: "person.fill")
                        .accessory(.chevron)
                    
                    PListItem("Settings", icon: "gearshape.fill")
                        .accessory(.chevron)
                        .hideDivider()
                        .skeleton(true)
                }
            }
            .padding()
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif

