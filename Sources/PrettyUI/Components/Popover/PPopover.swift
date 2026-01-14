//
//  PPopover.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired popover component with fluid spring animations.
//  Displays interactive content anchored to a trigger element with
//  automatic positioning and arrow indicator.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Popover Position

/// Position options for PPopover relative to anchor
public enum PPopoverPosition: String, Equatable, Sendable, CaseIterable {
    /// Popover appears above the anchor, arrow points down
    case top
    /// Popover appears below the anchor, arrow points up
    case bottom
    /// Popover appears to the left of the anchor, arrow points right
    case leading
    /// Popover appears to the right of the anchor, arrow points left
    case trailing
}

// MARK: - Popover Arrow Alignment

/// Alignment for the popover arrow along its axis
public enum PPopoverArrowAlignment: Equatable, Sendable {
    /// Arrow centered (default)
    case center
    /// Arrow aligned to start (leading for top/bottom, top for leading/trailing)
    case start
    /// Arrow aligned to end (trailing for top/bottom, bottom for leading/trailing)
    case end
    /// Arrow at a specific offset from center
    case offset(CGFloat)
}

// MARK: - Popover Style

/// Visual style options for PPopover
public enum PPopoverStyle: Equatable, Sendable {
    /// Light card background (default)
    case light
    /// Dark inverted background
    case dark
    /// Custom colors
    case custom(background: PopoverColor, foreground: PopoverColor)
    
    /// Sendable color wrapper for popover customization
    public struct PopoverColor: Equatable, Sendable {
        public let red: Double
        public let green: Double
        public let blue: Double
        public let opacity: Double
        
        /// Create from RGB values (0-1 range)
        public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
            self.red = red
            self.green = green
            self.blue = blue
            self.opacity = opacity
        }
        
        /// Create from hex string (e.g., "#FF5733" or "FF5733")
        public init(hex: String) {
            var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
            
            var rgb: UInt64 = 0
            Scanner(string: hexSanitized).scanHexInt64(&rgb)
            
            self.red = Double((rgb & 0xFF0000) >> 16) / 255.0
            self.green = Double((rgb & 0x00FF00) >> 8) / 255.0
            self.blue = Double(rgb & 0x0000FF) / 255.0
            self.opacity = 1.0
        }
        
        /// Convert to SwiftUI Color
        public var color: Color {
            Color(red: red, green: green, blue: blue).opacity(opacity)
        }
        
        // MARK: - Preset Colors
        
        public static let black = PopoverColor(red: 0, green: 0, blue: 0)
        public static let white = PopoverColor(red: 1, green: 1, blue: 1)
        public static let clear = PopoverColor(red: 0, green: 0, blue: 0, opacity: 0)
    }
}

// MARK: - Popover Configuration

/// Configuration for PPopover styling and behavior
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopoverConfiguration: Equatable, Sendable {
    /// Position of the popover relative to anchor
    public var position: PPopoverPosition = .bottom
    /// Arrow alignment along the popover edge
    public var arrowAlignment: PPopoverArrowAlignment = .center
    /// Corner radius for the popover
    public var radius: RadiusSize = .xl
    /// Arrow size (width and height)
    public var arrowSize: CGFloat = 8
    /// Whether to show the arrow
    public var showArrow: Bool = true
    /// Content padding
    public var padding: SpacingSize = .md
    /// Maximum width (nil for auto)
    public var maxWidth: CGFloat? = nil
    /// Maximum height (nil for auto)
    public var maxHeight: CGFloat? = nil
    /// Distance from anchor
    public var offset: CGFloat = 6
    /// Whether tapping outside dismisses the popover
    public var dismissOnOutsideTap: Bool = true
    /// Backdrop opacity (0.0-1.0) - very subtle by default
    public var backdropOpacity: Double = 0.01
    /// Popover style (colors)
    public var style: PPopoverStyle = .light
    /// Shadow size
    public var shadow: ShadowSize = .md
    
    public init() {}
    
    public static func == (lhs: PPopoverConfiguration, rhs: PPopoverConfiguration) -> Bool {
        lhs.position == rhs.position &&
        lhs.radius == rhs.radius &&
        lhs.arrowSize == rhs.arrowSize &&
        lhs.showArrow == rhs.showArrow &&
        lhs.padding == rhs.padding &&
        lhs.maxWidth == rhs.maxWidth &&
        lhs.maxHeight == rhs.maxHeight &&
        lhs.offset == rhs.offset &&
        lhs.dismissOnOutsideTap == rhs.dismissOnOutsideTap &&
        lhs.backdropOpacity == rhs.backdropOpacity &&
        lhs.style == rhs.style &&
        lhs.shadow == rhs.shadow
    }
}

// MARK: - Popover Arrow Shape

/// Custom shape for the popover arrow
struct PopoverArrowShape: Shape {
    let position: PPopoverPosition
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch position {
        case .top:
            // Arrow points down (popover is above anchor)
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
            
        case .bottom:
            // Arrow points up (popover is below anchor)
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            
        case .leading:
            // Arrow points right (popover is to the left of anchor)
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            
        case .trailing:
            // Arrow points left (popover is to the right of anchor)
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
        
        return path
    }
}

// MARK: - Popover Dismiss Environment Key

/// Wrapper class to hold the dismiss action
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
final class PPopoverDismissAction: @unchecked Sendable {
    let dismiss: () -> Void
    
    init(_ dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
}

/// Environment key for popover dismiss action
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct PPopoverDismissKey: EnvironmentKey {
    static let defaultValue: PPopoverDismissAction? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var pPopoverDismiss: PPopoverDismissAction? {
        get { self[PPopoverDismissKey.self] }
        set { self[PPopoverDismissKey.self] = newValue }
    }
}

// MARK: - Popover Content Holder

/// Observable object for managing popover state at the root level
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
final class PPopoverContentHolder: ObservableObject {
    // Use nonisolated(unsafe) for the shared singleton to avoid concurrency issues
    nonisolated(unsafe) static let shared = PPopoverContentHolder()
    
    @Published var currentContent: AnyView? = nil
    @Published var currentConfig: PPopoverConfiguration? = nil
    @Published var currentAnchorFrame: CGRect = .zero
    @Published var isPresented: Bool = false
    
    private var dismissAction: (() -> Void)? = nil
    
    private init() {}
    
    /// Present a popover with content
    @MainActor
    func present<Content: View>(
        content: Content,
        config: PPopoverConfiguration,
        anchorFrame: CGRect,
        dismiss: @escaping () -> Void
    ) {
        self.currentContent = AnyView(content)
        self.currentConfig = config
        self.currentAnchorFrame = anchorFrame
        self.dismissAction = dismiss
        self.isPresented = true
    }
    
    /// Update anchor frame (for scrolling/resizing)
    @MainActor
    func updateAnchorFrame(_ frame: CGRect) {
        if isPresented {
            self.currentAnchorFrame = frame
        }
    }
    
    /// Dismiss the current popover
    @MainActor
    func dismiss() {
        let action = dismissAction
        dismissAction = nil
        isPresented = false
        currentContent = nil
        currentConfig = nil
        action?()
    }
    
    /// Clear all state
    @MainActor
    func clear() {
        isPresented = false
        currentContent = nil
        currentConfig = nil
        currentAnchorFrame = .zero
        dismissAction = nil
    }
}

// MARK: - Root Popover Container

/// A view modifier that renders popovers at the root level of the view hierarchy.
/// This ensures popovers appear above all other UI elements.
///
/// Apply this modifier at the root of your app:
/// ```swift
/// ContentView()
///     .prettyTheme(.sky)
///     .pPopoverRoot()
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopoverRootModifier: ViewModifier {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - State
    
    @ObservedObject private var popoverHolder = PPopoverContentHolder.shared
    @State private var isAnimating = false
    @State private var isDismissing = false
    @State private var popoverSize: CGSize = .zero
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Entry animation - spring with slight bounce (Family style)
    private var entryAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.12)
            : .spring(response: 0.28, dampingFraction: 0.82, blendDuration: 0)
    }
    
    /// Exit animation - fast ease in
    private var exitAnimation: Animation {
        reduceMotion
            ? .easeIn(duration: 0.08)
            : .easeIn(duration: 0.15)
    }
    
    /// Backdrop animation
    private var backdropAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.08)
            : .easeOut(duration: 0.18)
    }
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                if popoverHolder.isPresented {
                    GeometryReader { geo in
                        popoverOverlay
                            .frame(width: screenSize.width, height: screenSize.height)
                            .position(
                                x: screenSize.width / 2 - geo.frame(in: .global).minX,
                                y: screenSize.height / 2 - geo.frame(in: .global).minY
                            )
                    }
                }
            }
            .onChange(of: popoverHolder.isPresented) { newValue in
                if newValue {
                    isDismissing = false
                    withAnimation(entryAnimation) {
                        isAnimating = true
                    }
                } else {
                    performDismissAnimation()
                }
            }
    }
    
    private var screenSize: CGSize {
        #if os(iOS) || os(tvOS)
        return UIScreen.main.bounds.size
        #elseif os(macOS)
        return NSApplication.shared.keyWindow?.contentView?.bounds.size ?? NSScreen.main?.visibleFrame.size ?? .zero
        #else
        return .zero
        #endif
    }
    
    // MARK: - Popover Overlay
    
    @ViewBuilder
    private var popoverOverlay: some View {
        GeometryReader { geo in
            ZStack {
                // Backdrop
                Color.black
                    .opacity(isAnimating ? (popoverHolder.currentConfig?.backdropOpacity ?? 0.01) : 0)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if popoverHolder.currentConfig?.dismissOnOutsideTap == true {
                            dismissPopover()
                        }
                    }
                    .animation(backdropAnimation, value: isAnimating)
                
                // Popover content positioned at anchor
                if let content = popoverHolder.currentContent,
                   let config = popoverHolder.currentConfig {
                    popoverView(content: content, config: config)
                        .background(
                            GeometryReader { popoverGeo in
                                Color.clear
                                    .onAppear { popoverSize = popoverGeo.size }
                                    .onChange(of: popoverGeo.size) { popoverSize = $0 }
                            }
                        )
                        .position(calculatePosition(anchorFrame: popoverHolder.currentAnchorFrame, config: config, in: geo))
                        .offset(entryOffset(for: config))
                        .scaleEffect(isAnimating ? 1.0 : 0.92)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(isDismissing ? exitAnimation : entryAnimation, value: isAnimating)
                        .environment(\.pPopoverDismiss, PPopoverDismissAction(dismissPopover))
                }
            }
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Popover View Builder
    
    @ViewBuilder
    private func popoverView(content: AnyView, config: PPopoverConfiguration) -> some View {
        let resolvedRadius = theme.radius[config.radius]
        let resolvedPadding = theme.spacing[config.padding]
        let resolvedShadow = theme.shadows[config.shadow]
        
        let backgroundColor: Color = {
            switch config.style {
            case .dark:
                return colors.foreground
            case .light:
                return colors.card
            case .custom(let background, _):
                return background.color
            }
        }()
        
        let foregroundColor: Color = {
            switch config.style {
            case .dark:
                return colors.background
            case .light:
                return colors.foreground
            case .custom(_, let foreground):
                return foreground.color
            }
        }()
        
        let popoverContent = Group {
            if config.showArrow {
                switch config.position {
                case .top:
                    VStack(spacing: 0) {
                        contentBody(content: content, config: config, backgroundColor: backgroundColor, foregroundColor: foregroundColor, resolvedRadius: resolvedRadius, resolvedPadding: resolvedPadding)
                        arrowView(for: config, backgroundColor: backgroundColor)
                    }
                case .bottom:
                    VStack(spacing: 0) {
                        arrowView(for: config, backgroundColor: backgroundColor)
                        contentBody(content: content, config: config, backgroundColor: backgroundColor, foregroundColor: foregroundColor, resolvedRadius: resolvedRadius, resolvedPadding: resolvedPadding)
                    }
                case .leading:
                    HStack(spacing: 0) {
                        contentBody(content: content, config: config, backgroundColor: backgroundColor, foregroundColor: foregroundColor, resolvedRadius: resolvedRadius, resolvedPadding: resolvedPadding)
                        arrowView(for: config, backgroundColor: backgroundColor)
                    }
                case .trailing:
                    HStack(spacing: 0) {
                        arrowView(for: config, backgroundColor: backgroundColor)
                        contentBody(content: content, config: config, backgroundColor: backgroundColor, foregroundColor: foregroundColor, resolvedRadius: resolvedRadius, resolvedPadding: resolvedPadding)
                    }
                }
            } else {
                contentBody(content: content, config: config, backgroundColor: backgroundColor, foregroundColor: foregroundColor, resolvedRadius: resolvedRadius, resolvedPadding: resolvedPadding)
            }
        }
        .fixedSize()
        .shadow(
            color: resolvedShadow.color,
            radius: resolvedShadow.radius,
            x: resolvedShadow.x,
            y: resolvedShadow.y
        )
        
        popoverContent
    }
    
    @ViewBuilder
    private func contentBody(
        content: AnyView,
        config: PPopoverConfiguration,
        backgroundColor: Color,
        foregroundColor: Color,
        resolvedRadius: CGFloat,
        resolvedPadding: CGFloat
    ) -> some View {
        ZStack {
            // Solid opaque background
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .fill(Color(red: 1, green: 1, blue: 1))
            
            // Theme background on top
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .fill(backgroundColor)
            
            // Content
            content
                .foregroundColor(foregroundColor)
                .padding(resolvedPadding / 2)
                .frame(maxWidth: config.maxWidth, maxHeight: config.maxHeight)
        }
        .fixedSize()
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
    }
    
    @ViewBuilder
    private func arrowView(for config: PPopoverConfiguration, backgroundColor: Color) -> some View {
        PopoverArrowShape(position: config.position)
            .fill(backgroundColor)
            .frame(
                width: config.position == .top || config.position == .bottom ? config.arrowSize * 2 : config.arrowSize,
                height: config.position == .top || config.position == .bottom ? config.arrowSize : config.arrowSize * 2
            )
    }
    
    // MARK: - Position Calculation
    
    private func calculatePosition(anchorFrame: CGRect, config: PPopoverConfiguration, in geo: GeometryProxy) -> CGPoint {
        let anchor = anchorFrame
        let gap = config.offset
        
        // Calculate anchor center in screen coordinates
        let anchorCenterX = anchor.midX
        let anchorCenterY = anchor.midY
        
        var x: CGFloat = anchorCenterX
        var y: CGFloat = anchorCenterY
        
        switch config.position {
        case .top:
            y = anchor.minY - popoverSize.height / 2 - gap
        case .bottom:
            y = anchor.maxY + popoverSize.height / 2 + gap
        case .leading:
            x = anchor.minX - popoverSize.width / 2 - gap
        case .trailing:
            x = anchor.maxX + popoverSize.width / 2 + gap
        }
        
        // Clamp to screen bounds with padding
        let padding: CGFloat = 8
        let halfWidth = popoverSize.width / 2
        let halfHeight = popoverSize.height / 2
        
        x = max(padding + halfWidth, min(x, geo.size.width - padding - halfWidth))
        y = max(padding + halfHeight, min(y, geo.size.height - padding - halfHeight))
        
        return CGPoint(x: x, y: y)
    }
    
    /// Entry offset direction for animation
    private func entryOffset(for config: PPopoverConfiguration) -> CGSize {
        guard !isAnimating else { return .zero }
        let distance: CGFloat = 8
        
        switch config.position {
        case .top: return CGSize(width: 0, height: distance)
        case .bottom: return CGSize(width: 0, height: -distance)
        case .leading: return CGSize(width: distance, height: 0)
        case .trailing: return CGSize(width: -distance, height: 0)
        }
    }
    
    // MARK: - Dismiss
    
    private func dismissPopover() {
        guard !isDismissing else { return }
        performDismissAnimation()
        popoverHolder.dismiss()
    }
    
    private func performDismissAnimation() {
        isDismissing = true
        withAnimation(exitAnimation) {
            isAnimating = false
        }
    }
}

// MARK: - PPopover View

/// A standalone popover view with arrow pointer
///
/// Usage:
/// ```swift
/// // Standalone popover
/// PPopover(position: .bottom) {
///     Text("Popover content")
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopover<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    private var config: PPopoverConfiguration
    private let content: Content
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var popoverConfig: PopoverConfig {
        theme.components.popover
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
    private var resolvedPadding: CGFloat {
        theme.spacing[config.padding]
    }
    
    private var resolvedShadow: ShadowStyle {
        theme.shadows[config.shadow]
    }
    
    /// Background color based on style
    private var backgroundColor: Color {
        switch config.style {
        case .dark:
            return colors.foreground
        case .light:
            return colors.card
        case .custom(let background, _):
            return background.color
        }
    }
    
    /// Foreground/text color based on style
    private var foregroundColor: Color {
        switch config.style {
        case .dark:
            return colors.background
        case .light:
            return colors.foreground
        case .custom(_, let foreground):
            return foreground.color
        }
    }
    
    // MARK: - Initializers
    
    /// Create a popover with custom content
    public init(
        position: PPopoverPosition = .bottom,
        @ViewBuilder content: () -> Content
    ) {
        var config = PPopoverConfiguration()
        config.position = position
        self.config = config
        self.content = content()
    }
    
    // Private init for modifiers
    private init(config: PPopoverConfiguration, content: Content) {
        self.config = config
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        popoverBody
            .shadow(
                color: resolvedShadow.color,
                radius: resolvedShadow.radius,
                x: resolvedShadow.x,
                y: resolvedShadow.y
            )
    }
    
    @ViewBuilder
    private var popoverBody: some View {
        if config.showArrow {
            switch config.position {
            case .top:
                VStack(spacing: 0) {
                    contentView
                    arrowView
                }
            case .bottom:
                VStack(spacing: 0) {
                    arrowView
                    contentView
                }
            case .leading:
                HStack(spacing: 0) {
                    contentView
                    arrowView
                }
            case .trailing:
                HStack(spacing: 0) {
                    arrowView
                    contentView
                }
            }
        } else {
            contentView
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        ZStack {
            // Solid opaque background - use explicit white to ensure no transparency
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .fill(Color(red: 1, green: 1, blue: 1))
            
            // Theme background on top
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .fill(backgroundColor)
            
            // Content on top
            content
                .foregroundColor(foregroundColor)
                .padding(resolvedPadding)
                .frame(maxWidth: config.maxWidth, maxHeight: config.maxHeight)
        }
        .fixedSize()
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
    }
    
    @ViewBuilder
    private var arrowView: some View {
        PopoverArrowShape(position: config.position)
            .fill(backgroundColor)
            .frame(
                width: config.position == .top || config.position == .bottom ? config.arrowSize * 2 : config.arrowSize,
                height: config.position == .top || config.position == .bottom ? config.arrowSize : config.arrowSize * 2
            )
    }
}

// MARK: - Fluent Modifiers for PPopover

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PPopover {
    
    /// Set the popover position
    func position(_ position: PPopoverPosition) -> PPopover {
        var newConfig = config
        newConfig.position = position
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the corner radius
    func radius(_ radius: RadiusSize) -> PPopover {
        var newConfig = config
        newConfig.radius = radius
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the arrow size
    func arrowSize(_ size: CGFloat) -> PPopover {
        var newConfig = config
        newConfig.arrowSize = size
        return PPopover(config: newConfig, content: content)
    }
    
    /// Show or hide the arrow
    func showArrow(_ show: Bool) -> PPopover {
        var newConfig = config
        newConfig.showArrow = show
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the content padding
    func padding(_ padding: SpacingSize) -> PPopover {
        var newConfig = config
        newConfig.padding = padding
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the maximum width
    func maxWidth(_ width: CGFloat?) -> PPopover {
        var newConfig = config
        newConfig.maxWidth = width
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the maximum height
    func maxHeight(_ height: CGFloat?) -> PPopover {
        var newConfig = config
        newConfig.maxHeight = height
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the offset from anchor
    func offset(_ offset: CGFloat) -> PPopover {
        var newConfig = config
        newConfig.offset = offset
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the popover style
    func style(_ style: PPopoverStyle) -> PPopover {
        var newConfig = config
        newConfig.style = style
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set dark style
    func dark() -> PPopover {
        var newConfig = config
        newConfig.style = .dark
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set light style (default)
    func light() -> PPopover {
        var newConfig = config
        newConfig.style = .light
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set custom background and foreground colors
    func colors(background: PPopoverStyle.PopoverColor, foreground: PPopoverStyle.PopoverColor) -> PPopover {
        var newConfig = config
        newConfig.style = .custom(background: background, foreground: foreground)
        return PPopover(config: newConfig, content: content)
    }
    
    /// Set the shadow size
    func shadow(_ shadow: ShadowSize) -> PPopover {
        var newConfig = config
        newConfig.shadow = shadow
        return PPopover(config: newConfig, content: content)
    }
}

// MARK: - PPopover View Modifier

/// A view modifier that presents a popover attached to the modified view.
/// Uses a shared observable object to render the popover at the root level,
/// ensuring it appears above all other UI elements.
///
/// Note: For this to work, `.pPopoverRoot()` must be applied at the root of your app.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopoverModifier<PopoverContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var config: PPopoverConfiguration
    @ViewBuilder var popoverContent: () -> PopoverContent
    
    // MARK: - State
    
    @State private var anchorFrame: CGRect = .zero
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            anchorFrame = geo.frame(in: .global)
                        }
                        .onChange(of: geo.frame(in: .global)) { newFrame in
                            anchorFrame = newFrame
                            // Update anchor frame in holder if this popover is showing
                            if isPresented {
                                PPopoverContentHolder.shared.updateAnchorFrame(newFrame)
                            }
                        }
                }
            )
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Present the popover
                    PPopoverContentHolder.shared.present(
                        content: popoverContent(),
                        config: config,
                        anchorFrame: anchorFrame,
                        dismiss: {
                            isPresented = false
                        }
                    )
                } else {
                    // Dismiss if this popover triggered the dismiss
                    if PPopoverContentHolder.shared.isPresented {
                        PPopoverContentHolder.shared.dismiss()
                    }
                }
            }
    }
}

// MARK: - View Extension for pPopover

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Present a popover with custom content
    ///
    /// ```swift
    /// Button("Show Popover") { showPopover = true }
    ///     .pPopover(isPresented: $showPopover) {
    ///         VStack(spacing: 12) {
    ///             Text("Popover Title")
    ///                 .font(.headline)
    ///             Text("Some content here")
    ///         }
    ///     }
    /// ```
    func pPopover<Content: View>(
        isPresented: Binding<Bool>,
        position: PPopoverPosition = .bottom,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var config = PPopoverConfiguration()
        config.position = position
        return modifier(
            PPopoverModifier(
                isPresented: isPresented,
                config: config,
                popoverContent: content
            )
        )
    }
    
    /// Present a popover with custom backdrop opacity
    ///
    /// ```swift
    /// Button("Show Menu") { showMenu = true }
    ///     .pPopover(isPresented: $showMenu, position: .bottom, backdropOpacity: 0.2) {
    ///         PPopoverMenu { ... }
    ///     }
    /// ```
    func pPopover<Content: View>(
        isPresented: Binding<Bool>,
        position: PPopoverPosition = .bottom,
        backdropOpacity: Double,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var config = PPopoverConfiguration()
        config.position = position
        config.backdropOpacity = backdropOpacity
        return modifier(
            PPopoverModifier(
                isPresented: isPresented,
                config: config,
                popoverContent: content
            )
        )
    }
    
    /// Present a popover with full configuration
    ///
    /// ```swift
    /// var config = PPopoverConfiguration()
    /// config.position = .top
    /// config.style = .dark
    /// config.showArrow = true
    ///
    /// view.pPopover(isPresented: $show, config: config) {
    ///     CustomContent()
    /// }
    /// ```
    func pPopover<Content: View>(
        isPresented: Binding<Bool>,
        config: PPopoverConfiguration,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            PPopoverModifier(
                isPresented: isPresented,
                config: config,
                popoverContent: content
            )
        )
    }
    
    /// Apply at the root of your app to enable popover rendering above all content.
    ///
    /// This modifier sets up the root-level overlay system that ensures popovers
    /// appear above all other UI elements, regardless of their position in the view hierarchy.
    ///
    /// ```swift
    /// @main
    /// struct MyApp: App {
    ///     var body: some Scene {
    ///         WindowGroup {
    ///             ContentView()
    ///                 .prettyTheme(.sky)
    ///                 .pPopoverRoot()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Note: This modifier must be applied at or near the root of your view hierarchy
    ///   for popovers to work correctly. Popovers triggered by `.pPopover()` will be
    ///   rendered in the overlay layer provided by this modifier.
    func pPopoverRoot() -> some View {
        modifier(PPopoverRootModifier())
    }
}

// MARK: - Popover Menu Components

/// A vertical menu list for use inside popovers
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopoverMenu<Content: View>: View {
    
    @Environment(\.prettyTheme) private var theme
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
    }
}

/// A single menu item for use inside PPopoverMenu
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopoverMenuItem: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.pPopoverDismiss) private var popoverDismiss
    
    // MARK: - Properties
    
    private let title: String
    private let icon: String?
    private let isDestructive: Bool
    private let action: () -> Void
    
    // MARK: - State
    
    @State private var isPressed = false
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    // MARK: - Initializers
    
    /// Create a menu item
    /// - Parameters:
    ///   - title: The menu item title
    ///   - icon: Optional SF Symbol name
    ///   - destructive: Whether this is a destructive action (shows in red)
    ///   - action: The action to perform when tapped
    public init(
        _ title: String,
        icon: String? = nil,
        destructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = destructive
        self.action = action
    }
    
    public var body: some View {
        Button {
            action()
            popoverDismiss?.dismiss()
        } label: {
            HStack(spacing: theme.spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 20)
                }
                
                Text(title)
                    .font(.system(size: theme.typography.sizes.base, weight: .medium))
                
                Spacer(minLength: theme.spacing.lg)
            }
            .foregroundColor(isDestructive ? colors.destructive : colors.foreground)
            .padding(.horizontal, theme.spacing.md)
            .padding(.vertical, theme.spacing.sm + 2)
            .background(isPressed ? colors.muted : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

/// A divider for use inside PPopoverMenu
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PPopoverMenuDivider: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public init() {}
    
    public var body: some View {
        Rectangle()
            .fill(colors.border)
            .frame(height: 1)
            .padding(.vertical, theme.spacing.xs)
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PPopover_Previews: PreviewProvider {
    static var previews: some View {
        PPopoverPreviewContainer()
            .prettyTheme(.sky)
            .pPopoverRoot()  // Required at root for popovers to render above all content
            .previewDisplayName("Popover Demo")
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct PPopoverPreviewContainer: View {
    @State private var showBasicPopover = false
    @State private var showMenuPopover = false
    @State private var showTopPopover = false
    @State private var showLeadingPopover = false
    @State private var showTrailingPopover = false
    @State private var showDarkPopover = false
    @State private var showNoArrowPopover = false
    @State private var showBackdropPopover = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 48) {
                    // Static Popovers Showcase
                    Group {
                        sectionHeader("Static Popovers")
                        
                        VStack(spacing: 24) {
                            // Light style
                            PPopover(position: .bottom) {
                                Text("Light popover content")
                                    .font(.subheadline)
                            }
                            
                            // Dark style
                            PPopover(position: .top) {
                                Text("Dark popover")
                                    .font(.subheadline)
                            }
                            .dark()
                            
                            // No arrow
                            PPopover(position: .bottom) {
                                Text("No arrow")
                                    .font(.subheadline)
                            }
                            .showArrow(false)
                        }
                    }
                    
                    Divider()
                    
                    // Interactive Popovers
                    Group {
                        sectionHeader("Interactive Popovers")
                        sectionSubheader("Tap the buttons to show popovers")
                        
                        VStack(spacing: 24) {
                            // Basic popover
                            Button("Show Basic Popover") {
                                showBasicPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showBasicPopover, position: .bottom) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Popover Title")
                                        .font(.headline)
                                    Text("This is some popover content that can be interactive.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(5)
                                .frame(width: 130)
                            }
                            
                            // Menu popover
                            PButton("Show Menu") {
                                showMenuPopover.toggle()
                            }
                            .background(.pink)
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showMenuPopover, position: .bottom, backdropOpacity: 0.15) {
                                PPopoverMenu {
                                    PPopoverMenuItem("Edit", icon: "pencil") {
                                        print("Edit tapped")
                                    }
                                    PPopoverMenuItem("Duplicate", icon: "doc.on.doc") {
                                        print("Duplicate tapped")
                                    }
                                    PPopoverMenuItem("Share", icon: "square.and.arrow.up") {
                                        print("Share tapped")
                                    }
                                    PPopoverMenuDivider()
                                    PPopoverMenuItem("Delete", icon: "trash", destructive: true) {
                                        print("Delete tapped")
                                    }
                                }
                                .frame(width: 180)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // All Positions
                    Group {
                        sectionHeader("All Positions")
                        
                        HStack(spacing: 32) {
                            Button("Top") {
                                showTopPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showTopPopover, position: .top) {
                                Text("Top Position")
                                    .font(.subheadline)
                            }
                            
                            Button("Bottom") {
                                showBasicPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showBasicPopover, position: .bottom) {
                                Text("Bottom Position")
                                    .font(.subheadline)
                            }
                        }
                        
                        HStack(spacing: 32) {
                            Button("Leading") {
                                showLeadingPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showLeadingPopover, position: .leading) {
                                Text("Leading")
                                    .font(.subheadline)
                            }
                            
                            Button("Trailing") {
                                showTrailingPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showTrailingPopover, position: .trailing) {
                                Text("Trailing")
                                    .font(.subheadline)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Styles
                    Group {
                        sectionHeader("Popover Styles")
                        
                        HStack(spacing: 24) {
                            Button("Light") {
                                showBasicPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showBasicPopover, position: .bottom) {
                                Text("Light Style")
                            }
                            
                            Button("Dark") {
                                showDarkPopover.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pPopover(isPresented: $showDarkPopover, position: .bottom) {
                                Text("Dark Style")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("PPopover")
        }
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func sectionSubheader(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
#endif

