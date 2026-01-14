//
//  PToast.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired toast notification component with fluid spring animations.
//  Displays ephemeral notifications with auto-dismiss, swipe gestures, and queue management.
//

import SwiftUI

// MARK: - Toast Variant

/// Visual variants for PToast
public enum PToastVariant: String, Equatable, Sendable, CaseIterable {
    /// Informational toast (blue)
    case info
    /// Success toast (green)
    case success
    /// Warning toast (orange/yellow)
    case warning
    /// Error/destructive toast (red)
    case error
}

// MARK: - Toast Position

/// Position options for PToast
public enum PToastPosition: String, Equatable, Sendable, CaseIterable {
    /// Displayed at the top of the screen
    case top
    /// Displayed at the bottom of the screen
    case bottom
}

// MARK: - Toast Item Model

/// Represents a single toast notification in the queue
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PToastItem: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public var description: String?
    public var icon: String?
    public var variant: PToastVariant
    public var duration: TimeInterval?
    public var showProgress: Bool
    public var dismissOnTap: Bool
    public var action: ToastAction?
    
    /// Action button configuration for toast
    public struct ToastAction: Equatable, Sendable {
        public let title: String
        public let actionID: UUID
        
        public init(title: String, actionID: UUID = UUID()) {
            self.title = title
            self.actionID = actionID
        }
        
        public static func == (lhs: ToastAction, rhs: ToastAction) -> Bool {
            lhs.actionID == rhs.actionID && lhs.title == rhs.title
        }
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        icon: String? = nil,
        variant: PToastVariant = .info,
        duration: TimeInterval? = 3.0,
        showProgress: Bool = false,
        dismissOnTap: Bool = true,
        action: ToastAction? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.variant = variant
        self.duration = duration
        self.showProgress = showProgress
        self.dismissOnTap = dismissOnTap
        self.action = action
    }
}

// MARK: - Toast Configuration

/// Configuration for toast styling and behavior
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PToastConfiguration {
    public var variant: PToastVariant = .info
    public var position: PToastPosition = .top
    public var duration: TimeInterval? = 3.0
    public var showProgress: Bool = false
    public var dismissOnTap: Bool = true
    public var icon: String? = nil
    public var description: String? = nil
    public var hapticFeedback: Bool = true
    public var actionTitle: String? = nil
    public var action: (() -> Void)? = nil
    public var radius: RadiusSize = .xl
    public var maxWidth: CGFloat = 400
    
    public init() {}
}

// MARK: - Toast Manager

/// Observable object that manages the toast queue
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
public final class PToastManager: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var toasts: [PToastItem] = []
    @Published public var position: PToastPosition = .top
    
    // MARK: - Private Properties
    
    private var dismissTasks: [UUID: Task<Void, Never>] = [:]
    private var actionHandlers: [UUID: () -> Void] = [:]
    
    // MARK: - Initializer
    
    public init(position: PToastPosition = .top) {
        self.position = position
    }
    
    // MARK: - Public Methods
    
    /// Show a simple toast with a title
    public func show(
        _ title: String,
        variant: PToastVariant = .info,
        duration: TimeInterval? = 3.0
    ) {
        let toast = PToastItem(
            title: title,
            variant: variant,
            duration: duration
        )
        addToast(toast)
    }
    
    /// Show a toast with full configuration
    public func show(
        _ title: String,
        description: String? = nil,
        icon: String? = nil,
        variant: PToastVariant = .info,
        duration: TimeInterval? = 3.0,
        showProgress: Bool = false,
        dismissOnTap: Bool = true,
        action: (title: String, handler: () -> Void)? = nil
    ) {
        var toastAction: PToastItem.ToastAction? = nil
        if let action = action {
            let actionID = UUID()
            toastAction = PToastItem.ToastAction(title: action.title, actionID: actionID)
            actionHandlers[actionID] = action.handler
        }
        
        let toast = PToastItem(
            title: title,
            description: description,
            icon: icon,
            variant: variant,
            duration: duration,
            showProgress: showProgress,
            dismissOnTap: dismissOnTap,
            action: toastAction
        )
        addToast(toast)
    }
    
    /// Show a pre-configured toast item
    public func show(_ toast: PToastItem) {
        addToast(toast)
    }
    
    /// Dismiss a specific toast
    public func dismiss(_ toast: PToastItem) {
        dismissToast(id: toast.id)
    }
    
    /// Dismiss toast by ID
    public func dismiss(id: UUID) {
        dismissToast(id: id)
    }
    
    /// Dismiss all toasts
    public func dismissAll() {
        for task in dismissTasks.values {
            task.cancel()
        }
        dismissTasks.removeAll()
        actionHandlers.removeAll()
        toasts.removeAll()
    }
    
    /// Execute action for toast
    func executeAction(for toast: PToastItem) {
        if let action = toast.action, let handler = actionHandlers[action.actionID] {
            handler()
        }
    }
    
    // MARK: - Private Methods
    
    private func addToast(_ toast: PToastItem) {
        toasts.append(toast)
        
        // Schedule auto-dismiss if duration is set
        if let duration = toast.duration {
            let task = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                if !Task.isCancelled {
                    dismissToast(id: toast.id)
                }
            }
            dismissTasks[toast.id] = task
        }
        
        // Haptic feedback
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
    
    private func dismissToast(id: UUID) {
        dismissTasks[id]?.cancel()
        dismissTasks.removeValue(forKey: id)
        
        // Find and remove action handler
        if let toast = toasts.first(where: { $0.id == id }), let action = toast.action {
            actionHandlers.removeValue(forKey: action.actionID)
        }
        
        toasts.removeAll { $0.id == id }
    }
}

// MARK: - Toast Container Modifier

/// A view modifier that overlays the toast container
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PToastContainerModifier: ViewModifier {
    
    @ObservedObject var manager: PToastManager
    
    public func body(content: Content) -> some View {
        content
            .overlay(alignment: manager.position == .top ? .top : .bottom) {
                PToastOverlay(manager: manager)
            }
    }
}

// MARK: - Toast Overlay

/// The overlay that displays and manages toast views
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct PToastOverlay: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    @ObservedObject var manager: PToastManager
    
    // MARK: - Computed Properties
    
    private var entryAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(manager.toasts) { toast in
                PToastItemView(
                    toast: toast,
                    position: manager.position,
                    onDismiss: {
                        withAnimation(entryAnimation) {
                            manager.dismiss(toast)
                        }
                    },
                    onAction: {
                        manager.executeAction(for: toast)
                        withAnimation(entryAnimation) {
                            manager.dismiss(toast)
                        }
                    }
                )
                .transition(toastTransition)
            }
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(manager.position == .top ? .top : .bottom, theme.spacing.md)
        .animation(entryAnimation, value: manager.toasts.map(\.id))
    }
    
    // MARK: - Transition
    
    private var toastTransition: AnyTransition {
        let edge: Edge = manager.position == .top ? .top : .bottom
        
        return .asymmetric(
            insertion: .move(edge: edge)
                .combined(with: .scale(scale: 0.9, anchor: manager.position == .top ? .top : .bottom))
                .combined(with: .opacity),
            removal: .move(edge: edge)
                .combined(with: .opacity)
        )
    }
}

// MARK: - Toast Item View

/// The visual representation of a single toast
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct PToastItemView: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    let toast: PToastItem
    let position: PToastPosition
    let onDismiss: () -> Void
    let onAction: () -> Void
    
    // MARK: - State
    
    @State private var dragOffset: CGFloat = 0
    @State private var progress: CGFloat = 1.0
    
    // MARK: - Constants
    
    private let dismissThreshold: CGFloat = 60
    private let dragResistance: CGFloat = 0.3
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var toastConfig: ToastConfig {
        theme.components.toast
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[toastConfig.radius]
    }
    
    private var variantColor: Color {
        switch toast.variant {
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
    
    private var iconName: String {
        if let customIcon = toast.icon {
            return customIcon
        }
        
        switch toast.variant {
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
    
    private var snapBackAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }
    
    // MARK: - Body
    
    var body: some View {
        toastContent
            .offset(y: dragOffset)
            .gesture(dragGesture)
            .onTapGesture {
                if toast.dismissOnTap {
                    onDismiss()
                }
            }
            .onAppear {
                startProgressTimer()
            }
    }
    
    // MARK: - Toast Content
    
    @ViewBuilder
    private var toastContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(variantColor)
                
                // Content
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(toast.title)
                        .font(.system(size: theme.typography.sizes.base, weight: .semibold))
                        .foregroundColor(colors.foreground)
                        .lineLimit(2)
                    
                    if let description = toast.description {
                        Text(description)
                            .font(.system(size: theme.typography.sizes.sm))
                            .foregroundColor(colors.mutedForeground)
                            .lineLimit(2)
                    }
                }
                
                Spacer(minLength: 0)
                
                // Action button
                if let action = toast.action {
                    Button(action: onAction) {
                        Text(action.title)
                            .font(.system(size: theme.typography.sizes.sm, weight: .semibold))
                            .foregroundColor(variantColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Close button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(colors.muted.opacity(0.5))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(theme.spacing.md)
            
            // Progress bar
            if toast.showProgress, toast.duration != nil {
                progressBar
            }
        }
        .frame(maxWidth: toastConfig.maxWidth)
        .background(colors.card)
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .stroke(colors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Progress Bar
    
    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(variantColor.opacity(0.15))
                
                // Progress fill
                Rectangle()
                    .fill(variantColor.opacity(0.8))
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 4)
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                
                // Determine if dragging in dismiss direction
                let isDismissDirection: Bool
                switch position {
                case .top:
                    isDismissDirection = translation < 0 // Dragging up
                case .bottom:
                    isDismissDirection = translation > 0 // Dragging down
                }
                
                if isDismissDirection {
                    dragOffset = translation
                } else {
                    dragOffset = translation * dragResistance
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                
                // Check if should dismiss based on position
                let shouldDismiss: Bool
                switch position {
                case .top:
                    shouldDismiss = translation < -dismissThreshold || velocity < -300
                case .bottom:
                    shouldDismiss = translation > dismissThreshold || velocity > 300
                }
                
                if shouldDismiss {
                    onDismiss()
                } else {
                    withAnimation(snapBackAnimation) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    // MARK: - Progress Timer
    
    private func startProgressTimer() {
        guard toast.showProgress, let duration = toast.duration else { return }
        
        progress = 1.0
        
        // Use a single smooth animation for the entire duration
        withAnimation(.linear(duration: duration)) {
            progress = 0.0
        }
    }
}

// MARK: - Simple Toast Modifier

/// A view modifier for presenting a single toast based on a binding
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PToastModifier<ToastContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    var position: PToastPosition
    @ViewBuilder var toastContent: () -> ToastContent
    
    @State private var internalManager = PToastManager()
    @State private var currentToastID: UUID?
    
    public func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    // Show toast
                    let id = UUID()
                    currentToastID = id
                    internalManager.position = position
                    // Content will be handled separately
                } else {
                    // Dismiss toast
                    if let id = currentToastID {
                        internalManager.dismiss(id: id)
                        currentToastID = nil
                    }
                }
            }
            .overlay(alignment: position == .top ? .top : .bottom) {
                if isPresented {
                    toastContent()
                        .onDisappear {
                            isPresented = false
                        }
                }
            }
    }
}

// MARK: - Toast Content Builder

/// A pre-styled toast content view with title, description, icon, and action
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PToastContent: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    private let title: String
    private var config: PToastConfiguration
    private var onDismiss: (() -> Void)?
    
    // MARK: - State
    
    @State private var dragOffset: CGFloat = 0
    @State private var progress: CGFloat = 1.0
    @State private var isVisible = true
    @State private var dismissTask: Task<Void, Never>?
    
    // MARK: - Constants
    
    private let dismissThreshold: CGFloat = 60
    private let dragResistance: CGFloat = 0.3
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var toastConfig: ToastConfig {
        theme.components.toast
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[config.radius]
    }
    
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
    
    private var iconName: String {
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
    
    private var entryAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.28, dampingFraction: 0.85, blendDuration: 0)
    }
    
    private var exitAnimation: Animation {
        reduceMotion
            ? .easeIn(duration: 0.1)
            : .easeIn(duration: 0.18)
    }
    
    private var snapBackAnimation: Animation {
        reduceMotion
            ? .easeOut(duration: 0.15)
            : .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)
    }
    
    // MARK: - Initializer
    
    public init(_ title: String) {
        self.title = title
        self.config = PToastConfiguration()
    }
    
    private init(title: String, config: PToastConfiguration, onDismiss: (() -> Void)?) {
        self.title = title
        self.config = config
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    public var body: some View {
        if isVisible {
            toastContent
                .offset(y: dragOffset)
                .gesture(dragGesture)
                .onTapGesture {
                    if config.dismissOnTap {
                        dismiss()
                    }
                }
                .onAppear {
                    startTimers()
                    triggerHaptic()
                }
                .onDisappear {
                    cancelTimers()
                }
                .transition(toastTransition)
        }
    }
    
    // MARK: - Toast Content
    
    @ViewBuilder
    private var toastContent: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.md) {
                // Icon
                Image(systemName: iconName)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(variantColor)
                
                // Content
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(title)
                        .font(.system(size: theme.typography.sizes.base, weight: .semibold))
                        .foregroundColor(colors.foreground)
                        .lineLimit(2)
                    
                    if let description = config.description {
                        Text(description)
                            .font(.system(size: theme.typography.sizes.sm))
                            .foregroundColor(colors.mutedForeground)
                            .lineLimit(2)
                    }
                }
                
                Spacer(minLength: 0)
                
                // Action button
                if let actionTitle = config.actionTitle {
                    Button {
                        config.action?()
                        dismiss()
                    } label: {
                        Text(actionTitle)
                            .font(.system(size: theme.typography.sizes.sm, weight: .semibold))
                            .foregroundColor(variantColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Close button
                Button(action: dismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(colors.mutedForeground)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(colors.muted.opacity(0.5))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(theme.spacing.md)
            
            // Progress bar
            if config.showProgress, config.duration != nil {
                contentProgressBar
            }
        }
        .frame(maxWidth: config.maxWidth)
        .background(colors.card)
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: resolvedRadius, style: .continuous)
                .stroke(colors.border.opacity(0.5), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.12),
            radius: 16,
            x: 0,
            y: 8
        )
        .padding(.horizontal, theme.spacing.md)
        .padding(config.position == .top ? .top : .bottom, theme.spacing.md)
    }
    
    // MARK: - Progress Bar
    
    @ViewBuilder
    private var contentProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(variantColor.opacity(0.15))
                
                // Progress fill
                Rectangle()
                    .fill(variantColor.opacity(0.8))
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 4)
    }
    
    // MARK: - Transition
    
    private var toastTransition: AnyTransition {
        let edge: Edge = config.position == .top ? .top : .bottom
        
        return .asymmetric(
            insertion: .move(edge: edge)
                .combined(with: .scale(scale: 0.9, anchor: config.position == .top ? .top : .bottom))
                .combined(with: .opacity),
            removal: .move(edge: edge)
                .combined(with: .opacity)
        )
    }
    
    // MARK: - Drag Gesture
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                
                let isDismissDirection: Bool
                switch config.position {
                case .top:
                    isDismissDirection = translation < 0
                case .bottom:
                    isDismissDirection = translation > 0
                }
                
                if isDismissDirection {
                    dragOffset = translation
                } else {
                    dragOffset = translation * dragResistance
                }
            }
            .onEnded { value in
                let translation = value.translation.height
                let velocity = value.predictedEndTranslation.height
                
                let shouldDismiss: Bool
                switch config.position {
                case .top:
                    shouldDismiss = translation < -dismissThreshold || velocity < -300
                case .bottom:
                    shouldDismiss = translation > dismissThreshold || velocity > 300
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
    
    // MARK: - Actions
    
    private func dismiss() {
        cancelTimers()
        withAnimation(exitAnimation) {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss?()
        }
    }
    
    private func startTimers() {
        // Auto-dismiss timer
        if let duration = config.duration {
            dismissTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                if !Task.isCancelled {
                    dismiss()
                }
            }
        }
        
        // Progress animation - single smooth animation for the entire duration
        if config.showProgress, let duration = config.duration {
            progress = 1.0
            withAnimation(.linear(duration: duration)) {
                progress = 0.0
            }
        }
    }
    
    private func cancelTimers() {
        dismissTask?.cancel()
    }
    
    private func triggerHaptic() {
        guard config.hapticFeedback else { return }
        #if os(iOS)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
}

// MARK: - Fluent Modifiers for PToastContent

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PToastContent {
    
    /// Set the toast variant
    func variant(_ variant: PToastVariant) -> PToastContent {
        var newConfig = config
        newConfig.variant = variant
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set the toast position
    func position(_ position: PToastPosition) -> PToastContent {
        var newConfig = config
        newConfig.position = position
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set the auto-dismiss duration (nil = manual dismiss only)
    func duration(_ duration: TimeInterval?) -> PToastContent {
        var newConfig = config
        newConfig.duration = duration
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Show or hide the progress bar
    func showProgress(_ show: Bool = true) -> PToastContent {
        var newConfig = config
        newConfig.showProgress = show
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set whether tapping dismisses the toast
    func dismissOnTap(_ dismiss: Bool = true) -> PToastContent {
        var newConfig = config
        newConfig.dismissOnTap = dismiss
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set a custom icon (SF Symbol name)
    func icon(_ systemName: String) -> PToastContent {
        var newConfig = config
        newConfig.icon = systemName
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set the description text
    func description(_ text: String?) -> PToastContent {
        var newConfig = config
        newConfig.description = text
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Enable or disable haptic feedback
    func haptics(_ enabled: Bool = true) -> PToastContent {
        var newConfig = config
        newConfig.hapticFeedback = enabled
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Add an action button
    func action(_ title: String, action: @escaping () -> Void) -> PToastContent {
        var newConfig = config
        newConfig.actionTitle = title
        newConfig.action = action
        return PToastContent(title: self.title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set the corner radius
    func radius(_ radius: RadiusSize) -> PToastContent {
        var newConfig = config
        newConfig.radius = radius
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set the maximum width
    func maxWidth(_ width: CGFloat) -> PToastContent {
        var newConfig = config
        newConfig.maxWidth = width
        return PToastContent(title: title, config: newConfig, onDismiss: onDismiss)
    }
    
    /// Set the dismiss callback
    func onDismiss(_ callback: @escaping () -> Void) -> PToastContent {
        PToastContent(title: title, config: config, onDismiss: callback)
    }
}

// MARK: - View Extensions

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Add a toast container that displays toasts from the manager
    ///
    /// ```swift
    /// @StateObject var toastManager = PToastManager()
    ///
    /// ContentView()
    ///     .pToastContainer(manager: toastManager)
    ///
    /// // Show toast
    /// toastManager.show("Success!", variant: .success)
    /// ```
    func pToastContainer(manager: PToastManager) -> some View {
        modifier(PToastContainerModifier(manager: manager))
    }
    
    /// Present a simple toast notification
    ///
    /// ```swift
    /// .pToast(
    ///     isPresented: $showToast,
    ///     title: "Copied to clipboard",
    ///     variant: .success
    /// )
    /// ```
    func pToast(
        isPresented: Binding<Bool>,
        title: String,
        description: String? = nil,
        icon: String? = nil,
        variant: PToastVariant = .info,
        position: PToastPosition = .top,
        duration: TimeInterval? = 3.0
    ) -> some View {
        self.overlay(alignment: position == .top ? .top : .bottom) {
            if isPresented.wrappedValue {
                PToastContent(title)
                    .description(description)
                    .icon(icon ?? "")
                    .variant(variant)
                    .position(position)
                    .duration(duration)
                    .onDismiss {
                        isPresented.wrappedValue = false
                    }
            }
        }
        .animation(
            .spring(response: 0.28, dampingFraction: 0.85),
            value: isPresented.wrappedValue
        )
    }
    
    /// Present a toast with custom content
    ///
    /// ```swift
    /// .pToast(isPresented: $showToast, position: .bottom) {
    ///     PToastContent("Transaction Complete")
    ///         .icon("checkmark.circle.fill")
    ///         .variant(.success)
    ///         .duration(4.0)
    /// }
    /// ```
    func pToast<Content: View>(
        isPresented: Binding<Bool>,
        position: PToastPosition = .top,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.overlay(alignment: position == .top ? .top : .bottom) {
            if isPresented.wrappedValue {
                content()
            }
        }
        .animation(
            .spring(response: 0.28, dampingFraction: 0.85),
            value: isPresented.wrappedValue
        )
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PToast_Previews: PreviewProvider {
    static var previews: some View {
        PToastPreviewContainer()
            .prettyTheme(.family)
            .previewDisplayName("Toast Demo")
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct PToastPreviewContainer: View {
    
    @StateObject private var toastManager = PToastManager()
    @State private var showSimpleToast = false
    @State private var showSuccessToast = false
    @State private var showErrorToast = false
    @State private var showProgressToast = false
    @State private var showBottomToast = false
    @State private var showActionToast = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Simple Toasts") {
                    Button("Info Toast") {
                        toastManager.show("This is an info message", variant: .info)
                    }
                    
                    Button("Success Toast") {
                        toastManager.show("Transaction completed!", variant: .success)
                    }
                    
                    Button("Warning Toast") {
                        toastManager.show("Check your connection", variant: .warning)
                    }
                    
                    Button("Error Toast") {
                        toastManager.show("Something went wrong", variant: .error)
                    }
                }
                
                Section("With Description") {
                    Button("Detailed Toast") {
                        toastManager.show(
                            "Wallet Connected",
                            description: "Your wallet is now ready to use.",
                            icon: "wallet.pass.fill",
                            variant: .success,
                            duration: 4.0
                        )
                    }
                }
                
                Section("With Progress") {
                    Button("Progress Toast") {
                        toastManager.show(
                            "Uploading file...",
                            description: "Please wait while we process your request.",
                            variant: .info,
                            duration: 5.0,
                            showProgress: true
                        )
                    }
                }
                
                Section("With Action") {
                    Button("Action Toast") {
                        toastManager.show(
                            "Message archived",
                            variant: .info,
                            duration: 5.0,
                            action: (title: "Undo", handler: {
                                toastManager.show("Restored!", variant: .success)
                            })
                        )
                    }
                }
                
                Section("Position") {
                    Button("Toggle Position") {
                        withAnimation {
                            toastManager.position = toastManager.position == .top ? .bottom : .top
                        }
                    }
                    
                    Text("Current: \(toastManager.position.rawValue)")
                        .foregroundColor(.secondary)
                }
                
                Section("Binding-Based") {
                    Button("Simple Binding Toast") {
                        showSimpleToast = true
                    }
                    
                    Button("Bottom Toast") {
                        showBottomToast = true
                    }
                }
                
                Section("Multiple Toasts") {
                    Button("Show 3 Toasts") {
                        toastManager.show("First toast", variant: .info)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            toastManager.show("Second toast", variant: .success)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            toastManager.show("Third toast", variant: .warning)
                        }
                    }
                    
                    Button("Dismiss All") {
                        toastManager.dismissAll()
                    }
                }
                
                Section("Usage") {
                    Text("""
                    // Manager-based
                    @StateObject var toast = PToastManager()
                    
                    view
                        .pToastContainer(manager: toast)
                    
                    toast.show("Message", variant: .success)
                    
                    // Binding-based
                    .pToast(isPresented: $show, title: "Success")
                    """)
                    .font(.system(.caption, design: .monospaced))
                }
            }
            .navigationTitle("PToast")
        }
        .pToastContainer(manager: toastManager)
        .pToast(
            isPresented: $showSimpleToast,
            title: "Hello from binding!",
            variant: .info
        )
        .pToast(
            isPresented: $showBottomToast,
            title: "Bottom toast!",
            variant: .success,
            position: .bottom
        )
    }
}

@available(iOS 16.0, macOS 13.0, *)
struct PToast_Dark_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PToastContent("Info Toast")
                .variant(.info)
            
            PToastContent("Success Toast")
                .variant(.success)
                .description("Your transaction was successful.")
            
            PToastContent("Warning Toast")
                .variant(.warning)
                .showProgress()
            
            PToastContent("Error Toast")
                .variant(.error)
                .action("Retry") {}
        }
        .padding()
        .background(Color(hex: "#0D0D0D"))
        .prettyTheme(.family)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode Variants")
    }
}
#endif

