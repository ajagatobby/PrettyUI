//
//  PMorphingFAB.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired morphing FAB component that transforms from a circular
//  button into an expandable menu and optionally into full-screen content.
//

import SwiftUI

// MARK: - Enums

/// Appearance mode for the FAB
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public enum PFABAppearance {
    case light      // Light background, dark icon
    case dark       // Dark background, light icon
    case system     // Follows system color scheme
    case custom     // Uses custom tint and icon colors
}

/// Shape of the FAB button
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public enum PFABShape {
    case circle
    case roundedSquare(cornerRadius: CGFloat)
    case capsule
}

/// Position/alignment for the expanded menu
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public enum PFABMenuAlignment {
    case bottom
    case center
    case top
}

/// Haptic feedback style
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public enum PFABHapticStyle {
    case none
    case light
    case medium
    case heavy
    case soft
    case rigid
}

// MARK: - Configuration

/// Configuration for PExpandableFAB styling
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable, message: "PExpandableFAB is not available on macOS")
public struct PExpandableFABConfiguration {
    // MARK: - Size & Shape
    var size: CGFloat = 56
    var shape: PFABShape = .circle
    var expandedCornerRadius: CGFloat = 30
    
    // MARK: - Appearance
    var appearance: PFABAppearance = .light
    var customTint: Color? = nil
    var customIconColor: Color? = nil
    var expandedTint: Color? = nil  // Different color when expanded
    
    // MARK: - Border
    var borderColor: Color? = nil
    var borderWidth: CGFloat = 0
    var expandedBorderColor: Color? = nil
    var expandedBorderWidth: CGFloat = 0
    
    // MARK: - Shadow
    var shadow: ShadowSize = .sm
    var expandedShadow: ShadowSize = .lg
    var customShadowColor: Color? = nil
    var customShadowRadius: CGFloat? = nil
    var customShadowOffset: CGSize? = nil
    
    // MARK: - Animation
    var animationDuration: CGFloat = 0.25
    var animationDamping: CGFloat = 0.85
    var pressScale: CGFloat = 0.95
    var iconRotation: Angle = .zero  // Rotation when menu is open
    var enablePressAnimation: Bool = true
    
    // MARK: - Backdrop
    var backdropOpacity: Double = 0.3
    var backdropBlur: CGFloat = 0  // 0 = no blur
    var backdropColor: Color = .black
    var dismissOnBackdropTap: Bool = true
    
    // MARK: - Menu Layout
    var menuAlignment: PFABMenuAlignment = .bottom
    var horizontalPadding: CGFloat = 16
    var bottomPadding: CGFloat = 8
    var topPadding: CGFloat = 8
    var menuMaxWidth: CGFloat? = nil  // nil = full width minus padding
    var menuMaxHeight: CGFloat? = nil
    
    // MARK: - Interaction
    var hapticStyle: PFABHapticStyle = .medium
    var closeOnMenuItemTap: Bool = false
}

// MARK: - PMorphingFAB

/// An expandable Floating Action Button that transforms from a circular button
/// into a menu and optionally into full-screen content.
///
/// Inspired by Family.co's elegant FAB animation pattern.
///
/// Basic usage:
/// ```swift
/// PExpandableFAB(isExpanded: $isExpanded) {
///     Image(systemName: "plus")
/// } menu: {
///     MenuContent()
/// } detail: {
///     DetailView()
/// }
/// ```
///
/// With customizations:
/// ```swift
/// PExpandableFAB(isExpanded: $isExpanded) {
///     Image(systemName: "plus")
/// } menu: {
///     MenuContent()
/// } detail: {
///     DetailView()
/// }
/// .appearance(.dark)
/// .fabShape(.roundedSquare(cornerRadius: 16))
/// .iconRotation(.degrees(45))
/// .backdropBlur(10)
/// .border(.blue, width: 2)
/// ```
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable, message: "PExpandableFAB is not available on macOS")
public struct PExpandableFAB<Label: View, MenuContent: View, ExpandedContent: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Bindings
    
    @Binding var isExpanded: Bool
    
    // MARK: - View Builders
    
    @ViewBuilder var label: Label
    @ViewBuilder var menu: MenuContent
    @ViewBuilder var detail: ExpandedContent
    
    // MARK: - Configuration
    
    private var config: PExpandableFABConfiguration
    
    // MARK: - Internal State
    
    @State private var showFullScreenCover: Bool = false
    @State private var animateContent: Bool = false
    @State private var viewPosition: CGRect = .zero
    @State private var isPressed: Bool = false
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var tintColor: Color {
        if let custom = config.customTint {
            return custom
        }
        
        switch config.appearance {
        case .light:
            return colors.background
        case .dark:
            return colors.foreground
        case .system:
            return colorScheme == .dark ? colors.foreground : colors.background
        case .custom:
            return colors.primary
        }
    }
    
    private var expandedTintColor: Color {
        config.expandedTint ?? tintColor
    }
    
    private var iconColor: Color {
        if let custom = config.customIconColor {
            return custom
        }
        
        switch config.appearance {
        case .light:
            return colors.foreground
        case .dark:
            return colors.background
        case .system:
            return colorScheme == .dark ? colors.background : colors.foreground
        case .custom:
            return colors.primaryForeground
        }
    }
    
    private var morphAnimation: Animation? {
        reduceMotion ? nil : .spring(response: config.animationDuration, dampingFraction: config.animationDamping)
    }
    
    private var pressAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.15, dampingFraction: 0.7)
    }
    
    private var shadowStyle: ShadowStyle {
        if let radius = config.customShadowRadius,
           let offset = config.customShadowOffset {
            return ShadowStyle(
                color: config.customShadowColor ?? Color.black.opacity(0.1),
                radius: radius,
                x: offset.width,
                y: offset.height
            )
        }
        return theme.shadows[config.shadow]
    }
    
    private var expandedShadowStyle: ShadowStyle {
        theme.shadows[config.expandedShadow]
    }
    
    private var currentIconRotation: Angle {
        animateContent ? config.iconRotation : .zero
    }
    
    
    // MARK: - Initializer
    
    /// Create an expandable FAB with label, menu, and detail content
    /// - Parameters:
    ///   - isExpanded: Binding to control the expanded detail state
    ///   - label: The FAB icon (typically an SF Symbol)
    ///   - menu: The menu content shown when FAB is tapped
    ///   - detail: The full-screen detail view shown when expanded
    public init(
        isExpanded: Binding<Bool>,
        @ViewBuilder label: () -> Label,
        @ViewBuilder menu: () -> MenuContent,
        @ViewBuilder detail: () -> ExpandedContent
    ) {
        self._isExpanded = isExpanded
        self.label = label()
        self.menu = menu()
        self.detail = detail()
        self.config = PExpandableFABConfiguration()
    }
    
    // Private init for modifiers
    private init(
        isExpanded: Binding<Bool>,
        label: Label,
        menu: MenuContent,
        detail: ExpandedContent,
        config: PExpandableFABConfiguration
    ) {
        self._isExpanded = isExpanded
        self.label = label
        self.menu = menu
        self.detail = detail
        self.config = config
    }
    
    // MARK: - Body
    
    public var body: some View {
        label
            .foregroundColor(iconColor)
            .rotationEffect(currentIconRotation)
            .frame(width: config.size, height: config.size)
            .background(tintColor)
            .modifier(FABShapeModifier(shape: config.shape, borderColor: config.borderColor, borderWidth: config.borderWidth))
            .prettyShadow(shadowStyle)
            .scaleEffect(isPressed && config.enablePressAnimation ? config.pressScale : 1.0)
            .animation(pressAnimation, value: isPressed)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            viewPosition = geometry.frame(in: .global)
                        }
                        .onChange(of: geometry.frame(in: .global)) { newValue in
                            viewPosition = newValue
                        }
                }
            )
            .opacity(showFullScreenCover ? 0 : 1)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        triggerHaptic()
                        toggleFullScreenCover(withAnimation: false, status: true)
                    }
            )
            .fullScreenCover(isPresented: $showFullScreenCover) {
                fullScreenContent
            }
    }
    
    // MARK: - Full Screen Content
    
    @ViewBuilder
    private var fullScreenContent: some View {
        ZStack(alignment: .topLeading) {
            if animateContent {
                ZStack(alignment: .top) {
                    if isExpanded {
                        detail
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        menuContainer
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .transition(.opacity)
            } else {
                label
                    .foregroundColor(iconColor)
                    .rotationEffect(currentIconRotation)
                    .frame(width: config.size, height: config.size)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: config.menuMaxWidth)
        .frame(maxHeight: config.menuMaxHeight)
        .clipShape(RoundedRectangle(cornerRadius: config.expandedCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: config.expandedCornerRadius, style: .continuous)
                .stroke(
                    (config.expandedBorderColor ?? config.borderColor) ?? .clear,
                    lineWidth: config.expandedBorderWidth > 0 ? config.expandedBorderWidth : config.borderWidth
                )
        )
        .background {
            RoundedRectangle(cornerRadius: config.expandedCornerRadius, style: .continuous)
                .fill(expandedTintColor)
                .prettyShadow(animateContent ? expandedShadowStyle : shadowStyle)
                .ignoresSafeArea(isExpanded ? .all : [])
        }
        .padding(.horizontal, animateContent && !isExpanded ? config.horizontalPadding : 0)
        .padding(.bottom, animateContent && !isExpanded ? config.bottomPadding : 0)
        .padding(.top, animateContent && !isExpanded ? config.topPadding : 0)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: menuFrameAlignment
        )
        .offset(
            x: animateContent ? 0 : viewPosition.minX,
            y: animateContent ? 0 : viewPosition.minY
        )
        .ignoresSafeArea(animateContent ? [] : .all)
        .background {
            backdropView
        }
        .task {
            try? await Task.sleep(nanoseconds: 60_000_000) // 0.06 seconds
            withAnimation(morphAnimation) {
                animateContent = true
            }
        }
        .animation(morphAnimation, value: isExpanded)
        .background(ClearBackgroundView())
    }
    
    private var menuFrameAlignment: Alignment {
        guard animateContent else { return .topLeading }
        
        switch config.menuAlignment {
        case .bottom:
            return .bottom
        case .center:
            return .center
        case .top:
            return .top
        }
    }
    
    @ViewBuilder
    private var menuContainer: some View {
        if config.menuMaxHeight != nil {
            ScrollView {
                menu
            }
        } else {
            menu
        }
    }
    
    @ViewBuilder
    private var backdropView: some View {
        ZStack {
            // Color backdrop
            Rectangle()
                .fill(config.backdropColor.opacity(animateContent ? config.backdropOpacity : 0))
            
            // Optional blur
            if config.backdropBlur > 0 && animateContent {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(animateContent ? 1 : 0)
            }
        }
        .ignoresSafeArea()
        .contentShape(Rectangle())
        .onTapGesture {
            if config.dismissOnBackdropTap {
                dismissWithAnimation()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func toggleFullScreenCover(withAnimation animated: Bool, status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = !animated
        
        withTransaction(transaction) {
            showFullScreenCover = status
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(morphAnimation) {
            animateContent = false
        }
        // Delay the dismiss to allow animation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + config.animationDuration + 0.1) {
            toggleFullScreenCover(withAnimation: false, status: false)
        }
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        guard config.hapticStyle != .none else { return }
        
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        switch config.hapticStyle {
        case .none:
            return
        case .light:
            style = .light
        case .medium:
            style = .medium
        case .heavy:
            style = .heavy
        case .soft:
            style = .soft
        case .rigid:
            style = .rigid
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.impactOccurred()
        #endif
    }
}

// MARK: - Shape Modifier Helper

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
private struct FABShapeModifier: ViewModifier {
    let shape: PFABShape
    let borderColor: Color?
    let borderWidth: CGFloat
    
    func body(content: Content) -> some View {
        switch shape {
        case .circle:
            content
                .clipShape(Circle())
                .overlay(Circle().stroke(borderColor ?? .clear, lineWidth: borderWidth))
                .contentShape(Circle())
        case .roundedSquare(let radius):
            content
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(borderColor ?? .clear, lineWidth: borderWidth))
                .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        case .capsule:
            content
                .clipShape(Capsule())
                .overlay(Capsule().stroke(borderColor ?? .clear, lineWidth: borderWidth))
                .contentShape(Capsule())
        }
    }
}

// MARK: - Clear Background Helper

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
private struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
public extension PExpandableFAB {
    
    // MARK: - Size & Shape
    
    /// Set the FAB size (width and height)
    func size(_ size: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.size = size
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the FAB shape
    func fabShape(_ shape: PFABShape) -> PExpandableFAB {
        var newConfig = config
        newConfig.shape = shape
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the corner radius when expanded
    func expandedCornerRadius(_ radius: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.expandedCornerRadius = radius
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Appearance
    
    /// Set the appearance mode (light, dark, system, or custom)
    func appearance(_ appearance: PFABAppearance) -> PExpandableFAB {
        var newConfig = config
        newConfig.appearance = appearance
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the FAB tint (background) color
    func tint(_ color: Color) -> PExpandableFAB {
        var newConfig = config
        newConfig.customTint = color
        newConfig.appearance = .custom
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set a different tint color when expanded
    func expandedTint(_ color: Color) -> PExpandableFAB {
        var newConfig = config
        newConfig.expandedTint = color
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the icon color
    func iconColor(_ color: Color) -> PExpandableFAB {
        var newConfig = config
        newConfig.customIconColor = color
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Border
    
    /// Add a border to the FAB
    func border(_ color: Color, width: CGFloat = 1) -> PExpandableFAB {
        var newConfig = config
        newConfig.borderColor = color
        newConfig.borderWidth = width
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set a different border when expanded
    func expandedBorder(_ color: Color, width: CGFloat = 1) -> PExpandableFAB {
        var newConfig = config
        newConfig.expandedBorderColor = color
        newConfig.expandedBorderWidth = width
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Shadow
    
    /// Set the shadow style at rest
    func shadow(_ shadow: ShadowSize) -> PExpandableFAB {
        var newConfig = config
        newConfig.shadow = shadow
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the shadow style when expanded
    func expandedShadow(_ shadow: ShadowSize) -> PExpandableFAB {
        var newConfig = config
        newConfig.expandedShadow = shadow
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set a custom shadow
    func customShadow(color: Color = Color.black.opacity(0.1), radius: CGFloat, x: CGFloat = 0, y: CGFloat = 4) -> PExpandableFAB {
        var newConfig = config
        newConfig.customShadowColor = color
        newConfig.customShadowRadius = radius
        newConfig.customShadowOffset = CGSize(width: x, height: y)
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Animation
    
    /// Set the animation duration and damping
    func animation(duration: CGFloat, damping: CGFloat = 0.85) -> PExpandableFAB {
        var newConfig = config
        newConfig.animationDuration = duration
        newConfig.animationDamping = damping
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the press scale effect (1.0 = no scale, 0.9 = 10% smaller)
    func pressScale(_ scale: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.pressScale = scale
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Enable or disable press animation
    func pressAnimation(_ enabled: Bool) -> PExpandableFAB {
        var newConfig = config
        newConfig.enablePressAnimation = enabled
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set icon rotation when menu is open (e.g., .degrees(45) for plus → X)
    func iconRotation(_ angle: Angle) -> PExpandableFAB {
        var newConfig = config
        newConfig.iconRotation = angle
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Backdrop
    
    /// Set the backdrop opacity (0.0 - 1.0)
    func backdropOpacity(_ opacity: Double) -> PExpandableFAB {
        var newConfig = config
        newConfig.backdropOpacity = opacity
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the backdrop blur radius
    func backdropBlur(_ radius: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.backdropBlur = radius
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the backdrop color
    func backdropColor(_ color: Color) -> PExpandableFAB {
        var newConfig = config
        newConfig.backdropColor = color
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Enable or disable dismiss on backdrop tap
    func dismissOnBackdropTap(_ enabled: Bool) -> PExpandableFAB {
        var newConfig = config
        newConfig.dismissOnBackdropTap = enabled
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Menu Layout
    
    /// Set the menu alignment when expanded
    func menuAlignment(_ alignment: PFABMenuAlignment) -> PExpandableFAB {
        var newConfig = config
        newConfig.menuAlignment = alignment
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set horizontal padding for the expanded menu
    func menuHorizontalPadding(_ padding: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.horizontalPadding = padding
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set vertical padding for the expanded menu
    func menuVerticalPadding(top: CGFloat = 8, bottom: CGFloat = 8) -> PExpandableFAB {
        var newConfig = config
        newConfig.topPadding = top
        newConfig.bottomPadding = bottom
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set maximum width for the expanded menu
    func menuMaxWidth(_ width: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.menuMaxWidth = width
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set maximum height for the expanded menu (enables scrolling)
    func menuMaxHeight(_ height: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.menuMaxHeight = height
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    // MARK: - Interaction
    
    /// Set the haptic feedback style
    func haptics(_ style: PFABHapticStyle) -> PExpandableFAB {
        var newConfig = config
        newConfig.hapticStyle = style
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Enable or disable auto-close when menu item is tapped
    func closeOnMenuItemTap(_ enabled: Bool) -> PExpandableFAB {
        var newConfig = config
        newConfig.closeOnMenuItemTap = enabled
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
}

// MARK: - FAB Menu Item

/// A pre-styled menu item for use inside PExpandableFAB menus
///
/// Usage:
/// ```swift
/// PExpandableFAB(isExpanded: $isExpanded) {
///     Image(systemName: "plus")
/// } menu: {
///     VStack(spacing: 4) {
///         PFABMenuItem(icon: "paperplane", title: "Send", description: "Transfer to wallet") {
///             // action
///         }
///         PFABMenuItem(icon: "arrow.down", title: "Receive") {
///             // action
///         }
///     }
/// } detail: {
///     DetailView()
/// }
/// ```
@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable, message: "PFABMenuItem is not available on macOS")
public struct PFABMenuItem: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    
    private let icon: String
    private let title: String
    private let description: String?
    private let action: () -> Void
    
    // MARK: - Configuration
    
    private var showChevron: Bool = true
    private var iconSize: CGFloat = 44
    private var iconFont: Font = .title2
    private var titleFont: Font = .body
    private var descriptionFont: Font = .caption
    private var customIconColor: Color? = nil
    private var customIconBackground: Color? = nil
    private var customTitleColor: Color? = nil
    private var customDescriptionColor: Color? = nil
    private var horizontalPadding: CGFloat = 16
    private var verticalPadding: CGFloat = 10
    private var spacing: CGFloat = 14
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Create a FAB menu item
    /// - Parameters:
    ///   - icon: SF Symbol name for the icon
    ///   - title: Main title text
    ///   - description: Optional description text
    ///   - showChevron: Whether to show a chevron indicator (default: true)
    ///   - action: Action to perform when tapped
    public init(
        icon: String,
        title: String,
        description: String? = nil,
        showChevron: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.showChevron = showChevron
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: spacing) {
                Image(systemName: icon)
                    .font(iconFont)
                    .frame(width: iconSize, height: iconSize)
                    .background(customIconBackground ?? colors.background)
                    .clipShape(Circle())
                    .foregroundColor(customIconColor ?? colors.foreground)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(titleFont)
                        .foregroundColor(customTitleColor ?? colors.background)
                        .fontWeight(.semibold)
                    
                    if let description {
                        Text(description)
                            .font(descriptionFont)
                            .foregroundColor(customDescriptionColor ?? colors.mutedForeground)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(colors.mutedForeground)
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PFABMenuItem Modifiers

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
public extension PFABMenuItem {
    
    /// Show or hide the chevron indicator
    func chevron(_ show: Bool) -> PFABMenuItem {
        var copy = self
        copy.showChevron = show
        return copy
    }
    
    /// Set the icon size
    func iconSize(_ size: CGFloat) -> PFABMenuItem {
        var copy = self
        copy.iconSize = size
        return copy
    }
    
    /// Set the icon font
    func iconFont(_ font: Font) -> PFABMenuItem {
        var copy = self
        copy.iconFont = font
        return copy
    }
    
    /// Set custom icon colors
    func iconStyle(color: Color? = nil, background: Color? = nil) -> PFABMenuItem {
        var copy = self
        copy.customIconColor = color
        copy.customIconBackground = background
        return copy
    }
    
    /// Set the title font
    func titleFont(_ font: Font) -> PFABMenuItem {
        var copy = self
        copy.titleFont = font
        return copy
    }
    
    /// Set custom title color
    func titleColor(_ color: Color) -> PFABMenuItem {
        var copy = self
        copy.customTitleColor = color
        return copy
    }
    
    /// Set the description font
    func descriptionFont(_ font: Font) -> PFABMenuItem {
        var copy = self
        copy.descriptionFont = font
        return copy
    }
    
    /// Set custom description color
    func descriptionColor(_ color: Color) -> PFABMenuItem {
        var copy = self
        copy.customDescriptionColor = color
        return copy
    }
    
    /// Set padding
    func padding(horizontal: CGFloat = 16, vertical: CGFloat = 10) -> PFABMenuItem {
        var copy = self
        copy.horizontalPadding = horizontal
        copy.verticalPadding = vertical
        return copy
    }
    
    /// Set spacing between icon and text
    func itemSpacing(_ spacing: CGFloat) -> PFABMenuItem {
        var copy = self
        copy.spacing = spacing
        return copy
    }
}

// MARK: - Convenience Initializer (No Detail View)

@available(iOS 16.0, tvOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
public extension PExpandableFAB where ExpandedContent == EmptyView {
    
    /// Create an expandable FAB with just a label and menu (no detail view)
    /// - Parameters:
    ///   - label: The FAB icon (typically an SF Symbol)
    ///   - menu: The menu content shown when FAB is tapped
    init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder menu: () -> MenuContent
    ) {
        self._isExpanded = .constant(false)
        self.label = label()
        self.menu = menu()
        self.detail = EmptyView()
        self.config = PExpandableFABConfiguration()
    }
}


// MARK: - Preview

#if DEBUG && os(iOS)
@available(iOS 16.0, *)
struct PExpandableFAB_Previews: PreviewProvider {
    static var previews: some View {
        PExpandableFABPreviewContainer()
            .prettyTheme(.sky)
            .previewDisplayName("Light Mode - Sky Theme")
        
        PExpandableFABPreviewContainer()
            .prettyTheme(.sky)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode - Sky Theme")
    }
}

@available(iOS 16.0, *)
private struct PExpandableFABPreviewContainer: View {
    @State private var isExpanded = false
    @State private var selectedItem = "Send"
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.prettyTheme) var theme
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("With Detail View") {
                    Text(
                        """
                        **PExpandableFAB(isExpanded: $state) {**
                           Image(systemName: "plus")
                        **} menu: {**
                           MenuContent()
                        **} detail: {**
                           DetailView()
                        **}**
                        """
                    )
                    .monospaced()
                    .font(.caption)
                    .lineSpacing(5)
                }
                
                Section("Customization Examples") {
                    Text(
                        """
                        **.appearance(.dark)**
                        **.fabShape(.roundedSquare(cornerRadius: 16))**
                        **.iconRotation(.degrees(45))**
                        **.backdropBlur(10)**
                        **.border(.blue, width: 2)**
                        **.pressScale(0.9)**
                        **.haptics(.heavy)**
                        """
                    )
                    .monospaced()
                    .font(.caption)
                    .lineSpacing(5)
                }
            }
            .navigationTitle("Expandable FAB")
        }
        .overlay(alignment: .bottomTrailing) {
            PExpandableFAB(isExpanded: $isExpanded) {
                Image(systemName: "plus")
                    .font(.title3)
                    .fontWeight(.semibold)
            } menu: {
                VStack(alignment: .leading, spacing: 4) {
                    PFABMenuItem(icon: "paperplane", title: "Send", description: "Transfer crypto to another wallet") {
                        selectedItem = "Send"
                        isExpanded = true
                    }
                    PFABMenuItem(icon: "arrow.trianglehead.2.counterclockwise", title: "Swap", description: "Exchange between different tokens") {
                        selectedItem = "Swap"
                        isExpanded = true
                    }
                    PFABMenuItem(icon: "arrow.down", title: "Receive", description: "Get your wallet address to receive") {
                        selectedItem = "Receive"
                        isExpanded = true
                    }
                    PFABMenuItem(icon: "qrcode", title: "Scan", description: "Scan a QR code to send or connect") {
                        selectedItem = "Scan"
                        isExpanded = true
                    }
                }
                .padding(.vertical, 16)
            } detail: {
                VStack(spacing: 0) {
                    HStack {
                        Text(selectedItem)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Spacer(minLength: 0)
                        
                        Button {
                            isExpanded = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(colors.mutedForeground)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        Image(systemName: selectedItem == "Send" ? "paperplane.circle.fill" :
                                selectedItem == "Swap" ? "arrow.trianglehead.2.counterclockwise.circle.fill" :
                                selectedItem == "Receive" ? "arrow.down.circle.fill" : "qrcode.viewfinder")
                            .font(.system(size: 64))
                            .foregroundColor(colors.primary)
                            .padding(.top, 40)
                        
                        Text("This is the \(selectedItem) view")
                            .font(.headline)
                        
                        Text("Here you would see the full interface for the \(selectedItem.lowercased()) action.")
                            .font(.subheadline)
                            .foregroundColor(colors.mutedForeground)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer()
                        
                        Button {
                            isExpanded = false
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(colors.primaryForeground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .foregroundColor(colors.background)
            }
            .appearance(.light)
            .iconRotation(.degrees(45))
            .backdropOpacity(0.4)
            .padding(15)
        }
    }
}
#endif
