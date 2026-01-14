//
//  PModal.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired modal component with fluid spring animations.
//  Presents a centered dialog with customizable content, icon, and action buttons.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - Modal Dismiss Environment Key

/// Wrapper class to hold the dismiss action (allows passing MainActor function through environment)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
final class PModalDismissAction: @unchecked Sendable {
    let dismiss: () -> Void
    
    init(_ dismiss: @escaping () -> Void) {
        self.dismiss = dismiss
    }
}

/// Environment key for modal dismiss action
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct PModalDismissKey: EnvironmentKey {
    static let defaultValue: PModalDismissAction? = nil
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    var pModalDismiss: PModalDismissAction? {
        get { self[PModalDismissKey.self] }
        set { self[PModalDismissKey.self] = newValue }
    }
}

// MARK: - Modal Position

/// Position options for PModal
public enum PModalPosition: String, Equatable, Sendable, CaseIterable {
    /// Centered in the screen (default)
    case center
    /// Positioned at the top of the screen
    case top
    /// Positioned at the bottom of the screen
    case bottom
}

// MARK: - Modal Overlay Style

/// Overlay/backdrop style options for PModal
public enum PModalOverlayStyle: Equatable, Sendable {
    /// Dimmed black overlay with configurable opacity (default)
    case dimmed
    /// Blurred overlay with configurable blur radius
    case blurred(radius: CGFloat = 10)
    /// Dimmed overlay combined with blur effect
    case dimmedBlur(opacity: Double = 0.3, radius: CGFloat = 10)
    /// Custom color overlay
    case color(Color, opacity: Double = 0.5)
    /// No overlay (transparent)
    case none
}

// MARK: - Modal Variant

/// Visual variants for PModal
public enum PModalVariant: String, Equatable, Sendable, CaseIterable {
    /// Standard informational modal
    case standard
    /// Destructive action modal (red accent)
    case destructive
    /// Success confirmation modal (green accent)
    case success
    /// Warning modal (orange accent)
    case warning
}

// MARK: - Modal Button Configuration

/// Configuration for modal action buttons
public struct PModalButton {
    let title: String
    let variant: PButtonVariant
    let action: () -> Void
    
    /// Create a cancel button
    public static func cancel(_ title: String = "Cancel", action: @escaping () -> Void) -> PModalButton {
        PModalButton(title: title, variant: .secondary, action: action)
    }
    
    /// Create a destructive button
    public static func destructive(_ title: String, action: @escaping () -> Void) -> PModalButton {
        PModalButton(title: title, variant: .destructive, action: action)
    }
    
    /// Create a primary button
    public static func primary(_ title: String, action: @escaping () -> Void) -> PModalButton {
        PModalButton(title: title, variant: .primary, action: action)
    }
    
    /// Create a secondary button
    public static func secondary(_ title: String, action: @escaping () -> Void) -> PModalButton {
        PModalButton(title: title, variant: .secondary, action: action)
    }
}

// MARK: - Modal Configuration

/// Configuration for PModal styling
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PModalConfiguration {
    /// SF Symbol name for the icon
    public var icon: String? = nil
    /// Custom icon color (defaults to variant-based color)
    public var iconColor: Color? = nil
    /// Whether to show the close button in the top-right
    public var showCloseButton: Bool = true
    /// Whether tapping the backdrop dismisses the modal
    public var dismissOnBackgroundTap: Bool = true
    /// Corner radius for the modal card
    public var radius: RadiusSize = .xxl
    /// Modal variant (affects icon color and accent)
    public var variant: PModalVariant = .standard
    /// Position of the modal on screen
    public var position: PModalPosition = .center
    /// Maximum width of the modal (for iPad/Mac)
    public var maxWidth: CGFloat = 340
    /// Content padding
    public var contentPadding: SpacingSize = .lg
    /// Backdrop opacity (used for .dimmed overlay style)
    public var backdropOpacity: Double = 0.5
    /// Overlay/backdrop style
    public var overlayStyle: PModalOverlayStyle = .dimmed
    /// Custom top padding (for .top position)
    public var topPadding: CGFloat? = nil
    /// Custom bottom padding (for .bottom position)
    public var bottomPadding: CGFloat? = nil
    /// Custom horizontal padding
    public var horizontalPadding: CGFloat = 16
    
    public init() {}
}

// MARK: - PModal View Modifier

/// A view modifier that presents a modal dialog
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PModalModifier<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var config: PModalConfiguration
    @ViewBuilder var modalContent: () -> ModalContent
    
    // Internal state to control actual visibility (allows for animated dismiss)
    @State private var isShowingOverlay = false
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                if isShowingOverlay {
                    GeometryReader { geo in
                        PModalOverlay(
                            isPresented: $isPresented,
                            isShowing: $isShowingOverlay,
                            config: config,
                            content: modalContent
                        )
                        .frame(width: screenSize.width, height: screenSize.height)
                        .position(
                            x: screenSize.width / 2 - geo.frame(in: .global).minX,
                            y: screenSize.height / 2 - geo.frame(in: .global).minY
                        )
                        .ignoresSafeArea()
                    }
                }
            }
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Show immediately when isPresented becomes true
                    isShowingOverlay = true
                }
                // When isPresented becomes false, PModalOverlay handles the animated dismiss
                // and will set isShowingOverlay = false after animation completes
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
}

// MARK: - Modal Overlay

/// The overlay that contains the backdrop and modal card
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct PModalOverlay<Content: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    @Binding var isShowing: Bool
    var config: PModalConfiguration
    @ViewBuilder var content: Content
    
    // MARK: - State
    
    @State private var isAnimating = false
    @State private var isDismissing = false
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Constants
    
    /// Threshold to trigger dismiss (in points)
    private let dismissThreshold: CGFloat = 100
    /// Resistance factor for dragging in wrong direction
    private let dragResistance: CGFloat = 0.3
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Entry animation - spring with slight bounce
    private var entryAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0)
    }
    
    /// Exit animation - fast ease in that accelerates as it slides off screen
    private var exitAnimation: Animation {
        reduceMotion
            ? .easeIn(duration: 0.1)
            : .easeIn(duration: 0.18)
    }
    
    /// Spring animation for drag release snap-back
    private var snapBackAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }
    
    private var backdropAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.1)
            : .easeOut(duration: isDismissing ? 0.2 : 0.18)
    }
    
    /// Current animation based on state
    private var currentAnimation: Animation {
        isDismissing ? exitAnimation : entryAnimation
    }
    
    /// ZStack alignment based on position
    private var alignment: Alignment {
        switch config.position {
        case .center:
            return .center
        case .top:
            return .top
        case .bottom:
            return .bottom
        }
    }
    
    /// Slide offset based on position - each position has appropriate entry/exit direction
    private var slideOffset: CGFloat {
        if isAnimating {
            return 0
        }
        
        switch config.position {
        case .center, .bottom:
            // Entry: slide up from below, Exit: slide down off screen
            return isDismissing ? 500 : 60
        case .top:
            // Entry: slide down from above, Exit: slide up off screen
            return isDismissing ? -500 : -60
        }
    }
    
    /// Total offset including drag
    private var totalOffset: CGFloat {
        slideOffset + dragOffset
    }
    
    /// Drag progress for adjusting overlay effects (0 = no drag, 1 = at dismiss threshold)
    private var dragProgress: Double {
        let dismissDirection = config.position == .top ? -1.0 : 1.0
        let progress = (dragOffset * dismissDirection) / dismissThreshold
        return min(max(progress, 0), 1)
    }
    
    /// Backdrop opacity adjusted for drag progress
    private var adjustedBackdropOpacity: Double {
        guard isAnimating else { return 0 }
        
        let baseOpacity: Double
        switch config.overlayStyle {
        case .dimmed:
            baseOpacity = config.backdropOpacity
        case .dimmedBlur(let opacity, _):
            baseOpacity = opacity
        case .color(_, let opacity):
            baseOpacity = opacity
        case .blurred, .none:
            baseOpacity = 0
        }
        
        return baseOpacity * (1 - dragProgress * 0.5)
    }
    
    /// Blur radius adjusted for drag progress
    private var adjustedBlurRadius: CGFloat {
        guard isAnimating else { return 0 }
        
        let baseRadius: CGFloat
        switch config.overlayStyle {
        case .blurred(let radius):
            baseRadius = radius
        case .dimmedBlur(_, let radius):
            baseRadius = radius
        case .dimmed, .color, .none:
            baseRadius = 0
        }
        
        return baseRadius * (1 - dragProgress * 0.5)
    }
    
    /// Overlay color based on style
    private var overlayColor: Color {
        switch config.overlayStyle {
        case .color(let color, _):
            return color
        case .dimmed, .blurred, .dimmedBlur, .none:
            return .black
        }
    }
    
    /// Edge padding for top/bottom positions
    private var edgePadding: EdgeInsets {
        let horizontal = config.horizontalPadding
        switch config.position {
        case .center:
            return EdgeInsets(
                top: config.topPadding ?? 0,
                leading: horizontal,
                bottom: config.bottomPadding ?? 0,
                trailing: horizontal
            )
        case .top:
            return EdgeInsets(
                top: config.topPadding ?? 16,
                leading: horizontal,
                bottom: 0,
                trailing: horizontal
            )
        case .bottom:
            return EdgeInsets(
                top: 0,
                leading: horizontal,
                bottom: config.bottomPadding ?? 16,
                trailing: horizontal
            )
        }
    }
    
    /// Drag gesture for dismissing the modal
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                
                // Determine if dragging in dismiss direction
                let isDismissDirection: Bool
                switch config.position {
                case .center, .bottom:
                    isDismissDirection = translation > 0 // Dragging down
                case .top:
                    isDismissDirection = translation < 0 // Dragging up
                }
                
                if isDismissDirection {
                    // Allow full movement in dismiss direction
                    dragOffset = translation
                } else {
                    // Apply resistance when dragging in wrong direction
                    dragOffset = translation * dragResistance
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                
                // Check if should dismiss based on position
                let shouldDismiss: Bool
                switch config.position {
                case .center, .bottom:
                    // Dismiss if dragged down past threshold or with high velocity
                    shouldDismiss = translation > dismissThreshold || velocity > 500
                case .top:
                    // Dismiss if dragged up past threshold or with high velocity
                    shouldDismiss = translation < -dismissThreshold || velocity < -500
                }
                
                if shouldDismiss {
                    dismiss()
                } else {
                    // Snap back to original position
                    withAnimation(snapBackAnimation) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: alignment) {
            // Backdrop/Overlay
            overlayView
                .ignoresSafeArea()
                .onTapGesture {
                    if config.dismissOnBackgroundTap {
                        dismiss()
                    }
                }
                .animation(backdropAnimation, value: isAnimating)
            
            // Modal Card - slides based on position, supports drag to dismiss
            content
                .environment(\.pModalDismiss, PModalDismissAction(dismiss))
                .padding(edgePadding)
                .offset(y: totalOffset)
                .opacity(isAnimating ? 1.0 : 0)
                .animation(currentAnimation, value: isAnimating)
                .gesture(dragGesture)
        }
        .onAppear {
            isAnimating = true
        }
        .onChange(of: isPresented) { newValue in
            // Handle programmatic dismissal (when isPresented is set to false externally)
            if !newValue && isAnimating && !isDismissing {
                dismiss()
            }
        }
    }
    
    // MARK: - Overlay View
    
    @ViewBuilder
    private var overlayView: some View {
        switch config.overlayStyle {
        case .none:
            // Transparent but still tappable
            Color.clear
                .contentShape(Rectangle())
            
        case .dimmed:
            // Standard dimmed overlay
            overlayColor
                .opacity(adjustedBackdropOpacity)
            
        case .blurred(let radius):
            // Blur only (no dimming)
            if isAnimating {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .blur(radius: max(0, adjustedBlurRadius - radius))
                    .opacity(isAnimating ? 1 : 0)
            } else {
                Color.clear
            }
            
        case .dimmedBlur:
            // Combined dimmed overlay with blur
            ZStack {
                if isAnimating {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(isAnimating ? 1 : 0)
                }
                overlayColor
                    .opacity(adjustedBackdropOpacity)
            }
            
        case .color:
            // Custom color overlay
            overlayColor
                .opacity(adjustedBackdropOpacity)
        }
    }
    
    // MARK: - Actions
    
    private func dismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        withAnimation(exitAnimation) {
            isAnimating = false
            dragOffset = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) {
            isShowing = false
            isPresented = false
        }
    }
}

// MARK: - Modal Content Builder

/// A pre-styled modal content view with title, description, icon, and actions
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PModalContent<Actions: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.pModalDismiss) private var modalDismiss
    
    // MARK: - Properties
    
    private let title: String
    private var config: PModalConfiguration
    private var descriptionText: String?
    private var actions: Actions?
    private var onClose: (() -> Void)?
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
    private var resolvedPadding: CGFloat {
        theme.spacing[config.contentPadding]
    }
    
    private var iconColor: Color {
        if let customColor = config.iconColor {
            return customColor
        }
        
        switch config.variant {
        case .standard:
            return colors.mutedForeground
        case .destructive:
            return colors.destructive
        case .success:
            return colors.success
        case .warning:
            return colors.warning
        }
    }
    
    // MARK: - Initializers
    
    /// Create modal content with a title
    public init(_ title: String) where Actions == EmptyView {
        self.title = title
        self.config = PModalConfiguration()
        self.descriptionText = nil
        self.actions = nil
        self.onClose = nil
    }
    
    /// Create modal content with a title and actions
    public init(_ title: String, @ViewBuilder actions: () -> Actions) {
        self.title = title
        self.config = PModalConfiguration()
        self.descriptionText = nil
        self.actions = actions()
        self.onClose = nil
    }
    
    // Private init for modifiers
    private init(
        title: String,
        config: PModalConfiguration,
        descriptionText: String?,
        actions: Actions?,
        onClose: (() -> Void)?
    ) {
        self.title = title
        self.config = config
        self.descriptionText = descriptionText
        self.actions = actions
        self.onClose = onClose
    }
    
    // MARK: - Body
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with icon and close button
            headerView
            
            // Title
            Text(title)
                .font(.system(size: theme.typography.sizes.xl, weight: .bold))
                .foregroundColor(colors.foreground)
                .padding(.top, theme.spacing.md)
            
            // Description
            if let description = descriptionText {
                Text(description)
                    .font(.system(size: theme.typography.sizes.base))
                    .foregroundColor(colors.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, theme.spacing.sm)
            }
            
            // Actions
            if let actions = actions {
                actions
                    .padding(.top, theme.spacing.lg)
            }
        }
        .padding(resolvedPadding)
        .frame(maxWidth: config.maxWidth)
        .background(colors.card)
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 32,
            x: 0,
            y: 12
        )
    }
    
    // MARK: - Header View
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .top) {
            // Icon
            if let iconName = config.icon {
                Image(systemName: iconName)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            Spacer(minLength: 0)
            
            // Close button
            if config.showCloseButton {
                Button {
                    // Use the animated dismiss from environment (preferred)
                    // Only fall back to onClose if no environment dismiss available
                    if let dismissAction = modalDismiss {
                        dismissAction.dismiss()
                    } else {
                        onClose?()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(colors.muted)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// MARK: - Fluent Modifiers for PModalContent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PModalContent {
    
    /// Set the modal description text
    func description(_ text: String?) -> PModalContent {
        PModalContent(
            title: title,
            config: config,
            descriptionText: text,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Set the modal icon (SF Symbol name)
    func icon(_ systemName: String) -> PModalContent {
        var newConfig = config
        newConfig.icon = systemName
        return PModalContent(
            title: title,
            config: newConfig,
            descriptionText: descriptionText,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Set custom icon color
    func iconColor(_ color: Color) -> PModalContent {
        var newConfig = config
        newConfig.iconColor = color
        return PModalContent(
            title: title,
            config: newConfig,
            descriptionText: descriptionText,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Set the modal variant
    func variant(_ variant: PModalVariant) -> PModalContent {
        var newConfig = config
        newConfig.variant = variant
        return PModalContent(
            title: title,
            config: newConfig,
            descriptionText: descriptionText,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Show or hide the close button
    func showCloseButton(_ show: Bool) -> PModalContent {
        var newConfig = config
        newConfig.showCloseButton = show
        return PModalContent(
            title: title,
            config: newConfig,
            descriptionText: descriptionText,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Set the corner radius
    func radius(_ radius: RadiusSize) -> PModalContent {
        var newConfig = config
        newConfig.radius = radius
        return PModalContent(
            title: title,
            config: newConfig,
            descriptionText: descriptionText,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Set the maximum width
    func maxWidth(_ width: CGFloat) -> PModalContent {
        var newConfig = config
        newConfig.maxWidth = width
        return PModalContent(
            title: title,
            config: newConfig,
            descriptionText: descriptionText,
            actions: actions,
            onClose: onClose
        )
    }
    
    /// Set the close action
    func onClose(_ action: @escaping () -> Void) -> PModalContent {
        PModalContent(
            title: title,
            config: config,
            descriptionText: descriptionText,
            actions: actions,
            onClose: action
        )
    }
    
    /// Add action buttons
    func actions<A: View>(@ViewBuilder _ content: () -> A) -> PModalContent<A> {
        PModalContent<A>(
            title: title,
            config: config,
            descriptionText: descriptionText,
            actions: content(),
            onClose: onClose
        )
    }
}

// MARK: - View Extension for pModal

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Present a modal dialog with custom content
    ///
    /// ```swift
    /// // Center position (default)
    /// .pModal(isPresented: $showModal) {
    ///     PModalContent("Remove Contact")
    ///         .description("This action cannot be undone.")
    ///         .icon("exclamationmark.circle")
    ///         .actions {
    ///             HStack(spacing: 12) {
    ///                 PButton("Cancel") { showModal = false }
    ///                     .variant(.secondary)
    ///                     .fullWidth()
    ///                 PButton("Remove") { remove() }
    ///                     .variant(.destructive)
    ///                     .fullWidth()
    ///             }
    ///         }
    /// }
    ///
    /// // Bottom position with custom padding
    /// .pModal(isPresented: $showModal, position: .bottom, bottomPadding: 32) {
    ///     // Content
    /// }
    ///
    /// // Top position with custom padding
    /// .pModal(isPresented: $showModal, position: .top, topPadding: 64) {
    ///     // Content
    /// }
    /// ```
    func pModal<Content: View>(
        isPresented: Binding<Bool>,
        position: PModalPosition = .center,
        overlay: PModalOverlayStyle = .dimmed,
        dismissOnBackgroundTap: Bool = true,
        topPadding: CGFloat? = nil,
        bottomPadding: CGFloat? = nil,
        horizontalPadding: CGFloat = 16,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        var config = PModalConfiguration()
        config.position = position
        config.overlayStyle = overlay
        config.dismissOnBackgroundTap = dismissOnBackgroundTap
        config.topPadding = topPadding
        config.bottomPadding = bottomPadding
        config.horizontalPadding = horizontalPadding
        return modifier(
            PModalModifier(
                isPresented: isPresented,
                config: config,
                modalContent: content
            )
        )
    }
}

// MARK: - Convenience Alert-Style Modal

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Present an alert-style modal with predefined buttons
    ///
    /// ```swift
    /// .pModalAlert(
    ///     isPresented: $showAlert,
    ///     title: "Remove Contact",
    ///     message: "This action cannot be undone.",
    ///     icon: "exclamationmark.circle",
    ///     primaryButton: .destructive("Remove") { delete() },
    ///     secondaryButton: .cancel { dismiss() }
    /// )
    ///
    /// // With position and custom padding
    /// .pModalAlert(
    ///     isPresented: $showAlert,
    ///     position: .bottom,
    ///     bottomPadding: 32,
    ///     title: "Confirm",
    ///     primaryButton: .primary("OK") { }
    /// )
    /// ```
    func pModalAlert(
        isPresented: Binding<Bool>,
        position: PModalPosition = .center,
        overlay: PModalOverlayStyle = .dimmed,
        topPadding: CGFloat? = nil,
        bottomPadding: CGFloat? = nil,
        horizontalPadding: CGFloat = 16,
        title: String,
        message: String? = nil,
        icon: String? = nil,
        variant: PModalVariant = .standard,
        primaryButton: PModalButton,
        secondaryButton: PModalButton? = nil
    ) -> some View {
        pModal(
            isPresented: isPresented,
            position: position,
            overlay: overlay,
            topPadding: topPadding,
            bottomPadding: bottomPadding,
            horizontalPadding: horizontalPadding
        ) {
            PModalAlertContent(
                isPresented: isPresented,
                title: title,
                message: message,
                icon: icon,
                variant: variant,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        }
    }
}

// MARK: - Alert Content View

/// Internal view for alert-style modals
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct PModalAlertContent: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.pModalDismiss) private var modalDismiss
    
    // MARK: - Properties
    
    @Binding var isPresented: Bool
    let title: String
    let message: String?
    let icon: String?
    let variant: PModalVariant
    let primaryButton: PModalButton
    let secondaryButton: PModalButton?
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var iconColor: Color {
        switch variant {
        case .standard:
            return colors.mutedForeground
        case .destructive:
            return colors.destructive
        case .success:
            return colors.success
        case .warning:
            return colors.warning
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(alignment: .top) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(iconColor)
                }
                
                Spacer(minLength: 0)
                
                Button {
                    // Use the animated dismiss from environment
                    if let dismissAction = modalDismiss {
                        dismissAction.dismiss()
                    } else {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(colors.muted)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Title
            Text(title)
                .font(.system(size: theme.typography.sizes.xl, weight: .bold))
                .foregroundColor(colors.foreground)
                .padding(.top, theme.spacing.md)
            
            // Message
            if let message = message {
                Text(message)
                    .font(.system(size: theme.typography.sizes.base))
                    .foregroundColor(colors.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, theme.spacing.sm)
            }
            
            // Buttons
            HStack(spacing: theme.spacing.md) {
                if let secondary = secondaryButton {
                    PButton(secondary.title) {
                        secondary.action()
                    }
                    .variant(secondary.variant)
                    .fullWidth()
                }
                
                PButton(primaryButton.title) {
                    primaryButton.action()
                }
                .variant(primaryButton.variant)
                .fullWidth()
            }
            .padding(.top, theme.spacing.lg)
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: 340)
        .background(colors.card)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xxl, style: .continuous))
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 32,
            x: 0,
            y: 12
        )
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PModal_Previews: PreviewProvider {
    static var previews: some View {
        PModalPreviewContainer()
            .prettyTheme(.sky)
            .previewDisplayName("Modal Demo")
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct PModalPreviewContainer: View {
    @State private var showBasicModal = false
    @State private var showDestructiveModal = false
    @State private var showSuccessModal = false
    @State private var showCustomModal = false
    @State private var showAlertModal = false
    
    var body: some View {
        VStack {
            List {
                Section("Modal Examples") {
                    Button("Basic Modal") {
                        showBasicModal = true
                    }
                    
                    Button("Destructive Modal") {
                        showDestructiveModal = true
                    }
                    
                    Button("Success Modal") {
                        showSuccessModal = true
                    }
                    
                    Button("Custom Content Modal") {
                        showCustomModal = true
                    }
                    
                    Button("Alert-Style Modal") {
                        showAlertModal = true
                    }
                }
                
                Section("Usage") {
                    Text("""
                    .pModal(isPresented: $show) {
                        PModalContent("Title")
                            .description("...")
                            .icon("icon.name")
                    }
                    """)
                    .font(.system(.caption, design: .monospaced))
                }
            }
        }
        // Basic Modal
        .pModal(isPresented: $showBasicModal) {
            PModalContent("Notification Settings")
                .description("Would you like to enable push notifications for this app?")
                .icon("bell.badge")
                .onClose { showBasicModal = false }
                .actions {
                    HStack(spacing: 12) {
                        PButton("Not Now") {
                            showBasicModal = false
                        }
                        .size(.md)
                        .variant(.secondary)
                        .fullWidth()
                        
                        PButton("Enable") {
                            showBasicModal = false
                        }
                        .size(.md)
                        .variant(.primary)
                        .fullWidth()
                    }
                }
        }
        // Destructive Modal
        .pModal(isPresented: $showDestructiveModal, overlay: .dimmedBlur(opacity: 0.05, radius: 0.5)) {
            PModalContent("Remove Contact")
                .description("If you remove this contact, it will no longer be in your address book. You can always add it again later.")
                .icon("exclamationmark.circle")
                .variant(.success)
                .onClose { showDestructiveModal = false }
                .actions {
                    HStack(spacing: 12) {
                        PButton("Cancel") {
                            showDestructiveModal = false
                        }
                        .variant(.secondary)
                        .fullWidth()
                        .size(.md)
                        
                        PButton("Remove") {
                            showDestructiveModal = false
                        }
                        .variant(.primary)
                        .background(.green)
                        .fullWidth()
                        .size(.md)
                    }
                }
        }
        // Success Modal
        .pModal(isPresented: $showSuccessModal, position: .bottom) {
            PModalContent("Transaction Complete")
                .description("Your payment of $50.00 has been successfully processed.")
                .icon("checkmark.circle")
                .variant(.success)
                .showCloseButton(false)
                .onClose { showSuccessModal = false }
                .actions {
                    HStack {
                        PButton("Done") {
                            showSuccessModal = false
                        }
                        .variant(.primary)
                        .fullWidth()
                        
                        PButton("Done") {
                            showSuccessModal = false
                        }
                        .variant(.primary)
                        .fullWidth()
                    }
                }
        }
    
        // Custom Content Modal
        .pModal(isPresented: $showCustomModal, position: .bottom, bottomPadding: 100) {
            VStack(spacing: 20) {
                Image(systemName: "star.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                
                Text("Rate Our App")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("If you enjoy using our app, please take a moment to rate it.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.vertical, 10)
                
                PButton("Submit Rating") {
                    showCustomModal = false
                }
                .variant(.primary)
                .fullWidth()
                
                Button("Maybe Later") {
                    showCustomModal = false
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 32, x: 0, y: 12)
        }
        // Alert-Style Modal
        .pModalAlert(
            isPresented: $showAlertModal,
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            icon: "trash.circle",
            variant: .standard,
            primaryButton: .destructive("Delete") {
                showAlertModal = false
            }
            ,
            secondaryButton: .cancel("Keep Account") {
                showAlertModal = false
            }
        )
    }
}
#endif

