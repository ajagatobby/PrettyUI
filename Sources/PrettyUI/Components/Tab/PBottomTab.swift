//
//  PBottomTab.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Bottom navigation tab bar component with standard and floating styles.
//

import SwiftUI

// MARK: - Environment Keys

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<String>? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabStyleKey: EnvironmentKey {
    static let defaultValue: PBottomTabStyle = .standard
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabSizeKey: EnvironmentKey {
    static let defaultValue: PBottomTabSize = .md
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabTransitionKey: EnvironmentKey {
    static let defaultValue: PBottomTabTransition = .slide
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabListBackgroundKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabIndicatorColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

// Customization keys
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabIconSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabLabelSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabIndicatorInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabActiveColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabInactiveColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabShowLabelsKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabSpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabFontWeightKey: EnvironmentKey {
    static let defaultValue: Font.Weight? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabFontDesignKey: EnvironmentKey {
    static let defaultValue: Font.Design? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabCustomFontKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var bottomTabSelection: Binding<String>? {
        get { self[BottomTabSelectionKey.self] }
        set { self[BottomTabSelectionKey.self] = newValue }
    }
    
    var bottomTabStyle: PBottomTabStyle {
        get { self[BottomTabStyleKey.self] }
        set { self[BottomTabStyleKey.self] = newValue }
    }
    
    var bottomTabSize: PBottomTabSize {
        get { self[BottomTabSizeKey.self] }
        set { self[BottomTabSizeKey.self] = newValue }
    }
    
    var bottomTabTransition: PBottomTabTransition {
        get { self[BottomTabTransitionKey.self] }
        set { self[BottomTabTransitionKey.self] = newValue }
    }
    
    var bottomTabListBackground: Color? {
        get { self[BottomTabListBackgroundKey.self] }
        set { self[BottomTabListBackgroundKey.self] = newValue }
    }
    
    var bottomTabIndicatorColor: Color? {
        get { self[BottomTabIndicatorColorKey.self] }
        set { self[BottomTabIndicatorColorKey.self] = newValue }
    }
    
    // Customization
    var bottomTabBarHeight: CGFloat? {
        get { self[BottomTabBarHeightKey.self] }
        set { self[BottomTabBarHeightKey.self] = newValue }
    }
    
    var bottomTabIconSize: CGFloat? {
        get { self[BottomTabIconSizeKey.self] }
        set { self[BottomTabIconSizeKey.self] = newValue }
    }
    
    var bottomTabLabelSize: CGFloat? {
        get { self[BottomTabLabelSizeKey.self] }
        set { self[BottomTabLabelSizeKey.self] = newValue }
    }
    
    var bottomTabIndicatorInset: CGFloat {
        get { self[BottomTabIndicatorInsetKey.self] }
        set { self[BottomTabIndicatorInsetKey.self] = newValue }
    }
    
    var bottomTabActiveColor: Color? {
        get { self[BottomTabActiveColorKey.self] }
        set { self[BottomTabActiveColorKey.self] = newValue }
    }
    
    var bottomTabInactiveColor: Color? {
        get { self[BottomTabInactiveColorKey.self] }
        set { self[BottomTabInactiveColorKey.self] = newValue }
    }
    
    var bottomTabShowLabels: Bool {
        get { self[BottomTabShowLabelsKey.self] }
        set { self[BottomTabShowLabelsKey.self] = newValue }
    }
    
    var bottomTabSpacing: CGFloat? {
        get { self[BottomTabSpacingKey.self] }
        set { self[BottomTabSpacingKey.self] = newValue }
    }
    
    var bottomTabFontWeight: Font.Weight? {
        get { self[BottomTabFontWeightKey.self] }
        set { self[BottomTabFontWeightKey.self] = newValue }
    }
    
    var bottomTabFontDesign: Font.Design? {
        get { self[BottomTabFontDesignKey.self] }
        set { self[BottomTabFontDesignKey.self] = newValue }
    }
    
    var bottomTabCustomFont: String? {
        get { self[BottomTabCustomFontKey.self] }
        set { self[BottomTabCustomFontKey.self] = newValue }
    }
}

// MARK: - Style & Size Enums

/// Visual style for bottom tabs
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PBottomTabStyle: String, Equatable, Sendable, CaseIterable {
    /// Standard iOS tab bar style
    case standard
    /// Floating pill bar
    case floating
}

/// Size variants for bottom tabs
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PBottomTabSize: String, Equatable, Sendable, CaseIterable {
    case sm, md, lg
}

/// Content transition styles
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public enum PBottomTabTransition: String, Equatable, Sendable, CaseIterable {
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

// MARK: - PBottomTab Container

/// A bottom navigation tab bar container.
///
/// Usage:
/// ```swift
/// @State var selected = "Home"
///
/// PBottomTab(selection: $selected) {
///     VStack(spacing: 0) {
///         PBottomTabPane {
///             PBottomTabContent("Home") { HomeView() }
///             PBottomTabContent("Settings") { SettingsView() }
///         }
///         
///         PBottomTabList {
///             PBottomTabTrigger("Home", icon: "house")
///             PBottomTabTrigger("Settings", icon: "gearshape")
///         }
///     }
/// }
/// .style(.floating)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PBottomTab<Content: View>: View {
    
    @Binding private var selection: String
    private let content: Content
    private var style: PBottomTabStyle = .standard
    private var size: PBottomTabSize = .md
    private var transition: PBottomTabTransition = .slide
    
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
        style: PBottomTabStyle,
        size: PBottomTabSize,
        transition: PBottomTabTransition
    ) {
        self._selection = selection
        self.content = content
        self.style = style
        self.size = size
        self.transition = transition
    }
    
    public var body: some View {
        content
            .environment(\.bottomTabSelection, $selection)
            .environment(\.bottomTabStyle, style)
            .environment(\.bottomTabSize, size)
            .environment(\.bottomTabTransition, transition)
    }
}

// MARK: - PBottomTab Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PBottomTab {
    
    /// Set the visual style of tabs
    func style(_ style: PBottomTabStyle) -> PBottomTab {
        PBottomTab(selection: $selection, content: content, style: style, size: size, transition: transition)
    }
    
    /// Set the size of tabs
    func size(_ size: PBottomTabSize) -> PBottomTab {
        PBottomTab(selection: $selection, content: content, style: style, size: size, transition: transition)
    }
    
    /// Set the content transition animation
    func transition(_ transition: PBottomTabTransition) -> PBottomTab {
        PBottomTab(selection: $selection, content: content, style: style, size: size, transition: transition)
    }
}

// MARK: - View Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    /// Set a custom background color for the bottom tab list container.
    func bottomTabListBackground(_ color: Color) -> some View {
        self.environment(\.bottomTabListBackground, color)
    }
    
    /// Set a custom color for the sliding indicator.
    func bottomTabIndicatorColor(_ color: Color) -> some View {
        self.environment(\.bottomTabIndicatorColor, color)
    }
    
    /// Set a custom height for the tab bar.
    func bottomTabBarHeight(_ height: CGFloat) -> some View {
        self.environment(\.bottomTabBarHeight, height)
    }
    
    /// Set a custom icon size for tab triggers.
    func bottomTabIconSize(_ size: CGFloat) -> some View {
        self.environment(\.bottomTabIconSize, size)
    }
    
    /// Set a custom label font size for tab triggers.
    func bottomTabLabelSize(_ size: CGFloat) -> some View {
        self.environment(\.bottomTabLabelSize, size)
    }
    
    /// Set the indicator inset (padding around content).
    /// Positive values make the indicator larger, negative values make it smaller.
    func bottomTabIndicatorInset(_ inset: CGFloat) -> some View {
        self.environment(\.bottomTabIndicatorInset, inset)
    }
    
    /// Set the active (selected) tab color.
    func bottomTabActiveColor(_ color: Color) -> some View {
        self.environment(\.bottomTabActiveColor, color)
    }
    
    /// Set the inactive (unselected) tab color.
    func bottomTabInactiveColor(_ color: Color) -> some View {
        self.environment(\.bottomTabInactiveColor, color)
    }
    
    /// Show or hide tab labels.
    func bottomTabShowLabels(_ show: Bool) -> some View {
        self.environment(\.bottomTabShowLabels, show)
    }
    
    /// Set custom spacing between icon and label.
    func bottomTabSpacing(_ spacing: CGFloat) -> some View {
        self.environment(\.bottomTabSpacing, spacing)
    }
    
    /// Set the font weight for tab labels.
    func bottomTabFontWeight(_ weight: Font.Weight) -> some View {
        self.environment(\.bottomTabFontWeight, weight)
    }
    
    /// Set the font design (default, serif, rounded, monospaced).
    func bottomTabFontDesign(_ design: Font.Design) -> some View {
        self.environment(\.bottomTabFontDesign, design)
    }
    
    /// Set a custom font family by name.
    func bottomTabFont(_ fontName: String) -> some View {
        self.environment(\.bottomTabCustomFont, fontName)
    }
}

// MARK: - Trigger Frame PreferenceKey

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct BottomTabTriggerFrameKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: [String: CGRect] = [:]
    
    static func reduce(value: inout [String: CGRect], nextValue: () -> [String: CGRect]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - PBottomTabList

/// Container for bottom tab triggers with optional sliding indicator.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PBottomTabList<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.bottomTabSelection) private var selection
    @Environment(\.bottomTabStyle) private var style
    @Environment(\.bottomTabSize) private var size
    @Environment(\.bottomTabListBackground) private var customBackground
    @Environment(\.bottomTabIndicatorColor) private var customIndicatorColor
    @Environment(\.bottomTabBarHeight) private var customHeight
    @Environment(\.bottomTabIndicatorInset) private var indicatorInset
    
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
                
                // Sliding indicator (only for floating style)
                if style == .floating {
                    slidingIndicator
                }
                
                // Triggers
                HStack(spacing: 0) {
                    content
                }
                .padding(containerPadding)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity)
        .frame(height: customHeight ?? defaultHeight)
        .coordinateSpace(name: "bottomTabList")
        .onPreferenceChange(BottomTabTriggerFrameKey.self) { frames in
            triggerFrames = frames
        }
    }
    
    private var defaultHeight: CGFloat {
        switch size {
        case .sm: return 52
        case .md: return 60
        case .lg: return 68
        }
    }
    
    // MARK: - Indicator
    
    @ViewBuilder
    private var slidingIndicator: some View {
        if let selectedValue = selection?.wrappedValue,
           let frame = triggerFrames[selectedValue],
           frame.width > 0 {
            
            Capsule()
                .fill(customIndicatorColor ?? colors.card)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                .frame(width: frame.width + 16 + indicatorInset, height: frame.height + indicatorInset)
                .position(x: frame.midX, y: frame.midY)
                .animation(springAnimation, value: selectedValue)
        }
    }
    
    // MARK: - Background
    
    @ViewBuilder
    private var containerBackground: some View {
        switch style {
        case .standard:
            Rectangle()
                .fill(customBackground ?? colors.card)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(colors.border)
                        .frame(height: 0.5)
                }
        case .floating:
            Capsule()
                .fill(customBackground ?? colors.muted.opacity(0.8))
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
        }
    }
    
    // MARK: - Styling
    
    private var springAnimation: Animation {
        .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0)
    }
    
    private var containerPadding: CGFloat {
        switch style {
        case .standard: return 8
        case .floating: return 4
        }
    }
}

// MARK: - PBottomTabTrigger

/// Individual bottom tab button with icon and label.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PBottomTabTrigger: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.bottomTabSelection) private var selection
    @Environment(\.bottomTabStyle) private var style
    @Environment(\.bottomTabSize) private var size
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.bottomTabIconSize) private var customIconSize
    @Environment(\.bottomTabLabelSize) private var customLabelSize
    @Environment(\.bottomTabActiveColor) private var customActiveColor
    @Environment(\.bottomTabInactiveColor) private var customInactiveColor
    @Environment(\.bottomTabShowLabels) private var showLabels
    @Environment(\.bottomTabSpacing) private var customSpacing
    @Environment(\.bottomTabFontWeight) private var customFontWeight
    @Environment(\.bottomTabFontDesign) private var customFontDesign
    @Environment(\.bottomTabCustomFont) private var customFontName
    
    private let value: String
    private let icon: String
    private let activeIcon: String?
    private let badge: Int?
    
    @State private var isPressed = false
    
    private var colors: ColorTokens { theme.colors(for: colorScheme) }
    private var isSelected: Bool { selection?.wrappedValue == value }
    
    /// Create a trigger with icon and optional badge (auto-fills when selected)
    public init(
        _ value: String,
        icon: String,
        badge: Int? = nil
    ) {
        self.value = value
        self.icon = icon
        self.activeIcon = nil
        self.badge = badge
    }
    
    /// Create a trigger with separate inactive/active icons and optional badge
    public init(
        _ value: String,
        icon: String,
        activeIcon: String,
        badge: Int? = nil
    ) {
        self.value = value
        self.icon = icon
        self.activeIcon = activeIcon
        self.badge = badge
    }
    
    public var body: some View {
        Button {
            selection?.wrappedValue = value
            triggerHaptic()
        } label: {
            // For floating style, measure content size for indicator
            if style == .floating {
                triggerContent
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: BottomTabTriggerFrameKey.self,
                                    value: [value: geo.frame(in: .named("bottomTabList"))]
                                )
                        }
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .contentShape(Rectangle())
            } else {
                triggerContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(
                                    key: BottomTabTriggerFrameKey.self,
                                    value: [value: geo.frame(in: .named("bottomTabList"))]
                                )
                        }
                    )
                    .contentShape(Rectangle())
            }
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
        VStack(alignment: .center, spacing: customSpacing ?? 3) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: currentIcon)
                    .font(.system(size: customIconSize ?? iconSize))
                    .symbolRenderingMode(.hierarchical)
                
                // Badge
                if let badgeCount = badge, badgeCount > 0 {
                    Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(colors.destructive))
                        .offset(x: 10, y: -6)
                }
            }
            
            if showLabels {
                Text(value)
                    .font(labelFont)
                    .fontWeight(customFontWeight ?? (isSelected ? .medium : .regular))
            }
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
    
    /// Returns the appropriate icon based on selection state
    private var currentIcon: String {
        if isSelected {
            // Use explicit activeIcon if provided, otherwise auto-fill
            return activeIcon ?? filledIcon(icon)
        }
        return icon
    }
    
    private var labelFont: Font {
        let fontSize = customLabelSize ?? labelSize
        
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
    
    /// Converts outline icon to filled version (fallback when no activeIcon specified)
    private func filledIcon(_ name: String) -> String {
        if name.hasSuffix(".fill") { return name }
        return "\(name).fill"
    }
    
    private var foregroundColor: Color {
        if isSelected {
            return customActiveColor ?? colors.primary
        } else {
            return customInactiveColor ?? colors.mutedForeground
        }
    }
    
    private var iconSize: CGFloat {
        switch size {
        case .sm: return 20
        case .md: return 22
        case .lg: return 26
        }
    }
    
    private var labelSize: CGFloat {
        switch size {
        case .sm: return 10
        case .md: return 11
        case .lg: return 12
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

// MARK: - PBottomTabPane

/// Container for bottom tab content that fills available space.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PBottomTabPane<Content: View>: View {
    
    @Environment(\.bottomTabSelection) private var selection
    @Environment(\.bottomTabTransition) private var transition
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

// MARK: - PBottomTabContent

/// Content panel that shows/hides based on selection.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PBottomTabContent<Content: View>: View {
    
    @Environment(\.bottomTabSelection) private var selection
    @Environment(\.bottomTabTransition) private var transition
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
struct PBottomTab_Previews: PreviewProvider {
    
    struct StandardPreview: View {
        @State private var selected = "Home"
        
        var body: some View {
            PBottomTab(selection: $selected) {
                VStack(spacing: 0) {
                    PBottomTabPane {
                        PBottomTabContent("Home") {
                            VStack {
                                Spacer()
                                Image(systemName: "house.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                                Text("Home")
                                Spacer()
                            }
                        }
                        PBottomTabContent("Search") {
                            VStack {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.green)
                                Text("Search")
                                Spacer()
                            }
                        }
                        PBottomTabContent("Profile") {
                            VStack {
                                Spacer()
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.purple)
                                Text("Profile")
                                Spacer()
                            }
                        }
                        PBottomTabContent("Settings") {
                            VStack {
                                Spacer()
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                Text("Settings")
                                Spacer()
                            }
                        }
                    }
                    
                    PBottomTabList {
                        PBottomTabTrigger("Home", icon: "house")
                        PBottomTabTrigger("Search", icon: "magnifyingglass")
                        PBottomTabTrigger("Profile", icon: "person", badge: 3)
                        PBottomTabTrigger("Settings", icon: "gearshape")
                    }
                }
            }
            .style(.standard)
        }
    }
    
    struct FloatingPreview: View {
        @State private var selected = "Home"
        
        var body: some View {
            PBottomTab(selection: $selected) {
                ZStack(alignment: .bottom) {
                    PBottomTabPane {
                        PBottomTabContent("Home") {
                            Color.blue.opacity(0.1)
                                .overlay(
                                    VStack {
                                        Image(systemName: "house.fill")
                                            .font(.system(size: 50))
                                        Text("Home")
                                    }
                                )
                        }
                        PBottomTabContent("Cars") {
                            Color.green.opacity(0.1)
                                .overlay(
                                    VStack {
                                        Image(systemName: "car")
                                            .font(.system(size: 50))
                                        Text("Cars")
                                    }
                                )
                        }
                        PBottomTabContent("Files") {
                            Color.green.opacity(0.1)
                                .overlay(
                                    VStack {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 50))
                                        Text("Search")
                                    }
                                )
                        }
                        PBottomTabContent("Profile") {
                            Color.purple.opacity(0.1)
                                .overlay(
                                    VStack {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                        Text("Profile")
                                    }
                                )
                        }
                    }
                    
                    PBottomTabList {
                        PBottomTabTrigger("Home", icon: "house")
                        PBottomTabTrigger("Cars", icon: "car")
                        PBottomTabTrigger("Files", icon: "folder")
                        PBottomTabTrigger("Profile", icon: "person")
                    }
                    .bottomTabListBackground(Color.black.opacity(0.85))
                    .bottomTabIndicatorColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.bottom)
                }
            }
            .style(.floating)
            .transition(.slide)
            .ignoresSafeArea(.all)
        }
    }
    
    static var previews: some View {
        Group {
            StandardPreview()
                .prettyTheme(.family)
                .previewDisplayName("Standard")
            
            FloatingPreview()
                .prettyTheme(.family)
                .previewDisplayName("Floating")
        }
    }
}
#endif

