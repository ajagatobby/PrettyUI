//
//  PAccordion.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired accordion component with fluid spring animations.
//

import SwiftUI

// MARK: - Accordion Variant

/// Visual style variants for the accordion
public enum PAccordionVariant: String, Equatable, Sendable, CaseIterable {
    /// Connected items with shared background
    case standard
    /// Each item has a visible border
    case bordered
    /// Each item is a separate card with spacing between
    case separated
}

// MARK: - Expansion Mode

/// Controls how accordion items expand
public enum PAccordionExpansionMode: Equatable, Sendable {
    /// Only one item can be expanded at a time
    case single
    /// Multiple items can be expanded simultaneously
    case multiple
}

// MARK: - Accordion Environment Keys

/// Environment key for accordion expansion mode
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct AccordionExpansionModeKey: EnvironmentKey {
    static let defaultValue: PAccordionExpansionMode = .multiple
}

/// Environment key for accordion variant
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct AccordionVariantKey: EnvironmentKey {
    static let defaultValue: PAccordionVariant = .standard
}

/// Environment key for accordion expanded items
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct AccordionExpandedItemsKey: EnvironmentKey {
    static let defaultValue: Binding<Set<String>>? = nil
}

/// Environment key for accordion item registration
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct AccordionToggleActionKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: ((String) -> Void)? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var accordionExpansionMode: PAccordionExpansionMode {
        get { self[AccordionExpansionModeKey.self] }
        set { self[AccordionExpansionModeKey.self] = newValue }
    }
    
    var accordionVariant: PAccordionVariant {
        get { self[AccordionVariantKey.self] }
        set { self[AccordionVariantKey.self] = newValue }
    }
    
    var accordionExpandedItems: Binding<Set<String>>? {
        get { self[AccordionExpandedItemsKey.self] }
        set { self[AccordionExpandedItemsKey.self] = newValue }
    }
    
    var accordionToggleAction: ((String) -> Void)? {
        get { self[AccordionToggleActionKey.self] }
        set { self[AccordionToggleActionKey.self] = newValue }
    }
}

// MARK: - Height Preference Key

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct ContentHeightPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - PAccordion

/// A container for accordion items with fluid animations
///
/// Basic usage:
/// ```swift
/// PAccordion {
///     PAccordionItem("What is PrettyUI?") {
///         Text("PrettyUI is a SwiftUI component library...")
///     }
///     PAccordionItem("How do I get started?") {
///         Text("Simply import PrettyUI and start using components...")
///     }
/// }
/// ```
///
/// With single expansion mode:
/// ```swift
/// PAccordion {
///     PAccordionItem("Section 1") { Content1() }
///     PAccordionItem("Section 2") { Content2() }
/// }
/// .expansionMode(.single)
/// .variant(.separated)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PAccordion<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - State
    
    @State private var expandedItems: Set<String> = []
    
    // MARK: - Properties
    
    private let content: Content
    private var variant: PAccordionVariant = .standard
    private var expansionMode: PAccordionExpansionMode = .multiple
    private var radius: RadiusSize? = nil
    private var showBorder: Bool? = nil
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var config: AccordionConfig {
        theme.components.accordion
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[radius ?? config.radius]
    }
    
    private var resolvedShowBorder: Bool {
        if let showBorder = showBorder { return showBorder }
        return variant == .bordered || variant == .standard
    }
    
    // MARK: - Initializer
    
    /// Create an accordion with content
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    // Private init for modifiers
    private init(
        content: Content,
        variant: PAccordionVariant,
        expansionMode: PAccordionExpansionMode,
        radius: RadiusSize?,
        showBorder: Bool?
    ) {
        self.content = content
        self.variant = variant
        self.expansionMode = expansionMode
        self.radius = radius
        self.showBorder = showBorder
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            switch variant {
            case .separated:
                VStack(spacing: theme.spacing.sm) {
                    content
                }
            case .standard, .bordered:
                VStack(spacing: 0) {
                    content
                }
                .background(colors.card)
                .clipShape(RoundedRectangle(cornerRadius: resolvedRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: resolvedRadius)
                        .stroke(resolvedShowBorder ? colors.border : Color.clear, lineWidth: 1)
                )
            }
        }
        .environment(\.accordionExpansionMode, expansionMode)
        .environment(\.accordionVariant, variant)
        .environment(\.accordionExpandedItems, $expandedItems)
        .environment(\.accordionToggleAction, toggleItem)
    }
    
    // MARK: - Actions
    
    private func toggleItem(_ id: String) {
        if expansionMode == .single {
            if expandedItems.contains(id) {
                expandedItems.remove(id)
            } else {
                expandedItems = [id]
            }
        } else {
            if expandedItems.contains(id) {
                expandedItems.remove(id)
            } else {
                expandedItems.insert(id)
            }
        }
    }
}

// MARK: - PAccordion Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PAccordion {
    
    /// Set the accordion variant
    public func variant(_ variant: PAccordionVariant) -> PAccordion {
        PAccordion(
            content: content,
            variant: variant,
            expansionMode: expansionMode,
            radius: radius,
            showBorder: showBorder
        )
    }
    
    /// Set the expansion mode (single or multiple)
    public func expansionMode(_ mode: PAccordionExpansionMode) -> PAccordion {
        PAccordion(
            content: content,
            variant: variant,
            expansionMode: mode,
            radius: radius,
            showBorder: showBorder
        )
    }
    
    /// Set the corner radius
    public func radius(_ radius: RadiusSize) -> PAccordion {
        PAccordion(
            content: content,
            variant: variant,
            expansionMode: expansionMode,
            radius: radius,
            showBorder: showBorder
        )
    }
    
    /// Show or hide the border
    public func showBorder(_ show: Bool) -> PAccordion {
        PAccordion(
            content: content,
            variant: variant,
            expansionMode: expansionMode,
            radius: radius,
            showBorder: show
        )
    }
}

// MARK: - PAccordionItem

/// An individual accordion item with header and expandable content
///
/// Usage:
/// ```swift
/// PAccordionItem("Question Title") {
///     Text("Answer content goes here...")
/// }
///
/// // With icon
/// PAccordionItem("Settings", icon: "gearshape.fill") {
///     SettingsContent()
/// }
///
/// // With subtitle
/// PAccordionItem("Profile", subtitle: "Manage your account") {
///     ProfileContent()
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PAccordionItem<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accordionVariant) private var accordionVariant
    @Environment(\.accordionExpandedItems) private var expandedItems
    @Environment(\.accordionToggleAction) private var toggleAction
    
    // MARK: - State
    
    @State private var contentHeight: CGFloat = 0
    @State private var localExpanded: Bool = false
    @State private var isPressed: Bool = false
    
    // MARK: - Properties
    
    private let id: String
    private let title: String
    private let subtitle: String?
    private let icon: String?
    private let iconColor: Color?
    private let content: Content
    
    // Configuration
    private var initiallyExpanded: Bool = false
    private var radius: RadiusSize? = nil
    private var showDivider: Bool = true
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var config: AccordionConfig {
        theme.components.accordion
    }
    
    private var isExpanded: Bool {
        if let expandedItems = expandedItems {
            return expandedItems.wrappedValue.contains(id)
        }
        return localExpanded
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[radius ?? config.radius]
    }
    
    private var springAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(
            response: config.springResponse,
            dampingFraction: config.springDamping
        )
    }
    
    private var isSeparatedStyle: Bool {
        accordionVariant == .separated
    }
    
    // MARK: - Initializers
    
    /// Create an accordion item with title and content
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        id: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id ?? title
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.content = content()
    }
    
    // Private init for modifiers
    private init(
        id: String,
        title: String,
        subtitle: String?,
        icon: String?,
        iconColor: Color?,
        content: Content,
        initiallyExpanded: Bool,
        radius: RadiusSize?,
        showDivider: Bool
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.content = content
        self.initiallyExpanded = initiallyExpanded
        self.radius = radius
        self.showDivider = showDivider
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Expandable Content
            expandableContent
            
            // Divider (for non-separated variants)
            if showDivider && !isSeparatedStyle && !isExpanded {
                Divider()
                    .padding(.horizontal, theme.spacing.md)
            }
        }
        .background(itemBackground)
        .clipShape(RoundedRectangle(cornerRadius: isSeparatedStyle ? resolvedRadius : 0))
        .overlay(itemBorder)
        .onAppear {
            if initiallyExpanded {
                if let toggleAction = toggleAction {
                    toggleAction(id)
                } else {
                    localExpanded = true
                }
            }
        }
    }
    
    // MARK: - Header View
    
    @ViewBuilder
    private var headerView: some View {
        Button(action: handleTap) {
            HStack(spacing: theme.spacing.md) {
                // Leading icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(iconColor ?? colors.primary)
                        .frame(width: 28, height: 28)
                }
                
                // Title and subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: theme.typography.sizes.base, weight: .medium))
                        .foregroundColor(colors.foreground)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: theme.typography.sizes.sm))
                            .foregroundColor(colors.mutedForeground)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Chevron indicator
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(colors.mutedForeground)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(springAnimation, value: isExpanded)
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(AccordionHeaderButtonStyle(
            isPressed: $isPressed,
            pressedColor: colors.muted.opacity(0.5),
            reduceMotion: reduceMotion
        ))
    }
    
    // MARK: - Expandable Content
    
    @ViewBuilder
    private var expandableContent: some View {
        VStack(spacing: 0) {
            if isExpanded {
                // Top divider when expanded
                Divider()
                    .padding(.horizontal, theme.spacing.md)
                
                // Content
                content
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .clipped()
        .animation(springAnimation, value: isExpanded)
    }
    
    // MARK: - Background & Border
    
    @ViewBuilder
    private var itemBackground: some View {
        if isSeparatedStyle {
            colors.card
        } else {
            Color.clear
        }
    }
    
    @ViewBuilder
    private var itemBorder: some View {
        if isSeparatedStyle {
            RoundedRectangle(cornerRadius: resolvedRadius)
                .stroke(colors.border, lineWidth: 1)
        } else {
            EmptyView()
        }
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
        
        withAnimation(springAnimation) {
            if let toggleAction = toggleAction {
                toggleAction(id)
            } else {
                localExpanded.toggle()
            }
        }
    }
}

// MARK: - PAccordionItem Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PAccordionItem {
    
    /// Set whether the item starts expanded
    public func expanded(_ isExpanded: Bool) -> PAccordionItem {
        PAccordionItem(
            id: id,
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            content: content,
            initiallyExpanded: isExpanded,
            radius: radius,
            showDivider: showDivider
        )
    }
    
    /// Set the corner radius (for separated variant)
    public func radius(_ radius: RadiusSize) -> PAccordionItem {
        PAccordionItem(
            id: id,
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            content: content,
            initiallyExpanded: initiallyExpanded,
            radius: radius,
            showDivider: showDivider
        )
    }
    
    /// Show or hide the divider
    public func showDivider(_ show: Bool) -> PAccordionItem {
        PAccordionItem(
            id: id,
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            content: content,
            initiallyExpanded: initiallyExpanded,
            radius: radius,
            showDivider: show
        )
    }
}

// MARK: - Accordion Header Button Style

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct AccordionHeaderButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    let pressedColor: Color
    let reduceMotion: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : Color.clear)
            .onChange(of: configuration.isPressed) { pressed in
                isPressed = pressed
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Standalone PAccordionItem (without container)

/// A standalone accordion item that manages its own state
/// Use this when you don't need group management
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PStandaloneAccordionItem<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - State
    
    @State private var isExpanded: Bool
    @State private var isPressed: Bool = false
    
    // MARK: - Properties
    
    private let title: String
    private let subtitle: String?
    private let icon: String?
    private let iconColor: Color?
    private let content: Content
    private var radius: RadiusSize? = nil
    private var showBorder: Bool = true
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var config: AccordionConfig {
        theme.components.accordion
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[radius ?? config.radius]
    }
    
    private var springAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(
            response: config.springResponse,
            dampingFraction: config.springDamping
        )
    }
    
    // MARK: - Initializer
    
    public init(
        _ title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color? = nil,
        initiallyExpanded: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self._isExpanded = State(initialValue: initiallyExpanded)
        self.content = content()
    }
    
    // Private init for modifiers
    private init(
        title: String,
        subtitle: String?,
        icon: String?,
        iconColor: Color?,
        isExpanded: Bool,
        content: Content,
        radius: RadiusSize?,
        showBorder: Bool
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self._isExpanded = State(initialValue: isExpanded)
        self.content = content
        self.radius = radius
        self.showBorder = showBorder
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: handleTap) {
                HStack(spacing: theme.spacing.md) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(iconColor ?? colors.primary)
                            .frame(width: 28, height: 28)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: theme.typography.sizes.base, weight: .medium))
                            .foregroundColor(colors.foreground)
                            .multilineTextAlignment(.leading)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.system(size: theme.typography.sizes.sm))
                                .foregroundColor(colors.mutedForeground)
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(springAnimation, value: isExpanded)
                }
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(AccordionHeaderButtonStyle(
                isPressed: $isPressed,
                pressedColor: colors.muted.opacity(0.5),
                reduceMotion: reduceMotion
            ))
            
            // Content
            if isExpanded {
                Divider()
                    .padding(.horizontal, theme.spacing.md)
                
                content
                    .padding(.horizontal, theme.spacing.md)
                    .padding(.vertical, theme.spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(colors.card)
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius))
        .overlay(
            RoundedRectangle(cornerRadius: resolvedRadius)
                .stroke(showBorder ? colors.border : Color.clear, lineWidth: 1)
        )
        .animation(springAnimation, value: isExpanded)
    }
    
    // MARK: - Actions
    
    private func handleTap() {
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
        
        withAnimation(springAnimation) {
            isExpanded.toggle()
        }
    }
}

// MARK: - PStandaloneAccordionItem Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PStandaloneAccordionItem {
    
    /// Set the corner radius
    public func radius(_ radius: RadiusSize) -> PStandaloneAccordionItem {
        PStandaloneAccordionItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            isExpanded: isExpanded,
            content: content,
            radius: radius,
            showBorder: showBorder
        )
    }
    
    /// Show or hide the border
    public func showBorder(_ show: Bool) -> PStandaloneAccordionItem {
        PStandaloneAccordionItem(
            title: title,
            subtitle: subtitle,
            icon: icon,
            iconColor: iconColor,
            isExpanded: isExpanded,
            content: content,
            radius: radius,
            showBorder: show
        )
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PAccordion_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Standard Accordion
                Group {
                    Text("Standard Accordion")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAccordion {
                        PAccordionItem("What is PrettyUI?") {
                            Text("PrettyUI is a beautiful SwiftUI component library inspired by Family.co's design system. It provides ready-to-use components with smooth animations and customizable themes.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        PAccordionItem("How do I get started?") {
                            Text("Simply add PrettyUI to your project using Swift Package Manager, import the library, and start using components like PButton, PCard, and PAccordion.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        PAccordionItem("Is it customizable?") {
                            Text("Yes! PrettyUI uses a comprehensive theming system. You can customize colors, spacing, radius, shadows, and more using theme presets or creating your own.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .showDivider(false)
                    }
                }
                
                Divider()
                
                // Separated Variant
                Group {
                    Text("Separated Variant")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAccordion {
                        PAccordionItem("Account Settings", icon: "person.circle.fill") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Manage your account preferences, profile information, and security settings.")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                
                                PButton("Edit Profile") {}
                                    .variant(.outline)
                                    .size(.sm)
                            }
                        }
                        .expanded(true)
                        
                        PAccordionItem("Notifications", subtitle: "3 unread", icon: "bell.fill") {
                            Text("Configure your notification preferences for alerts, updates, and promotional messages.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        PAccordionItem("Privacy & Security", icon: "lock.shield.fill") {
                            Text("Review and manage your privacy settings, connected apps, and security options.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                    .variant(.separated)
                    .expansionMode(.single)
                }
                
                Divider()
                
                // Bordered Variant
                Group {
                    Text("Bordered Variant")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAccordion {
                        PAccordionItem("Step 1: Create Account") {
                            Text("Sign up with your email address to create a new account.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        PAccordionItem("Step 2: Verify Email") {
                            Text("Check your inbox and click the verification link we sent you.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        
                        PAccordionItem("Step 3: Complete Setup") {
                            Text("Add your profile information and preferences to get started.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                        .showDivider(false)
                    }
                    .variant(.bordered)
                }
                
                Divider()
                
                // Standalone Item
                Group {
                    Text("Standalone Item")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PStandaloneAccordionItem(
                        "Advanced Options",
                        subtitle: "For power users",
                        icon: "slider.horizontal.3"
                    ) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("These settings are for advanced users who want more control over their experience.")
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                PButton("Reset") {}
                                    .variant(.destructive)
                                    .size(.sm)
                                
                                PButton("Save Changes") {}
                                    .variant(.primary)
                                    .size(.sm)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: "#F8F9FA"))
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode")
        
        ScrollView {
            VStack(spacing: 24) {
                PAccordion {
                    PAccordionItem("Dark Mode FAQ", icon: "moon.fill") {
                        Text("This accordion works beautifully in dark mode with automatic color adaptation.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .expanded(true)
                    
                    PAccordionItem("Another Question") {
                        Text("More content here...")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .showDivider(false)
                }
                .variant(.separated)
            }
            .padding()
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif

