//
//  PTopTab.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Top navigation tab bar component with segmented, pills, and underline styles.
//

import SwiftUI

// MARK: - Environment Keys

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<String>? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabStyleKey: EnvironmentKey {
    static let defaultValue: PTopTabStyle = .segmented
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabSizeKey: EnvironmentKey {
    static let defaultValue: PTopTabSize = .md
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabTransitionKey: EnvironmentKey {
    static let defaultValue: PTopTabTransition = .slide
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabListBackgroundKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabIndicatorColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

// Customization keys
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabFontSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabIndicatorInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabActiveColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabInactiveColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabPaddingKey: EnvironmentKey {
    static let defaultValue: EdgeInsets? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabFontWeightKey: EnvironmentKey {
    static let defaultValue: Font.Weight? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabFontDesignKey: EnvironmentKey {
    static let defaultValue: Font.Design? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabCustomFontKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabIconSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabIconPositionKey: EnvironmentKey {
    static let defaultValue: PTopTabIconPosition? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabIconSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabShowLabelsKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var topTabSelection: Binding<String>? {
        get { self[TopTabSelectionKey.self] }
        set { self[TopTabSelectionKey.self] = newValue }
    }
    
    var topTabStyle: PTopTabStyle {
        get { self[TopTabStyleKey.self] }
        set { self[TopTabStyleKey.self] = newValue }
    }
    
    var topTabSize: PTopTabSize {
        get { self[TopTabSizeKey.self] }
        set { self[TopTabSizeKey.self] = newValue }
    }
    
    var topTabTransition: PTopTabTransition {
        get { self[TopTabTransitionKey.self] }
        set { self[TopTabTransitionKey.self] = newValue }
    }
    
    var topTabListBackground: Color? {
        get { self[TopTabListBackgroundKey.self] }
        set { self[TopTabListBackgroundKey.self] = newValue }
    }
    
    var topTabIndicatorColor: Color? {
        get { self[TopTabIndicatorColorKey.self] }
        set { self[TopTabIndicatorColorKey.self] = newValue }
    }
    
    // Customization
    var topTabBarHeight: CGFloat? {
        get { self[TopTabBarHeightKey.self] }
        set { self[TopTabBarHeightKey.self] = newValue }
    }
    
    var topTabFontSize: CGFloat? {
        get { self[TopTabFontSizeKey.self] }
        set { self[TopTabFontSizeKey.self] = newValue }
    }
    
    var topTabIndicatorInset: CGFloat {
        get { self[TopTabIndicatorInsetKey.self] }
        set { self[TopTabIndicatorInsetKey.self] = newValue }
    }
    
    var topTabActiveColor: Color? {
        get { self[TopTabActiveColorKey.self] }
        set { self[TopTabActiveColorKey.self] = newValue }
    }
    
    var topTabInactiveColor: Color? {
        get { self[TopTabInactiveColorKey.self] }
        set { self[TopTabInactiveColorKey.self] = newValue }
    }
    
    var topTabPadding: EdgeInsets? {
        get { self[TopTabPaddingKey.self] }
        set { self[TopTabPaddingKey.self] = newValue }
    }
    
    var topTabFontWeight: Font.Weight? {
        get { self[TopTabFontWeightKey.self] }
        set { self[TopTabFontWeightKey.self] = newValue }
    }
    
    var topTabFontDesign: Font.Design? {
        get { self[TopTabFontDesignKey.self] }
        set { self[TopTabFontDesignKey.self] = newValue }
    }
    
    var topTabCustomFont: String? {
        get { self[TopTabCustomFontKey.self] }
        set { self[TopTabCustomFontKey.self] = newValue }
    }
    
    var topTabIconSize: CGFloat? {
        get { self[TopTabIconSizeKey.self] }
        set { self[TopTabIconSizeKey.self] = newValue }
    }
    
    var topTabIconPosition: PTopTabIconPosition? {
        get { self[TopTabIconPositionKey.self] }
        set { self[TopTabIconPositionKey.self] = newValue }
    }
    
    var topTabIconSpacing: CGFloat? {
        get { self[TopTabIconSpacingKey.self] }
        set { self[TopTabIconSpacingKey.self] = newValue }
    }
    
    var topTabShowLabels: Bool {
        get { self[TopTabShowLabelsKey.self] }
        set { self[TopTabShowLabelsKey.self] = newValue }
    }
}

// MARK: - Style & Size Enums

/// Visual style for top tabs
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PTopTabStyle: String, Equatable, Sendable, CaseIterable {
    /// Segmented control with background container
    case segmented
    /// Pill-shaped sliding indicator
    case pills
    /// Underline indicator
    case underline
}

/// Size variants for top tabs
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PTopTabSize: String, Equatable, Sendable, CaseIterable {
    case sm, md, lg
}

/// Content transition styles
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PTopTabTransition: String, Equatable, Sendable, CaseIterable {
    /// No transition
    case none
    /// Fade in/out with subtle scale
    case fade
    /// Slide from trailing edge
    case slide
    /// Scale up from center
    case scale
    /// Slide up from bottom
    case lift
    /// Zoom in with blur effect
    case zoom
}

// MARK: - PTopTab Container

/// A top navigation tab bar container.
///
/// Usage:
/// ```swift
/// @State var selected = "account"
///
/// PTopTab(selection: $selected) {
///     PTopTabList {
///         PTopTabTrigger("Account")
///         PTopTabTrigger("Password")
///     }
///
///     PTopTabContent("account") { AccountView() }
///     PTopTabContent("password") { PasswordView() }
/// }
/// .style(.segmented)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTopTab<Content: View>: View {
    
    @Binding private var selection: String
    private let content: Content
    private var style: PTopTabStyle = .segmented
    private var size: PTopTabSize = .md
    private var transition: PTopTabTransition = .slide
    
    public init(
        selection: Binding<String>,
        @ViewBuilder content: () -> Content
    ) {
        self._selection = selection
        self.content = content()
    }
    
    private init(
        selection: Binding<String>,
        content: Content,
        style: PTopTabStyle,
        size: PTopTabSize,
        transition: PTopTabTransition
    ) {
        self._selection = selection
        self.content = content
        self.style = style
        self.size = size
        self.transition = transition
    }
    
    public var body: some View {
        content
            .environment(\.topTabSelection, $selection)
            .environment(\.topTabStyle, style)
            .environment(\.topTabSize, size)
            .environment(\.topTabTransition, transition)
    }
}

// MARK: - PTopTab Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PTopTab {
    
    /// Set the visual style of tabs
    func style(_ style: PTopTabStyle) -> PTopTab {
        PTopTab(selection: $selection, content: content, style: style, size: size, transition: transition)
    }
    
    /// Set the size of tabs
    func size(_ size: PTopTabSize) -> PTopTab {
        PTopTab(selection: $selection, content: content, style: style, size: size, transition: transition)
    }
    
    /// Set the content transition animation
    func transition(_ transition: PTopTabTransition) -> PTopTab {
        PTopTab(selection: $selection, content: content, style: style, size: size, transition: transition)
    }
}

// MARK: - View Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    /// Set a custom background color for the top tab list container.
    func topTabListBackground(_ color: Color) -> some View {
        self.environment(\.topTabListBackground, color)
    }
    
    /// Set a custom color for the sliding indicator.
    func topTabIndicatorColor(_ color: Color) -> some View {
        self.environment(\.topTabIndicatorColor, color)
    }
    
    /// Set a custom height for the tab bar.
    func topTabBarHeight(_ height: CGFloat) -> some View {
        self.environment(\.topTabBarHeight, height)
    }
    
    /// Set a custom font size for tab triggers.
    func topTabFontSize(_ size: CGFloat) -> some View {
        self.environment(\.topTabFontSize, size)
    }
    
    /// Set the indicator inset (padding around content).
    /// Positive values make the indicator larger, negative values make it smaller.
    func topTabIndicatorInset(_ inset: CGFloat) -> some View {
        self.environment(\.topTabIndicatorInset, inset)
    }
    
    /// Set the active (selected) tab color.
    func topTabActiveColor(_ color: Color) -> some View {
        self.environment(\.topTabActiveColor, color)
    }
    
    /// Set the inactive (unselected) tab color.
    func topTabInactiveColor(_ color: Color) -> some View {
        self.environment(\.topTabInactiveColor, color)
    }
    
    /// Set custom padding for tab triggers.
    func topTabPadding(_ padding: EdgeInsets) -> some View {
        self.environment(\.topTabPadding, padding)
    }
    
    /// Set custom horizontal and vertical padding for tab triggers.
    func topTabPadding(horizontal: CGFloat, vertical: CGFloat) -> some View {
        self.environment(\.topTabPadding, EdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal))
    }
    
    /// Set the font weight for tab triggers.
    func topTabFontWeight(_ weight: Font.Weight) -> some View {
        self.environment(\.topTabFontWeight, weight)
    }
    
    /// Set the font design (default, serif, rounded, monospaced).
    func topTabFontDesign(_ design: Font.Design) -> some View {
        self.environment(\.topTabFontDesign, design)
    }
    
    /// Set a custom font family by name.
    func topTabFont(_ fontName: String) -> some View {
        self.environment(\.topTabCustomFont, fontName)
    }
    
    /// Set custom icon size for tab triggers.
    func topTabIconSize(_ size: CGFloat) -> some View {
        self.environment(\.topTabIconSize, size)
    }
    
    /// Set icon position relative to label (leading, trailing, top).
    func topTabIconPosition(_ position: PTopTabIconPosition) -> some View {
        self.environment(\.topTabIconPosition, position)
    }
    
    /// Set spacing between icon and label.
    func topTabIconSpacing(_ spacing: CGFloat) -> some View {
        self.environment(\.topTabIconSpacing, spacing)
    }
    
    /// Show or hide tab labels (icon-only mode when false).
    func topTabShowLabels(_ show: Bool) -> some View {
        self.environment(\.topTabShowLabels, show)
    }
}

// MARK: - Trigger Frame PreferenceKey

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct TopTabTriggerFrameKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - PTopTabList

/// Container for top tab triggers with sliding indicator animation.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTopTabList<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.topTabSelection) private var selection
    @Environment(\.topTabStyle) private var style
    @Environment(\.topTabSize) private var size
    @Environment(\.topTabListBackground) private var customBackground
    @Environment(\.topTabIndicatorColor) private var customIndicatorColor
    @Environment(\.topTabBarHeight) private var customHeight
    @Environment(\.topTabIndicatorInset) private var indicatorInset
    
    private let content: Content
    
    @State private var triggerFrames: [String: CGRect] = [:]
    
    private var colors: ColorTokens { theme.colors(for: colorScheme) }
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background container
                containerBackground
                
                // Sliding indicator
                slidingIndicator
                
                // Triggers
                HStack(spacing: triggerSpacing) {
                    content
                }
                .padding(containerPadding)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity)
        .frame(height: customHeight ?? defaultHeight)
        .coordinateSpace(name: "topTabList")
        .onPreferenceChange(TopTabTriggerFrameKey.self) { frames in
            triggerFrames = frames
        }
    }
    
    private var defaultHeight: CGFloat {
        switch size {
        case .sm: return 36
        case .md: return 40
        case .lg: return 48
        }
    }
    
    // MARK: - Indicator
    
    @ViewBuilder
    private var slidingIndicator: some View {
        if let selectedValue = selection?.wrappedValue,
           let frame = triggerFrames[selectedValue],
           frame.width > 0 {
            
            switch style {
            case .segmented:
                RoundedRectangle(cornerRadius: indicatorRadius, style: .continuous)
                    .fill(customIndicatorColor ?? colors.card)
                    .shadow(color: Color.black.opacity(0.06), radius: 2, x: 0, y: 1)
                    .frame(width: frame.width + indicatorInset, height: frame.height + indicatorInset)
                    .position(x: frame.midX, y: frame.midY)
                    .animation(springAnimation, value: selectedValue)
                    
            case .pills:
                Capsule()
                    .fill(customIndicatorColor ?? colors.foreground)
                    .frame(width: frame.width + indicatorInset, height: frame.height + indicatorInset)
                    .position(x: frame.midX, y: frame.midY)
                    .animation(springAnimation, value: selectedValue)
                    
            case .underline:
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(customIndicatorColor ?? colors.primary)
                    .frame(width: frame.width - 8 + indicatorInset, height: 2)
                    .position(x: frame.midX, y: frame.maxY - 1)
                    .animation(springAnimation, value: selectedValue)
            }
        }
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var containerBackground: some View {
        switch style {
        case .segmented:
            RoundedRectangle(cornerRadius: containerRadius, style: .continuous)
                .fill(customBackground ?? colors.muted.opacity(0.6))
        case .pills:
            if let bg = customBackground {
                Capsule().fill(bg)
            } else {
                Color.clear
            }
        case .underline:
            Color.clear
        }
    }
    
    // MARK: - Styling
    
    private var springAnimation: Animation {
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    }
    
    private var triggerSpacing: CGFloat {
        switch style {
        case .segmented: return 0
        case .pills: return 4
        case .underline: return 8
        }
    }
    
    private var containerPadding: CGFloat {
        switch style {
        case .segmented: return 3
        case .pills, .underline: return 0
        }
    }
    
    private var containerRadius: CGFloat {
        switch size {
        case .sm: return 8
        case .md: return 10
        case .lg: return 12
        }
    }
    
    private var indicatorRadius: CGFloat {
        switch size {
        case .sm: return 6
        case .md: return 8
        case .lg: return 10
        }
    }
}

// MARK: - PTopTabTrigger

/// Icon position for top tab triggers
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PTopTabIconPosition: String, Equatable, Sendable {
    case leading
    case trailing
    case top
}

/// Individual top tab button.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTopTabTrigger<Label: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.topTabSelection) private var selection
    @Environment(\.topTabStyle) private var style
    @Environment(\.topTabSize) private var size
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.topTabFontSize) private var customFontSize
    @Environment(\.topTabActiveColor) private var customActiveColor
    @Environment(\.topTabInactiveColor) private var customInactiveColor
    @Environment(\.topTabPadding) private var customPadding
    @Environment(\.topTabFontWeight) private var customFontWeight
    @Environment(\.topTabFontDesign) private var customFontDesign
    @Environment(\.topTabCustomFont) private var customFontName
    @Environment(\.topTabIconSize) private var customIconSize
    @Environment(\.topTabIconPosition) private var iconPosition
    @Environment(\.topTabIconSpacing) private var iconSpacing
    @Environment(\.topTabShowLabels) private var showLabels
    
    private let value: String
    private let label: Label
    private let icon: String?
    private let activeIcon: String?
    
    @State private var isPressed = false
    
    private var colors: ColorTokens { theme.colors(for: colorScheme) }
    private var isSelected: Bool { selection?.wrappedValue == value }
    
    /// Create a trigger with custom label
    public init(
        value: String,
        icon: String? = nil,
        activeIcon: String? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.value = value
        self.label = label()
        self.icon = icon
        self.activeIcon = activeIcon
    }
    
    public var body: some View {
        Button {
            selection?.wrappedValue = value
            triggerHaptic()
        } label: {
            triggerContent
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: TopTabTriggerFrameKey.self,
                                value: [value: geo.frame(in: .named("topTabList"))]
                            )
                    }
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(pressAnimation, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed { isPressed = true }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .accessibilityLabel(value)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
    
    @ViewBuilder
    private var triggerContent: some View {
        Group {
            if let iconName = icon {
                iconLabelContent(iconName: iconName)
            } else {
                label
                    .font(labelFont)
                    .fontWeight(customFontWeight ?? (isSelected ? .semibold : .medium))
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, customPadding?.leading ?? horizontalPadding)
        .padding(.vertical, customPadding?.top ?? verticalPadding)
    }
    
    @ViewBuilder
    private func iconLabelContent(iconName: String) -> some View {
        let spacing = iconSpacing ?? 6.0
        let position = iconPosition ?? .leading
        
        switch position {
        case .top:
            VStack(spacing: spacing) {
                iconView(iconName)
                if showLabels {
                    label
                        .font(labelFont)
                        .fontWeight(customFontWeight ?? (isSelected ? .semibold : .medium))
                }
            }
        case .leading:
            HStack(spacing: spacing) {
                iconView(iconName)
                if showLabels {
                    label
                        .font(labelFont)
                        .fontWeight(customFontWeight ?? (isSelected ? .semibold : .medium))
                }
            }
        case .trailing:
            HStack(spacing: spacing) {
                if showLabels {
                    label
                        .font(labelFont)
                        .fontWeight(customFontWeight ?? (isSelected ? .semibold : .medium))
                }
                iconView(iconName)
            }
        }
    }
    
    @ViewBuilder
    private func iconView(_ iconName: String) -> some View {
        Image(systemName: currentIcon(iconName))
            .font(.system(size: customIconSize ?? iconSize))
            .symbolRenderingMode(.hierarchical)
    }
    
    /// Returns the appropriate icon based on selection state
    private func currentIcon(_ inactiveIconName: String) -> String {
        if isSelected {
            // Use explicit activeIcon if provided, otherwise auto-fill
            return activeIcon ?? filledIcon(inactiveIconName)
        }
        return inactiveIconName
    }
    
    /// Converts outline icon to filled version (fallback when no activeIcon specified)
    private func filledIcon(_ name: String) -> String {
        if name.hasSuffix(".fill") { return name }
        return "\(name).fill"
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .sm: return 14
        case .md: return 16
        case .lg: return 18
        }
    }
    
    private var foregroundColor: Color {
        if isSelected {
            if let activeColor = customActiveColor {
                return activeColor
            }
            switch style {
            case .segmented: return colors.foreground
            case .pills: return colors.background
            case .underline: return colors.primary
            }
        } else {
            return customInactiveColor ?? colors.mutedForeground
        }
    }
    
    private var labelFont: Font {
        let fontSize = customFontSize ?? defaultFontSize
        
        // Use custom font family if provided
        if let fontName = customFontName {
            return .custom(fontName, size: fontSize)
        }
        
        // Use system font with optional design
        if let design = customFontDesign {
            return .system(size: fontSize, design: design)
        }
        
        return .system(size: fontSize)
    }
    
    private var defaultFontSize: CGFloat {
        switch size {
        case .sm: return 13
        case .md: return 14
        case .lg: return 16
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .sm: return 10
        case .md: return 12
        case .lg: return 16
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .sm: return 6
        case .md: return 8
        case .lg: return 10
        }
    }
    
    private var pressAnimation: Animation {
        reduceMotion ? .linear(duration: 0.1) : .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0)
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - PTopTabTrigger Convenience Inits

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PTopTabTrigger where Label == Text {
    
    /// Create a trigger with text label
    init(_ value: String) {
        self.value = value
        self.label = Text(value)
        self.icon = nil
        self.activeIcon = nil
    }
    
    /// Create a trigger with text label and icon (auto-fills when selected)
    init(_ value: String, icon: String) {
        self.value = value
        self.label = Text(value)
        self.icon = icon
        self.activeIcon = nil
    }
    
    /// Create a trigger with text label and separate inactive/active icons
    init(_ value: String, icon: String, activeIcon: String) {
        self.value = value
        self.label = Text(value)
        self.icon = icon
        self.activeIcon = activeIcon
    }
    
    /// Create an icon-only trigger with separate inactive/active icons
    init(value: String, icon: String, activeIcon: String? = nil) {
        self.value = value
        self.label = Text(value)
        self.icon = icon
        self.activeIcon = activeIcon
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PTopTabTrigger where Label == SwiftUI.Label<Text, Image> {
    
    /// Create a trigger with SwiftUI Label (text and inline icon)
    init(_ value: String, systemImage: String) {
        self.value = value
        self.label = SwiftUI.Label(value, systemImage: systemImage)
        self.icon = nil
        self.activeIcon = nil
    }
}

// MARK: - PTopTabPane

/// Container for top tab content that fills available space.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTopTabPane<Content: View>: View {
    
    @Environment(\.topTabSelection) private var selection
    @Environment(\.topTabTransition) private var transition
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }
}

// MARK: - PTopTabContent

/// Content panel that shows/hides based on selection.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTopTabContent<Content: View>: View {
    
    @Environment(\.topTabSelection) private var selection
    @Environment(\.topTabTransition) private var transition
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    private let value: String
    private let content: Content
    
    private var isSelected: Bool { selection?.wrappedValue == value }
    
    public init(
        _ value: String,
        @ViewBuilder content: () -> Content
    ) {
        self.value = value
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            if isSelected {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(contentTransition)
            }
        }
        .animation(contentAnimation, value: selection?.wrappedValue)
    }
    
    private var contentAnimation: Animation {
        reduceMotion
            ? .linear(duration: 0.15)
            : .timingCurve(0.22, 1, 0.36, 1, duration: 0.45)
    }
    
    private var contentTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        
        switch transition {
        case .none:
            return .identity
            
        case .fade:
            return .asymmetric(
                insertion: .opacity
                    .combined(with: .scale(scale: 0.96, anchor: .center))
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.4)),
                removal: .opacity
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.3))
            )
            
        case .slide:
            return .asymmetric(
                insertion: .push(from: .trailing)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.45)),
                removal: .push(from: .trailing)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.45))
            )
            
        case .scale:
            return .asymmetric(
                insertion: .scale(scale: 0.8, anchor: .center)
                    .combined(with: .opacity)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.4)),
                removal: .scale(scale: 1.1, anchor: .center)
                    .combined(with: .opacity)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.3))
            )
            
        case .lift:
            return .asymmetric(
                insertion: .move(edge: .bottom)
                    .combined(with: .opacity)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.45)),
                removal: .move(edge: .top)
                    .combined(with: .opacity)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.35))
            )
            
        case .zoom:
            return .asymmetric(
                insertion: .scale(scale: 0.5, anchor: .center)
                    .combined(with: .opacity)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.5)),
                removal: .scale(scale: 1.5, anchor: .center)
                    .combined(with: .opacity)
                    .animation(.timingCurve(0.22, 1, 0.36, 1, duration: 0.35))
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PTopTab_Previews: PreviewProvider {
    
    struct SegmentedPreview: View {
        @State private var selected = "Account"
        
        var body: some View {
            VStack(spacing: 0) {
                PTopTab(selection: $selected) {
                    VStack(spacing: 0) {
                        PTopTabList {
                            PTopTabTrigger("Account", icon: "house", activeIcon: "house.fill")
                            PTopTabTrigger("Password", icon: "gear", activeIcon: "gearshape.fill")
                        }
                        .padding(.horizontal)
                        
                        PTopTabPane {
                            PTopTabContent("Account") {
                                VStack {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.blue)
                                    Text("Account Settings")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            PTopTabContent("Password") {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.green)
                                    Text("Password Settings")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            PTopTabContent("Settings") {
                                VStack {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.purple)
                                    Text("General Settings")
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
                .style(.pills)
                .transition(.slide)
                .topTabFontSize(18)
                .topTabFontWeight(.heavy)
                .topTabActiveColor(.white)
                .topTabInactiveColor(.gray.opacity(0.6))
            }
        }
    }
    
    struct PillsPreview: View {
        @State private var selected = "Tokens"
        
        var body: some View {
            VStack(spacing: 0) {
                PTopTab(selection: $selected) {
                    VStack(spacing: 0) {
                        PTopTabList {
                            PTopTabTrigger("Tokens", icon: "bitcoinsign.circle")
                            PTopTabTrigger("NFTs", icon: "photo.stack")
                            PTopTabTrigger("Activity", icon: "chart.line.uptrend.xyaxis")
                        }
                        .padding(.horizontal)
                        
                        PTopTabPane {
                            PTopTabContent("Tokens") {
                                Text("Tokens List").font(.title)
                            }
                            PTopTabContent("NFTs") {
                                Text("NFT Gallery").font(.title)
                            }
                            PTopTabContent("Activity") {
                                Text("Activity Feed").font(.title)
                            }
                        }
                    }
                }
                .style(.pills)
                .topTabIconPosition(.leading)
                .topTabIconSpacing(6)
            }
        }
    }
    
    struct IconOnlyPreview: View {
        @State private var selected = "Home"
        
        var body: some View {
            VStack(spacing: 0) {
                PTopTab(selection: $selected) {
                    VStack(spacing: 0) {
                        PTopTabList {
                            PTopTabTrigger("Home", icon: "house")
                            PTopTabTrigger("Search", icon: "magnifyingglass")
                            PTopTabTrigger("Favorites", icon: "heart")
                            PTopTabTrigger("Profile", icon: "person")
                        }
                        .padding(.horizontal)
                        
                        PTopTabPane {
                            PTopTabContent("Home") {
                                Text("Home Screen").font(.title)
                            }
                            PTopTabContent("Search") {
                                Text("Search Screen").font(.title)
                            }
                            PTopTabContent("Favorites") {
                                Text("Favorites Screen").font(.title)
                            }
                            PTopTabContent("Profile") {
                                Text("Profile Screen").font(.title)
                            }
                        }
                    }
                }
                .style(.segmented)
                .topTabShowLabels(false)
                .topTabIconSize(20)
            }
        }
    }
    
    struct UnderlinePreview: View {
        @State private var selected = "Overview"
        
        var body: some View {
            VStack(spacing: 0) {
                PTopTab(selection: $selected) {
                    VStack(spacing: 0) {
                        PTopTabList {
                            PTopTabTrigger("Overview")
                            PTopTabTrigger("Analytics")
                            PTopTabTrigger("Reports")
                        }
                        .padding(.horizontal)
                        
                        PTopTabPane {
                            PTopTabContent("Overview") {
                                Text("Overview Content").font(.title)
                            }
                            PTopTabContent("Analytics") {
                                Text("Analytics Dashboard").font(.title)
                            }
                            PTopTabContent("Reports") {
                                Text("Reports Section").font(.title)
                            }
                        }
                    }
                }
                .style(.underline)
            }
        }
    }
    
    static var previews: some View {
        Group {
            SegmentedPreview()
                .prettyTheme(.family)
                .previewDisplayName("Segmented")
            
            PillsPreview()
                .prettyTheme(.family)
                .previewDisplayName("Pills with Icons")
            
            IconOnlyPreview()
                .prettyTheme(.family)
                .previewDisplayName("Icon Only")
            
            UnderlinePreview()
                .prettyTheme(.family)
                .previewDisplayName("Underline")
        }
    }
}
#endif
