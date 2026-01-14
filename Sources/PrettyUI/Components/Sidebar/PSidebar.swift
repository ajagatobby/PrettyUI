//
//  PSidebar.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired animated sidebar menu component with fluid spring animations,
//  gesture-based dismissal, and flexible content structure.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Sidebar Position

/// Position options for PSidebar
public enum PSidebarPosition: String, Equatable, Sendable, CaseIterable {
    /// Sidebar slides in from the leading edge (left on LTR)
    case leading
    /// Sidebar slides in from the trailing edge (right on LTR)
    case trailing
}

// MARK: - Sidebar Style

/// Visual style options for PSidebar
public enum PSidebarStyle: String, Equatable, Sendable, CaseIterable {
    /// Full height edge-to-edge sidebar (classic style)
    case fullHeight
    /// Floating card with rounded corners and margin
    case floating
}

// MARK: - Sidebar Overlay Style

/// Overlay/backdrop style options for PSidebar
public enum PSidebarOverlayStyle: Equatable, Sendable {
    /// Dimmed black overlay with configurable opacity (default)
    case dimmed
    /// Blurred overlay with configurable blur radius
    case blurred(radius: CGFloat = 10)
    /// Dimmed overlay combined with blur effect
    case dimmedBlur(opacity: Double = 0.3, radius: CGFloat = 10)
    /// No overlay (transparent)
    case none
}

// MARK: - Sidebar Item Variant

/// Visual variants for sidebar items
public enum PSidebarItemVariant: String, Equatable, Sendable, CaseIterable {
    /// Standard navigation item
    case standard
    /// Destructive action item (red accent)
    case destructive
    /// Selected/active item
    case selected
}

// MARK: - Sidebar Dismiss Environment Key

/// Wrapper class to hold the dismiss action
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
final class PSidebarDismissAction: @unchecked Sendable {
    let dismiss: () -> Void
    
    init(_ dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
}

/// Environment key for sidebar dismiss action
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct PSidebarDismissKey: EnvironmentKey {
    static let defaultValue: PSidebarDismissAction? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var pSidebarDismiss: PSidebarDismissAction? {
        get { self[PSidebarDismissKey.self] }
        set { self[PSidebarDismissKey.self] = newValue }
    }
}

// MARK: - Sidebar Animation Index Environment Key

/// Environment key for staggered animation index
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct PSidebarAnimationIndexKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var pSidebarAnimationIndex: Int {
        get { self[PSidebarAnimationIndexKey.self] }
        set { self[PSidebarAnimationIndexKey.self] = newValue }
    }
}

// MARK: - Sidebar Configuration

/// Configuration for PSidebar styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarConfiguration {
    /// Position of the sidebar (leading or trailing)
    public var position: PSidebarPosition = .leading
    /// Visual style of the sidebar
    public var style: PSidebarStyle = .fullHeight
    /// Overlay/backdrop style
    public var overlayStyle: PSidebarOverlayStyle = .dimmed
    /// Width of the sidebar panel
    public var width: CGFloat = 300
    /// Corner radius for floating style
    public var radius: RadiusSize = .xxl
    /// Content padding
    public var contentPadding: SpacingSize = .lg
    /// Margin for floating style
    public var floatingMargin: CGFloat = 16
    /// Whether tapping the backdrop dismisses the sidebar
    public var dismissOnBackgroundTap: Bool = true
    /// Backdrop opacity
    public var backdropOpacity: Double = 0.5
    /// Whether to enable drag-to-dismiss gesture
    public var enableDragToDismiss: Bool = true
    
    public init() {}
}

// MARK: - PSidebar View Modifier

/// A view modifier that presents a sidebar menu
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarModifier<SidebarContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var config: PSidebarConfiguration
    @ViewBuilder var sidebarContent: () -> SidebarContent
    
    // Internal state to control actual visibility
    @State private var isShowingOverlay = false
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                if isShowingOverlay {
                    PSidebarOverlay(
                        isPresented: $isPresented,
                        isShowing: $isShowingOverlay,
                        config: config,
                        content: sidebarContent
                    )
                    .ignoresSafeArea()
                }
            }
            .onChange(of: isPresented) { newValue in
                if newValue {
                    isShowingOverlay = true
                    triggerHaptic()
                }
            }
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Sidebar Overlay

/// The overlay that contains the backdrop and sidebar panel
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct PSidebarOverlay<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @Binding var isShowing: Bool
    var config: PSidebarConfiguration
    @ViewBuilder var content: Content
    
    // MARK: - State
    
    @State private var isVisible = false
    @State private var isDismissing = false
    @State private var dragOffset: CGFloat = 0
    @State private var contentAppeared = false
    
    // MARK: - Constants
    
    private let dismissThreshold: CGFloat = 100
    private let dragResistance: CGFloat = 0.3
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Entry animation - subtle ease out
    private var entryAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.2)
            : .easeOut(duration: 0.28)
    }
    
    /// Exit animation - smooth ease out (decelerates at end)
    private var exitAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.18)
            : .easeOut(duration: 0.22)
    }
    
    /// Animation for drag release snap-back
    private var snapBackAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .easeOut(duration: 0.2)
    }
    
    private var backdropAnimation: Animation {
        .easeOut(duration: 0.2)
    }
    
    /// Current animation based on state
    private var currentAnimation: Animation {
        isDismissing ? exitAnimation : entryAnimation
    }
    
    /// Effective position considering layout direction
    private var effectivePosition: PSidebarPosition {
        if layoutDirection == .rightToLeft {
            return config.position == .leading ? .trailing : .leading
        }
        return config.position
    }
    
    /// ZStack alignment based on position
    private var alignment: Alignment {
        effectivePosition == .leading ? .leading : .trailing
    }
    
    /// Off-screen offset value based on position
    private var offScreenOffset: CGFloat {
        let baseOffset = config.width + (config.style == .floating ? config.floatingMargin * 2 : 0) + 50
        return effectivePosition == .leading ? -baseOffset : baseOffset
    }
    
    /// Total offset including drag and visibility state
    private var totalOffset: CGFloat {
        let baseOffset = isVisible ? 0 : offScreenOffset
        return baseOffset + dragOffset
    }
    
    /// Drag progress for adjusting overlay effects
    private var dragProgress: Double {
        let dismissDirection: CGFloat = effectivePosition == .leading ? -1.0 : 1.0
        let progress = (dragOffset * dismissDirection) / dismissThreshold
        return min(max(progress, 0), 1)
    }
    
    /// Backdrop opacity adjusted for drag progress
    private var adjustedBackdropOpacity: Double {
        guard isVisible else { return 0 }
        
        let baseOpacity: Double
        switch config.overlayStyle {
        case .dimmed:
            baseOpacity = config.backdropOpacity
        case .dimmedBlur(let opacity, _):
            baseOpacity = opacity
        case .blurred, .none:
            baseOpacity = 0
        }
        
        return baseOpacity * (1 - dragProgress * 0.5)
    }
    
    /// Blur radius adjusted for drag progress
    private var adjustedBlurRadius: CGFloat {
        guard isVisible else { return 0 }
        
        let baseRadius: CGFloat
        switch config.overlayStyle {
        case .blurred(let radius):
            baseRadius = radius
        case .dimmedBlur(_, let radius):
            baseRadius = radius
        case .dimmed, .none:
            baseRadius = 0
        }
        
        return baseRadius * (1 - dragProgress * 0.5)
    }
    
    /// Resolved corner radius
    private var resolvedRadius: CGFloat {
        config.style == .floating ? theme.radius[config.radius] : 0
    }
    
    /// Edge insets for floating style
    private var floatingInsets: EdgeInsets {
        guard config.style == .floating else {
            return EdgeInsets()
        }
        
        let margin = config.floatingMargin
        return EdgeInsets(
            top: margin,
            leading: effectivePosition == .leading ? margin : 0,
            bottom: margin,
            trailing: effectivePosition == .trailing ? margin : 0
        )
    }
    
    /// Drag gesture for dismissing the sidebar
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard config.enableDragToDismiss else { return }
                
                let translation = value.translation.width
                
                // Determine if dragging in dismiss direction
                let isDismissDirection: Bool
                switch effectivePosition {
                case .leading:
                    isDismissDirection = translation < 0 // Dragging left
                case .trailing:
                    isDismissDirection = translation > 0 // Dragging right
                }
                
                if isDismissDirection {
                    dragOffset = translation
                } else {
                    dragOffset = translation * dragResistance
                }
            }
            .onEnded { value in
                guard config.enableDragToDismiss else { return }
                
                let translation = value.translation.width
                let velocity = value.predictedEndTranslation.width
                
                // Check if should dismiss based on position
                let shouldDismiss: Bool
                switch effectivePosition {
                case .leading:
                    shouldDismiss = translation < -dismissThreshold || velocity < -500
                case .trailing:
                    shouldDismiss = translation > dismissThreshold || velocity > 500
                }
                
                if shouldDismiss {
                    dismiss()
                } else {
                    withAnimation(snapBackAnimation) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: alignment) {
                // Backdrop/Overlay
                overlayView
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onTapGesture {
                        if config.dismissOnBackgroundTap {
                            dismiss()
                        }
                    }
                
                // Sidebar Panel
                sidebarPanel
                    .environment(\.pSidebarDismiss, PSidebarDismissAction(dismiss))
                    .padding(floatingInsets)
                    .offset(x: totalOffset)
                    .gesture(dragGesture)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            // Animate in with spring
            withAnimation(entryAnimation) {
                isVisible = true
            }
            // Trigger content stagger animation after panel appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                contentAppeared = true
            }
        }
        .onChange(of: isPresented) { newValue in
            if !newValue && isVisible && !isDismissing {
                dismiss()
            }
        }
    }
    
    // MARK: - Overlay View
    
    @ViewBuilder
    private var overlayView: some View {
        switch config.overlayStyle {
        case .none:
            Color.clear
                .contentShape(Rectangle())
            
        case .dimmed:
            Color.black
                .opacity(adjustedBackdropOpacity)
                .animation(backdropAnimation, value: isVisible)
            
        case .blurred(let radius):
            Rectangle()
                .fill(.ultraThinMaterial)
                .blur(radius: max(0, adjustedBlurRadius - radius))
                .opacity(isVisible ? 1 : 0)
                .animation(backdropAnimation, value: isVisible)
            
        case .dimmedBlur:
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(isVisible ? 1 : 0)
                Color.black
                    .opacity(adjustedBackdropOpacity)
            }
            .animation(backdropAnimation, value: isVisible)
        }
    }
    
    // MARK: - Sidebar Panel
    
    @ViewBuilder
    private var sidebarPanel: some View {
        content
            .frame(width: config.width)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(colors.card)
            .clipShape(sidebarShape)
            .shadow(
                color: Color.black.opacity(config.style == .floating ? 0.15 : 0.08),
                radius: config.style == .floating ? 32 : 16,
                x: effectivePosition == .leading ? 8 : -8,
                y: 0
            )
    }
    
    /// Shape for the sidebar based on style and position
    private var sidebarShape: some Shape {
        if config.style == .floating {
            return AnyShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
        } else {
            // Full height: use standard rectangle (no rounded corners needed for edge-to-edge)
            return AnyShape(Rectangle())
        }
    }
    
    // MARK: - Actions
    
    private func dismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        contentAppeared = false
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
        
        withAnimation(exitAnimation) {
            isVisible = false
            dragOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            isShowing = false
            isPresented = false
        }
    }
}

// MARK: - Type-Erased Shape Helper

/// Type-erased shape for conditional shape usage
struct AnyShape: Shape, @unchecked Sendable {
    private let pathBuilder: @Sendable (CGRect) -> Path
    
    init<S: Shape>(_ shape: S) {
        // Capture the shape and create a sendable closure
        let captured = shape
        pathBuilder = { rect in
            captured.path(in: rect)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        pathBuilder(rect)
    }
}

// MARK: - PSidebar Content Builder

/// A pre-styled container for sidebar content with header, sections, and footer
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarContent<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(theme.spacing.lg)
    }
}

// MARK: - PSidebar Header

/// Header component for sidebar with avatar, title, and subtitle
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarHeader: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let title: String
    private var subtitle: String?
    private var avatarImage: Image?
    private var avatarSystemName: String?
    private var onTap: (() -> Void)?
    
    public init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    private init(
        title: String,
        subtitle: String?,
        avatarImage: Image?,
        avatarSystemName: String?,
        onTap: (() -> Void)?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.avatarImage = avatarImage
        self.avatarSystemName = avatarSystemName
        self.onTap = onTap
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: theme.spacing.md) {
                // Avatar
                avatarView
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: theme.typography.sizes.lg, weight: .semibold))
                        .foregroundColor(colors.foreground)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: theme.typography.sizes.sm))
                            .foregroundColor(colors.mutedForeground)
                    }
                }
                
                Spacer(minLength: 0)
                
                // Chevron if tappable
                if onTap != nil {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                }
            }
            .padding(.vertical, theme.spacing.md)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
    
    @ViewBuilder
    private var avatarView: some View {
        Group {
            if let image = avatarImage {
                image
                    .resizable()
                    .scaledToFill()
            } else if let systemName = avatarSystemName {
                Image(systemName: systemName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(colors.primary)
            } else {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(colors.mutedForeground)
            }
        }
        .frame(width: 48, height: 48)
        .background(colors.muted)
        .clipShape(Circle())
    }
    
    // MARK: - Fluent Modifiers
    
    /// Set an avatar image
    public func avatar(_ image: Image) -> PSidebarHeader {
        PSidebarHeader(
            title: title,
            subtitle: subtitle,
            avatarImage: image,
            avatarSystemName: nil,
            onTap: onTap
        )
    }
    
    /// Set an avatar using SF Symbol
    public func avatarSystemImage(_ systemName: String) -> PSidebarHeader {
        PSidebarHeader(
            title: title,
            subtitle: subtitle,
            avatarImage: nil,
            avatarSystemName: systemName,
            onTap: onTap
        )
    }
    
    /// Set tap action
    public func onTap(_ action: @escaping () -> Void) -> PSidebarHeader {
        PSidebarHeader(
            title: title,
            subtitle: subtitle,
            avatarImage: avatarImage,
            avatarSystemName: avatarSystemName,
            onTap: action
        )
    }
}

// MARK: - PSidebar Section

/// A section container for grouping sidebar items with optional title
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarSection<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let title: String?
    private let content: Content
    
    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let title = title {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(colors.mutedForeground)
                    .tracking(0.5)
                    .padding(.leading, theme.spacing.sm)
                    .padding(.top, theme.spacing.lg)
                    .padding(.bottom, theme.spacing.xs)
            }
            
            content
        }
    }
}

// MARK: - PSidebar Item

/// A navigation item in the sidebar menu
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarItem: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.pSidebarDismiss) private var sidebarDismiss
    
    private let title: String
    private var icon: String?
    private var variant: PSidebarItemVariant = .standard
    private var badge: String?
    private var dismissOnTap: Bool = false
    private var action: (() -> Void)?
    private var animationIndex: Int = 0
    
    @State private var isPressed = false
    
    public init(_ title: String, icon: String? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    private init(
        title: String,
        icon: String?,
        variant: PSidebarItemVariant,
        badge: String?,
        dismissOnTap: Bool,
        action: (() -> Void)?,
        animationIndex: Int
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.badge = badge
        self.dismissOnTap = dismissOnTap
        self.action = action
        self.animationIndex = animationIndex
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .standard:
            return colors.foreground
        case .destructive:
            return colors.destructive
        case .selected:
            return colors.primary
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .selected:
            return colors.primary.opacity(0.1)
        default:
            return isPressed ? colors.muted : Color.clear
        }
    }
    
    public var body: some View {
        Button {
            action?()
            if dismissOnTap {
                sidebarDismiss?.dismiss()
            }
        } label: {
            HStack(spacing: theme.spacing.md) {
                // Icon
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(foregroundColor)
                        .frame(width: 24)
                }
                
                // Title
                Text(title)
                    .font(.system(size: theme.typography.sizes.base, weight: variant == .selected ? .semibold : .regular))
                    .foregroundColor(foregroundColor)
                
                Spacer(minLength: 0)
                
                // Badge
                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.primaryForeground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(colors.primary)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.md)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    // MARK: - Fluent Modifiers
    
    /// Set the item variant
    public func variant(_ variant: PSidebarItemVariant) -> PSidebarItem {
        PSidebarItem(
            title: title,
            icon: icon,
            variant: variant,
            badge: badge,
            dismissOnTap: dismissOnTap,
            action: action,
            animationIndex: animationIndex
        )
    }
    
    /// Add a badge
    public func badge(_ text: String) -> PSidebarItem {
        PSidebarItem(
            title: title,
            icon: icon,
            variant: variant,
            badge: text,
            dismissOnTap: dismissOnTap,
            action: action,
            animationIndex: animationIndex
        )
    }
    
    /// Dismiss sidebar when tapped
    public func dismissOnTap(_ dismiss: Bool = true) -> PSidebarItem {
        PSidebarItem(
            title: title,
            icon: icon,
            variant: variant,
            badge: badge,
            dismissOnTap: dismiss,
            action: action,
            animationIndex: animationIndex
        )
    }
    
    /// Set animation index for staggered animation
    public func animationIndex(_ index: Int) -> PSidebarItem {
        PSidebarItem(
            title: title,
            icon: icon,
            variant: variant,
            badge: badge,
            dismissOnTap: dismissOnTap,
            action: action,
            animationIndex: index
        )
    }
}

// MARK: - PSidebar Footer

/// Footer section for sidebar with bottom-aligned content
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarFooter<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        Spacer()
        
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()
                .background(colors.border)
                .padding(.bottom, theme.spacing.sm)
            
            content
        }
    }
}

// MARK: - PSidebar Divider

/// A styled divider for sidebar sections
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSidebarDivider: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    public init() {}
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        Rectangle()
            .fill(colors.border)
            .frame(height: 1)
            .padding(.vertical, theme.spacing.sm)
    }
}

// MARK: - View Extension for pSidebar

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Present an animated sidebar menu
    ///
    /// ```swift
    /// .pSidebar(isPresented: $showMenu) {
    ///     PSidebarContent {
    ///         PSidebarHeader("John Doe", subtitle: "@johndoe")
    ///             .avatar(Image("avatar"))
    ///
    ///         PSidebarSection("Navigation") {
    ///             PSidebarItem("Home", icon: "house")
    ///                 .animationIndex(0)
    ///             PSidebarItem("Wallet", icon: "wallet.fill")
    ///                 .animationIndex(1)
    ///             PSidebarItem("Settings", icon: "gear")
    ///                 .animationIndex(2)
    ///         }
    ///
    ///         PSidebarFooter {
    ///             PSidebarItem("Sign Out", icon: "arrow.right.square")
    ///                 .variant(.destructive)
    ///         }
    ///     }
    /// }
    ///
    /// // With custom configuration
    /// .pSidebar(isPresented: $showMenu, position: .trailing, style: .floating) {
    ///     // Custom content
    /// }
    /// ```
    func pSidebar<Content: View>(
        isPresented: Binding<Bool>,
        position: PSidebarPosition = .leading,
        style: PSidebarStyle = .fullHeight,
        overlay: PSidebarOverlayStyle = .dimmed,
        width: CGFloat = 300,
        dismissOnBackgroundTap: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var config = PSidebarConfiguration()
        config.position = position
        config.style = style
        config.overlayStyle = overlay
        config.width = width
        config.dismissOnBackgroundTap = dismissOnBackgroundTap
        return modifier(
            PSidebarModifier(
                isPresented: isPresented,
                config: config,
                sidebarContent: content
            )
        )
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PSidebar_Previews: PreviewProvider {
    static var previews: some View {
        PSidebarPreviewContainer()
            .prettyTheme(.sky)
            .previewDisplayName("Sidebar Demo")
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct PSidebarPreviewContainer: View {
    @State private var showLeadingSidebar = false
    @State private var showTrailingSidebar = false
    @State private var showFloatingSidebar = false
    @State private var selectedItem = "Home"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("PSidebar Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Button("Show Leading Sidebar") {
                showLeadingSidebar = true
            }
            .buttonStyle(.borderedProminent)
            
            Button("Show Trailing Sidebar") {
                showTrailingSidebar = true
            }
            .buttonStyle(.bordered)
            
            Button("Show Floating Sidebar") {
                showFloatingSidebar = true
            }
            .buttonStyle(.bordered)
            
            Text("Selected: \(selectedItem)")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#F8F9FA"))
        // Leading sidebar
        .pSidebar(isPresented: $showLeadingSidebar, position: .leading, style: .fullHeight) {
            PSidebarContent {
                PSidebarHeader("John Doe", subtitle: "@johndoe")
                    .avatarSystemImage("person.circle.fill")
                    .onTap { print("Header tapped") }
                
                PSidebarSection("Navigation") {
                    PSidebarItem("Home", icon: "house.fill") {
                        selectedItem = "Home"
                    }
                    .variant(selectedItem == "Home" ? .selected : .standard)
                    .animationIndex(0)
                    .dismissOnTap()
                    
                    PSidebarItem("Wallet", icon: "wallet.fill") {
                        selectedItem = "Wallet"
                    }
                    .variant(selectedItem == "Wallet" ? .selected : .standard)
                    .badge("3")
                    .animationIndex(1)
                    .dismissOnTap()
                    
                    PSidebarItem("Activity", icon: "chart.line.uptrend.xyaxis") {
                        selectedItem = "Activity"
                    }
                    .variant(selectedItem == "Activity" ? .selected : .standard)
                    .animationIndex(2)
                    .dismissOnTap()
                    
                    PSidebarItem("Settings", icon: "gear") {
                        selectedItem = "Settings"
                    }
                    .variant(selectedItem == "Settings" ? .selected : .standard)
                    .animationIndex(3)
                    .dismissOnTap()
                }
                
                PSidebarFooter {
                    PSidebarItem("Sign Out", icon: "arrow.right.square") {
                        print("Sign out tapped")
                    }
                    .variant(.destructive)
                    .dismissOnTap()
                }
            }
        }
        // Trailing sidebar
        .pSidebar(isPresented: $showTrailingSidebar, position: .trailing, style: .fullHeight) {
            PSidebarContent {
                PSidebarHeader("Notifications")
                    .avatarSystemImage("bell.fill")
                
                PSidebarSection {
                    PSidebarItem("All Notifications", icon: "bell") { }
                        .animationIndex(0)
                    PSidebarItem("Mentions", icon: "at") { }
                        .badge("5")
                        .animationIndex(1)
                    PSidebarItem("Transactions", icon: "arrow.left.arrow.right") { }
                        .animationIndex(2)
                }
            }
        }
        // Floating sidebar
        .pSidebar(isPresented: $showFloatingSidebar, position: .leading, style: .floating, overlay: .dimmedBlur()) {
            PSidebarContent {
                PSidebarHeader("Quick Actions")
                    .avatarSystemImage("bolt.fill")
                
                PSidebarSection {
                    PSidebarItem("Send", icon: "arrow.up.circle.fill") { }
                        .animationIndex(0)
                        .dismissOnTap()
                    PSidebarItem("Receive", icon: "arrow.down.circle.fill") { }
                        .animationIndex(1)
                        .dismissOnTap()
                    PSidebarItem("Swap", icon: "arrow.triangle.2.circlepath") { }
                        .animationIndex(2)
                        .dismissOnTap()
                }
                
                PSidebarDivider()
                
                PSidebarSection("Recent") {
                    PSidebarItem("0x1234...5678", icon: "person.crop.circle") { }
                        .animationIndex(3)
                    PSidebarItem("0xabcd...efgh", icon: "person.crop.circle") { }
                        .animationIndex(4)
                }
            }
        }
    }
}
#endif

