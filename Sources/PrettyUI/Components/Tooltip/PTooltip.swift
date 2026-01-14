//
//  PTooltip.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired tooltip component with fluid spring animations.
//  Displays contextual information with an arrow pointing to the anchor element.
//

import SwiftUI

// MARK: - Tooltip Position

/// Position options for PTooltip arrow
public enum PTooltipPosition: String, Equatable, Sendable, CaseIterable {
    /// Tooltip appears above the anchor, arrow points down
    case top
    /// Tooltip appears below the anchor, arrow points up
    case bottom
    /// Tooltip appears to the left of the anchor, arrow points right
    case leading
    /// Tooltip appears to the right of the anchor, arrow points left
    case trailing
}

// MARK: - Tooltip Arrow Alignment

/// Alignment for the tooltip arrow along its axis
public enum PTooltipArrowAlignment: Equatable, Sendable {
    /// Arrow centered (default)
    case center
    /// Arrow aligned to start (leading for top/bottom, top for leading/trailing)
    case start
    /// Arrow aligned to end (trailing for top/bottom, bottom for leading/trailing)
    case end
    /// Arrow at a specific offset from center
    case offset(CGFloat)
}

// MARK: - Tooltip Style

/// Predefined tooltip styles
public enum PTooltipStyle: Equatable, Sendable {
    /// Default dark tooltip (dark background, light text)
    case dark
    /// Light tooltip (light background, dark text)
    case light
    /// Custom colors
    case custom(background: TooltipColor, text: TooltipColor)
    
    /// Sendable color wrapper for tooltip customization
    public struct TooltipColor: Equatable, Sendable {
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
        
        /// Create from UIColor/NSColor style 0-255 values
        public init(r: Int, g: Int, b: Int, a: Double = 1) {
            self.red = Double(r) / 255.0
            self.green = Double(g) / 255.0
            self.blue = Double(b) / 255.0
            self.opacity = a
        }
        
        /// Convert to SwiftUI Color
        public var color: Color {
            Color(red: red, green: green, blue: blue).opacity(opacity)
        }
        
        // MARK: - Preset Colors
        
        public static let black = TooltipColor(red: 0, green: 0, blue: 0)
        public static let white = TooltipColor(red: 1, green: 1, blue: 1)
        public static let clear = TooltipColor(red: 0, green: 0, blue: 0, opacity: 0)
        
        // Primary colors
        public static let red = TooltipColor(red: 1, green: 0, blue: 0)
        public static let green = TooltipColor(red: 0, green: 0.8, blue: 0.4)
        public static let blue = TooltipColor(red: 0.2, green: 0.6, blue: 1)
        
        // Semantic colors
        public static let success = TooltipColor(hex: "#34C759")
        public static let warning = TooltipColor(hex: "#FF9500")
        public static let error = TooltipColor(hex: "#FF3B30")
        public static let info = TooltipColor(hex: "#1DA1F2")
    }
}

// MARK: - Tooltip Configuration

/// Configuration for PTooltip styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTooltipConfiguration: Equatable, Sendable {
    /// Position of the tooltip relative to anchor
    public var position: PTooltipPosition = .bottom
    /// Arrow alignment along the tooltip edge
    public var arrowAlignment: PTooltipArrowAlignment = .center
    /// Corner radius for the tooltip
    public var radius: RadiusSize = .md
    /// Arrow size (width and height)
    public var arrowSize: CGFloat = 8
    /// Content padding
    public var padding: SpacingSize = .sm
    /// Horizontal padding multiplier (for text tooltips)
    public var horizontalPaddingMultiplier: CGFloat = 1.5
    /// Maximum width (nil for auto)
    public var maxWidth: CGFloat? = nil
    /// Distance from anchor
    public var offset: CGFloat = 4
    /// Whether to auto-dismiss after delay
    public var autoDismiss: Bool = false
    /// Auto-dismiss delay in seconds
    public var autoDismissDelay: Double = 3.0
    /// Whether to dismiss on tap
    public var dismissOnTap: Bool = true
    /// Tooltip style (colors)
    public var style: PTooltipStyle = .dark
    /// Display duration for touch-triggered tooltips (iOS)
    public var displayDuration: Double = 2.5
    /// Show delay before tooltip appears
    public var showDelay: Double = 0.5
    
    public init() {}
    
    public static func == (lhs: PTooltipConfiguration, rhs: PTooltipConfiguration) -> Bool {
        lhs.position == rhs.position &&
        lhs.radius == rhs.radius &&
        lhs.arrowSize == rhs.arrowSize &&
        lhs.padding == rhs.padding &&
        lhs.horizontalPaddingMultiplier == rhs.horizontalPaddingMultiplier &&
        lhs.maxWidth == rhs.maxWidth &&
        lhs.offset == rhs.offset &&
        lhs.autoDismiss == rhs.autoDismiss &&
        lhs.autoDismissDelay == rhs.autoDismissDelay &&
        lhs.dismissOnTap == rhs.dismissOnTap &&
        lhs.style == rhs.style &&
        lhs.displayDuration == rhs.displayDuration &&
        lhs.showDelay == rhs.showDelay
    }
}

// MARK: - Tooltip Arrow Shape

/// Custom shape for the tooltip arrow
struct TooltipArrowShape: Shape {
    let position: PTooltipPosition
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch position {
        case .top:
            // Arrow points down (tooltip is above anchor)
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.closeSubpath()
            
        case .bottom:
            // Arrow points up (tooltip is below anchor)
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
            
        case .leading:
            // Arrow points right (tooltip is to the left of anchor)
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            
        case .trailing:
            // Arrow points left (tooltip is to the right of anchor)
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
        
        return path
    }
}

// MARK: - PTooltip View

/// A tooltip component with arrow pointer and fluid animations
///
/// Usage:
/// ```swift
/// // Standalone tooltip
/// PTooltip("Invalid Word")
///
/// // With position
/// PTooltip("Tap to add an image", position: .top)
///
/// // Custom content
/// PTooltip(position: .bottom) {
///     HStack(spacing: 12) {
///         Text("habit")
///         Divider()
///         Text("hair")
///         Divider()
///         Text("half")
///     }
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTooltip<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    private var config: PTooltipConfiguration
    private let content: Content
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var tooltipConfig: TooltipConfig {
        theme.components.tooltip
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
    private var resolvedPadding: CGFloat {
        theme.spacing[config.padding]
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
        case .custom(_, let text):
            return text.color
        }
    }
    
    // MARK: - Initializers
    
    /// Create a tooltip with custom content
    public init(
        position: PTooltipPosition = .bottom,
        @ViewBuilder content: () -> Content
    ) {
        var config = PTooltipConfiguration()
        config.position = position
        self.config = config
        self.content = content()
    }
    
    /// Create a tooltip with a text message
    public init(
        _ text: String,
        position: PTooltipPosition = .bottom
    ) where Content == Text {
        var config = PTooltipConfiguration()
        config.position = position
        self.config = config
        self.content = Text(text)
    }
    
    // Private init for modifiers
    private init(config: PTooltipConfiguration, content: Content) {
        self.config = config
        self.content = content
    }
    
    // MARK: - Body
    
    public var body: some View {
        tooltipBody
    }
    
    @ViewBuilder
    private var tooltipBody: some View {
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
    }
    
    @ViewBuilder
    private var contentView: some View {
        content
            .font(.system(size: theme.typography.sizes.sm, weight: .medium))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, resolvedPadding * config.horizontalPaddingMultiplier)
            .padding(.vertical, resolvedPadding)
            .frame(maxWidth: config.maxWidth)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
    }
    
    @ViewBuilder
    private var arrowView: some View {
        TooltipArrowShape(position: config.position)
            .fill(backgroundColor)
            .frame(
                width: config.position == .top || config.position == .bottom ? config.arrowSize * 2 : config.arrowSize,
                height: config.position == .top || config.position == .bottom ? config.arrowSize : config.arrowSize * 2
            )
    }
}

// MARK: - Fluent Modifiers for PTooltip

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PTooltip {
    
    /// Set the tooltip position
    func position(_ position: PTooltipPosition) -> PTooltip {
        var newConfig = config
        newConfig.position = position
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the corner radius
    func radius(_ radius: RadiusSize) -> PTooltip {
        var newConfig = config
        newConfig.radius = radius
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the arrow size
    func arrowSize(_ size: CGFloat) -> PTooltip {
        var newConfig = config
        newConfig.arrowSize = size
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the content padding
    func padding(_ padding: SpacingSize) -> PTooltip {
        var newConfig = config
        newConfig.padding = padding
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the maximum width
    func maxWidth(_ width: CGFloat?) -> PTooltip {
        var newConfig = config
        newConfig.maxWidth = width
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the offset from anchor
    func offset(_ offset: CGFloat) -> PTooltip {
        var newConfig = config
        newConfig.offset = offset
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the tooltip style
    func style(_ style: PTooltipStyle) -> PTooltip {
        var newConfig = config
        newConfig.style = style
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set dark style (default)
    func dark() -> PTooltip {
        var newConfig = config
        newConfig.style = .dark
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set light style
    func light() -> PTooltip {
        var newConfig = config
        newConfig.style = .light
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set custom background and text colors using TooltipColor
    func colors(background: PTooltipStyle.TooltipColor, text: PTooltipStyle.TooltipColor) -> PTooltip {
        var newConfig = config
        newConfig.style = .custom(background: background, text: text)
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set custom background and text colors using hex strings
    func colors(backgroundHex: String, textHex: String) -> PTooltip {
        var newConfig = config
        newConfig.style = .custom(
            background: PTooltipStyle.TooltipColor(hex: backgroundHex),
            text: PTooltipStyle.TooltipColor(hex: textHex)
        )
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the display duration for auto-dismiss
    func displayDuration(_ duration: Double) -> PTooltip {
        var newConfig = config
        newConfig.displayDuration = duration
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Set the show delay
    func showDelay(_ delay: Double) -> PTooltip {
        var newConfig = config
        newConfig.showDelay = delay
        return PTooltip(config: newConfig, content: content)
    }
    
    /// Enable auto-dismiss with optional custom delay
    func autoDismiss(_ enabled: Bool = true, delay: Double? = nil) -> PTooltip {
        var newConfig = config
        newConfig.autoDismiss = enabled
        if let delay = delay {
            newConfig.autoDismissDelay = delay
        }
        return PTooltip(config: newConfig, content: content)
    }
}

// MARK: - Inline Tooltip Overlay

/// Simplified tooltip overlay that positions relative to anchor using alignment
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct PTooltipInlineOverlay<TooltipContent: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    var config: PTooltipConfiguration
    @ViewBuilder var tooltipContent: () -> TooltipContent
    
    // MARK: - State
    
    @State private var isAnimating = false
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Entry animation - spring with slight bounce (matching PModal)
    private var entryAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.1)
            : .spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0)
    }
    
    /// Exit animation - fast ease in
    private var exitAnimation: Animation {
        reduceMotion
            ? .easeIn(duration: 0.08)
            : .easeIn(duration: 0.15)
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
        case .custom(_, let text):
            return text.color
        }
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
    private var resolvedPadding: CGFloat {
        theme.spacing[config.padding]
    }
    
    /// Entry offset direction for animation
    private var entryOffset: CGSize {
        guard !isAnimating else { return .zero }
        let distance: CGFloat = 6
        
        switch config.position {
        case .top: return CGSize(width: 0, height: distance)
        case .bottom: return CGSize(width: 0, height: -distance)
        case .leading: return CGSize(width: distance, height: 0)
        case .trailing: return CGSize(width: -distance, height: 0)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        tooltipView
            .opacity(isAnimating ? 1 : 0)
            .scaleEffect(isAnimating ? 1 : 0.95)
            .offset(entryOffset)
            .animation(entryAnimation, value: isAnimating)
            .onAppear {
                withAnimation(entryAnimation) {
                    isAnimating = true
                }
                
                // Auto-dismiss if enabled
                if config.autoDismiss {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.autoDismissDelay) {
                        dismiss()
                    }
                }
            }
            .onChange(of: isPresented) { newValue in
                if !newValue && isAnimating {
                    dismiss()
                }
            }
    }
    
    @ViewBuilder
    private var tooltipView: some View {
        Group {
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
        }
        .fixedSize()
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 12,
            x: 0,
            y: 4
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if config.dismissOnTap {
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        tooltipContent()
            .font(.system(size: theme.typography.sizes.sm, weight: .medium))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, resolvedPadding * config.horizontalPaddingMultiplier)
            .padding(.vertical, resolvedPadding)
            .frame(maxWidth: config.maxWidth)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
    }
    
    @ViewBuilder
    private var arrowView: some View {
        TooltipArrowShape(position: config.position)
            .fill(backgroundColor)
            .frame(
                width: config.position == .top || config.position == .bottom ? config.arrowSize * 2 : config.arrowSize,
                height: config.position == .top || config.position == .bottom ? config.arrowSize : config.arrowSize * 2
            )
    }
    
    // MARK: - Actions
    
    private func dismiss() {
        withAnimation(exitAnimation) {
            isAnimating = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            isPresented = false
        }
    }
}

// MARK: - PTooltip View Modifier

/// A view modifier that presents a tooltip attached to the modified view
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTooltipModifier<TooltipContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var config: PTooltipConfiguration
    @ViewBuilder var tooltipContent: () -> TooltipContent
    
    @State private var anchorSize: CGSize = .zero
    @State private var tooltipSize: CGSize = .zero
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { anchorSize = geo.size }
                        .onChange(of: geo.size) { anchorSize = $0 }
                }
            )
            .overlay {
                if isPresented {
                    PTooltipInlineOverlay(
                        isPresented: $isPresented,
                        config: config,
                        tooltipContent: tooltipContent
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { tooltipSize = geo.size }
                                .onChange(of: geo.size) { tooltipSize = $0 }
                        }
                    )
                    .offset(calculateOffset())
                }
            }
    }
    
    /// Calculate the offset to position tooltip outside the anchor
    private func calculateOffset() -> CGSize {
        let gap = config.offset
        
        switch config.position {
        case .top:
            // Position tooltip above anchor
            let y = -(anchorSize.height / 2) - (tooltipSize.height / 2) - gap
            return CGSize(width: 0, height: y)
            
        case .bottom:
            // Position tooltip below anchor
            let y = (anchorSize.height / 2) + (tooltipSize.height / 2) + gap
            return CGSize(width: 0, height: y)
            
        case .leading:
            // Position tooltip to the left of anchor
            let x = -(anchorSize.width / 2) - (tooltipSize.width / 2) - gap
            return CGSize(width: x, height: 0)
            
        case .trailing:
            // Position tooltip to the right of anchor
            let x = (anchorSize.width / 2) + (tooltipSize.width / 2) + gap
            return CGSize(width: x, height: 0)
        }
    }
}

// MARK: - View Extension for pTooltip

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Present a tooltip with text content
    ///
    /// ```swift
    /// TextField("Word", text: $word)
    ///     .pTooltip(isPresented: $showError, text: "Invalid Word")
    ///
    /// // With position
    /// Button("Help") {}
    ///     .pTooltip(isPresented: $showHelp, position: .top, text: "Tap for assistance")
    /// ```
    func pTooltip(
        isPresented: Binding<Bool>,
        position: PTooltipPosition = .bottom,
        text: String
    ) -> some View {
        var config = PTooltipConfiguration()
        config.position = position
        return modifier(
            PTooltipModifier(
                isPresented: isPresented,
                config: config,
                tooltipContent: { Text(text) }
            )
        )
    }
    
    /// Present a tooltip with custom content
    ///
    /// ```swift
    /// TextField("Word", text: $word)
    ///     .pTooltip(isPresented: $showSuggestions, position: .bottom) {
    ///         HStack(spacing: 0) {
    ///             ForEach(suggestions, id: \.self) { word in
    ///                 Button(word) { selectWord(word) }
    ///                     .padding(.horizontal, 12)
    ///                 if word != suggestions.last {
    ///                     Divider()
    ///                 }
    ///             }
    ///         }
    ///     }
    /// ```
    func pTooltip<Content: View>(
        isPresented: Binding<Bool>,
        position: PTooltipPosition = .bottom,
        autoDismiss: Bool = false,
        autoDismissDelay: Double = 3.0,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var config = PTooltipConfiguration()
        config.position = position
        config.autoDismiss = autoDismiss
        config.autoDismissDelay = autoDismissDelay
        return modifier(
            PTooltipModifier(
                isPresented: isPresented,
                config: config,
                tooltipContent: content
            )
        )
    }
    
    /// Present a tooltip with full configuration
    ///
    /// ```swift
    /// view.pTooltip(
    ///     isPresented: $show,
    ///     config: PTooltipConfiguration(
    ///         position: .top,
    ///         radius: .lg,
    ///         arrowSize: 10
    ///     )
    /// ) {
    ///     CustomTooltipContent()
    /// }
    /// ```
    func pTooltip<Content: View>(
        isPresented: Binding<Bool>,
        config: PTooltipConfiguration,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            PTooltipModifier(
                isPresented: isPresented,
                config: config,
                tooltipContent: content
            )
        )
    }
}

// MARK: - Hover Tooltip Modifier

/// A view modifier that shows a tooltip on hover (macOS/pointer) or long press (iOS touch)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTooltipHoverModifier<TooltipContent: View>: ViewModifier {
    var config: PTooltipConfiguration
    @ViewBuilder var tooltipContent: () -> TooltipContent
    
    @State private var isPresented = false
    @State private var isHovering = false
    @State private var showWorkItem: DispatchWorkItem?
    @State private var anchorSize: CGSize = .zero
    @State private var tooltipSize: CGSize = .zero
    
    /// The delay before showing the tooltip
    private var effectiveShowDelay: Double {
        config.showDelay
    }
    
    /// The duration the tooltip stays visible on touch (iOS)
    private var effectiveDisplayDuration: Double {
        config.displayDuration
    }
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear { anchorSize = geo.size }
                        .onChange(of: geo.size) { anchorSize = $0 }
                }
            )
            // Hover support (macOS and iOS with pointer)
            .onHover { hovering in
                isHovering = hovering
                
                // Cancel any pending work
                showWorkItem?.cancel()
                
                if hovering {
                    // Schedule show after delay
                    let workItem = DispatchWorkItem {
                        if isHovering {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                                isPresented = true
                            }
                        }
                    }
                    showWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + effectiveShowDelay, execute: workItem)
                } else {
                    // Hide with animation
                    withAnimation(.easeIn(duration: 0.15)) {
                        isPresented = false
                    }
                }
            }
            // Long press support (iOS touch without pointer)
            #if os(iOS)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: effectiveShowDelay)
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.85)) {
                            isPresented = true
                        }
                        
                        // Auto-dismiss after configured duration on touch
                        DispatchQueue.main.asyncAfter(deadline: .now() + effectiveDisplayDuration) {
                            withAnimation(.easeIn(duration: 0.15)) {
                                isPresented = false
                            }
                        }
                    }
            )
            #endif
            .overlay {
                if isPresented {
                    PTooltipInlineOverlay(
                        isPresented: $isPresented,
                        config: config,
                        tooltipContent: tooltipContent
                    )
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onAppear { tooltipSize = geo.size }
                                .onChange(of: geo.size) { tooltipSize = $0 }
                        }
                    )
                    .offset(calculateOffset())
                    .allowsHitTesting(false)
                }
            }
            // Tap anywhere to dismiss on iOS
            #if os(iOS)
            .onTapGesture {
                if isPresented {
                    withAnimation(.easeIn(duration: 0.15)) {
                        isPresented = false
                    }
                }
            }
            #endif
    }
    
    /// Calculate the offset to position tooltip outside the anchor
    private func calculateOffset() -> CGSize {
        let gap = config.offset
        
        switch config.position {
        case .top:
            // Position tooltip above anchor
            let y = -(anchorSize.height / 2) - (tooltipSize.height / 2) - gap
            return CGSize(width: 0, height: y)
            
        case .bottom:
            // Position tooltip below anchor
            let y = (anchorSize.height / 2) + (tooltipSize.height / 2) + gap
            return CGSize(width: 0, height: y)
            
        case .leading:
            // Position tooltip to the left of anchor
            let x = -(anchorSize.width / 2) - (tooltipSize.width / 2) - gap
            return CGSize(width: x, height: 0)
            
        case .trailing:
            // Position tooltip to the right of anchor
            let x = (anchorSize.width / 2) + (tooltipSize.width / 2) + gap
            return CGSize(width: x, height: 0)
        }
    }
}

// MARK: - Hover Tooltip View Extensions

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Show a tooltip on hover (macOS) or long press (iOS)
    ///
    /// ```swift
    /// // Simple text tooltip on hover
    /// Button("Help") {}
    ///     .pTooltipOnHover("Click for help")
    ///
    /// // With custom position and delay
    /// Icon()
    ///     .pTooltipOnHover("Settings", position: .top, delay: 0.3)
    ///
    /// // With custom style
    /// Icon()
    ///     .pTooltipOnHover("Light tooltip", style: .light)
    /// ```
    func pTooltipOnHover(
        _ text: String,
        position: PTooltipPosition = .bottom,
        style: PTooltipStyle = .dark,
        delay: Double = 0.5,
        displayDuration: Double = 2.5
    ) -> some View {
        var config = PTooltipConfiguration()
        config.position = position
        config.style = style
        config.showDelay = delay
        config.displayDuration = displayDuration
        config.dismissOnTap = false
        return modifier(
            PTooltipHoverModifier(
                config: config,
                tooltipContent: { Text(text) }
            )
        )
    }
    
    /// Show a tooltip with custom content on hover (macOS) or long press (iOS)
    ///
    /// ```swift
    /// Button("Info") {}
    ///     .pTooltipOnHover(position: .top, style: .light) {
    ///         VStack {
    ///             Text("Title")
    ///             Text("Description")
    ///         }
    ///     }
    /// ```
    func pTooltipOnHover<Content: View>(
        position: PTooltipPosition = .bottom,
        style: PTooltipStyle = .dark,
        delay: Double = 0.5,
        displayDuration: Double = 2.5,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var config = PTooltipConfiguration()
        config.position = position
        config.style = style
        config.showDelay = delay
        config.displayDuration = displayDuration
        config.dismissOnTap = false
        return modifier(
            PTooltipHoverModifier(
                config: config,
                tooltipContent: content
            )
        )
    }
    
    /// Show a tooltip with full configuration on hover (macOS) or long press (iOS)
    ///
    /// ```swift
    /// var config = PTooltipConfiguration()
    /// config.position = .bottom
    /// config.style = .custom(
    ///     background: .init(red: 0.2, green: 0.6, blue: 1),
    ///     text: .white
    /// )
    /// config.displayDuration = 5.0
    ///
    /// Button("Custom") {}
    ///     .pTooltipOnHover(config: config) {
    ///         Text("Custom styled tooltip")
    ///     }
    /// ```
    func pTooltipOnHover<Content: View>(
        config: PTooltipConfiguration,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            PTooltipHoverModifier(
                config: config,
                tooltipContent: content
            )
        )
    }
}

// MARK: - Tooltip Content Builders

/// Pre-built tooltip content for word suggestions (like in the screenshots)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTooltipSuggestions: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let suggestions: [String]
    private let onSelect: (String) -> Void
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public init(_ suggestions: [String], onSelect: @escaping (String) -> Void) {
        self.suggestions = suggestions
        self.onSelect = onSelect
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(suggestions.enumerated()), id: \.offset) { index, word in
                Button {
                    onSelect(word)
                } label: {
                    Text(word)
                        .font(.system(size: theme.typography.sizes.sm, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
                
                if index < suggestions.count - 1 {
                    Rectangle()
                        .fill(colors.background.opacity(0.3))
                        .frame(width: 1)
                        .padding(.vertical, 4)
                }
            }
        }
    }
}

/// Rich tooltip content with title and description (like "Let's back up your wallet!")
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTooltipRichContent: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let title: String
    private let description: String?
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public init(_ title: String, description: String? = nil) {
        self.title = title
        self.description = description
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(.system(size: theme.typography.sizes.sm, weight: .semibold))
            
            if let description = description {
                Text(description)
                    .font(.system(size: theme.typography.sizes.xs))
                    .opacity(0.8)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PTooltip_Previews: PreviewProvider {
    static var previews: some View {
        PTooltipPreviewContainer()
            .prettyTheme(.family)
            .previewDisplayName("Tooltip Demo")
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct PTooltipPreviewContainer: View {
    @State private var showInvalidWord = false
    @State private var showSuggestions = false
    @State private var showTopTooltip = false
    @State private var showRichTooltip = false
    @State private var showLeadingTooltip = false
    @State private var showTrailingTooltip = false
    @State private var showCustomStyled = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 48) {
                    // Static tooltips showcase
                    Group {
                        sectionHeader("Static Tooltips")
                        
                        VStack(spacing: 24) {
                            PTooltip("Invalid Word", position: .bottom)
                            
                            PTooltip("Tap to add an image", position: .top)
                            
                            PTooltip(position: .bottom) {
                                HStack(spacing: 12) {
                                    Text("habit")
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 1)
                                    Text("hair")
                                    Rectangle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 1)
                                    Text("half")
                                }
                                .font(.system(size: 14, weight: .medium))
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Tooltip Styles
                    Group {
                        sectionHeader("Tooltip Styles")
                        
                        VStack(spacing: 24) {
                            // Dark style (default)
                            HStack {
                                Text("Dark (Default)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Dark tooltip", position: .leading)
                                    .style(.dark)
                            }
                            
                            // Light style
                            HStack {
                                Text("Light")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Light tooltip", position: .leading)
                                    .style(.light)
                            }
                            
                            // Custom colors - Success
                            HStack {
                                Text("Success (Green)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Success!", position: .leading)
                                    .colors(background: .success, text: .white)
                            }
                            
                            // Custom colors - Warning
                            HStack {
                                Text("Warning (Orange)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Warning!", position: .leading)
                                    .colors(background: .warning, text: .white)
                            }
                            
                            // Custom colors - Error
                            HStack {
                                Text("Error (Red)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Error!", position: .leading)
                                    .colors(background: .error, text: .white)
                            }
                            
                            // Custom colors - Info (Blue)
                            HStack {
                                Text("Info (Blue)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Info tooltip", position: .leading)
                                    .colors(background: .info, text: .white)
                            }
                            
                            // Custom hex colors
                            HStack {
                                Text("Custom Hex (#8B5CF6)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                                PTooltip("Purple tooltip", position: .leading)
                                    .colors(backgroundHex: "#8B5CF6", textHex: "#FFFFFF")
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Hover tooltips with styles
                    Group {
                        sectionHeader("Hover / Long Press Tooltips")
                        sectionSubheader("Hover (macOS) or long-press (iOS) these icons")
                        
                        HStack(spacing: 20) {
                            // Dark (default)
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "moon.fill")
                                        .font(.title2)
                                    Text("Dark")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover("Dark style", position: .bottom, style: .dark)
                            
                            // Light
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "sun.max.fill")
                                        .font(.title2)
                                    Text("Light")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover("Light style", position: .bottom, style: .light)
                            
                            // Success
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                    Text("Success")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover(
                                "Success!",
                                position: .bottom,
                                style: .custom(background: .success, text: .white)
                            )
                            
                            // Warning
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                    Text("Warning")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover(
                                "Warning!",
                                position: .bottom,
                                style: .custom(background: .warning, text: .white)
                            )
                            
                            // Error
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.red)
                                    Text("Error")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover(
                                "Error!",
                                position: .bottom,
                                style: .custom(background: .error, text: .white)
                            )
                        }
                        
                        // Custom timing
                        HStack(spacing: 24) {
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "hare.fill")
                                        .font(.title2)
                                    Text("Fast (0.2s)")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover("Quick tooltip!", position: .top, delay: 0.2)
                            
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "tortoise.fill")
                                        .font(.title2)
                                    Text("Slow (1s)")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover("Slow tooltip...", position: .top, delay: 1.0)
                            
                            Button {} label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "clock.fill")
                                        .font(.title2)
                                    Text("Long (5s)")
                                        .font(.caption2)
                                }
                            }
                            .pTooltipOnHover("Stays for 5 seconds", position: .top, displayDuration: 5.0)
                        }
                        .padding(.top, 16)
                    }
                    
                    Divider()
                    
                    // Tap-triggered tooltips
                    Group {
                        sectionHeader("Tap-Triggered Tooltips")
                        
                        VStack(spacing: 24) {
                            // Basic tooltips
                            HStack(spacing: 16) {
                                Button("Invalid Word") {
                                    showInvalidWord.toggle()
                                }
                                .buttonStyle(.bordered)
                                .pTooltip(isPresented: $showInvalidWord, position: .bottom, text: "Invalid Word")
                                
                                Button("Top Tooltip") {
                                    showTopTooltip.toggle()
                                }
                                .buttonStyle(.bordered)
                                .pTooltip(isPresented: $showTopTooltip, position: .top, text: "Tap to add an image")
                            }
                            
                            // Suggestions tooltip
                            Button("Show Suggestions") {
                                showSuggestions.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pTooltip(isPresented: $showSuggestions, position: .bottom) {
                                PTooltipSuggestions(["habit", "hair", "half"]) { word in
                                    print("Selected: \(word)")
                                    showSuggestions = false
                                }
                            }
                            
                            // Rich content tooltip
                            Button("Show Rich Tooltip") {
                                showRichTooltip.toggle()
                            }
                            .buttonStyle(.bordered)
                            .pTooltip(isPresented: $showRichTooltip, position: .bottom) {
                                PTooltipRichContent(
                                    "Let's back up your wallet!",
                                    description: "\"Backing up\" means saving your wallet's Secret Recovery Phrase in a secure location that you control."
                                )
                                .frame(maxWidth: 280)
                            }
                            
                            // Leading/Trailing tooltips
                            HStack(spacing: 40) {
                                Button("Leading") {
                                    showLeadingTooltip.toggle()
                                }
                                .buttonStyle(.bordered)
                                .pTooltip(isPresented: $showLeadingTooltip, position: .leading, text: "Left side")
                                
                                Button("Trailing") {
                                    showTrailingTooltip.toggle()
                                }
                                .buttonStyle(.bordered)
                                .pTooltip(isPresented: $showTrailingTooltip, position: .trailing, text: "Right side")
                            }
                        }
                    }
                    
                    Divider()
                    
                    // All positions
                    Group {
                        sectionHeader("All Positions")
                        
                        VStack(spacing: 60) {
                            // Top
                            VStack(spacing: 8) {
                                PTooltip("Top Position", position: .top)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 40)
                                    .overlay(Text("Anchor").font(.caption))
                            }
                            
                            // Bottom
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 100, height: 40)
                                    .overlay(Text("Anchor").font(.caption))
                                PTooltip("Bottom Position", position: .bottom)
                                    .colors(background: .success, text: .white)
                            }
                            
                            // Leading & Trailing
                            HStack(spacing: 40) {
                                HStack(spacing: 8) {
                                    PTooltip("Leading", position: .leading)
                                        .colors(background: .warning, text: .white)
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 40)
                                        .overlay(Text("Anchor").font(.caption2))
                                }
                                
                                HStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 40)
                                        .overlay(Text("Anchor").font(.caption2))
                                    PTooltip("Trailing", position: .trailing)
                                        .colors(background: .error, text: .white)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("PTooltip")
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

