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

// MARK: - Configuration

/// Configuration for PExpandableFAB styling
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable, message: "PExpandableFAB is not available on macOS")
public struct PExpandableFABConfiguration {
    var size: CGFloat = 56
    var expandedCornerRadius: CGFloat = 30
    var animationDuration: CGFloat = 0.2
    var backdropOpacity: Double = 0.05
    var hapticFeedback: Bool = true
    var shadow: ShadowSize = .sm
    var expandedShadow: ShadowSize = .lg
    var horizontalPadding: CGFloat = 15
    var bottomPadding: CGFloat = 5
    
    // Uses theme foreground/background by default (nil = use theme)
    var customTint: Color? = nil
    var customIconColor: Color? = nil
}

// MARK: - PMorphingFAB

/// An expandable Floating Action Button that transforms from a circular button
/// into a menu and optionally into full-screen content.
///
/// Inspired by Family.co's elegant FAB animation pattern.
///
/// Usage:
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
/// Simple usage with just a menu:
/// ```swift
/// PExpandableFAB {
///     Image(systemName: "plus")
/// } menu: {
///     MenuContent()
/// }
/// ```
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
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
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var tintColor: Color {
        config.customTint ?? colors.foreground
    }
    
    private var iconColor: Color {
        config.customIconColor ?? colors.background
    }
    
    private var morphAnimation: Animation? {
        reduceMotion ? nil : .interpolatingSpring(duration: config.animationDuration, bounce: 0)
    }
    
    private var shadowStyle: ShadowStyle {
        theme.shadows[config.shadow]
    }
    
    private var expandedShadowStyle: ShadowStyle {
        theme.shadows[config.expandedShadow]
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
            .foregroundStyle(iconColor)
            .frame(width: config.size, height: config.size)
            .background(tintColor)
            .clipShape(.circle)
            .contentShape(.circle)
            .prettyShadow(shadowStyle)
            .onGeometryChange(for: CGRect.self, of: {
                $0.frame(in: .global)
            }, action: { newValue in
                viewPosition = newValue
            })
            .opacity(showFullScreenCover ? 0 : 1)
            .onTapGesture {
                triggerHaptic()
                toggleFullScreenCover(withAnimation: false, status: true)
            }
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
                            .transition(.blurReplace)
                    } else {
                        menu
                            .transition(.blurReplace)
                    }
                }
                .transition(.blurReplace)
            } else {
                label
                    .foregroundStyle(iconColor)
                    .frame(width: config.size, height: config.size)
                    .transition(.blurReplace)
            }
        }
        .geometryGroup()
        .clipShape(.rect(cornerRadius: config.expandedCornerRadius, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: config.expandedCornerRadius, style: .continuous)
                .fill(tintColor)
                .prettyShadow(animateContent ? expandedShadowStyle : shadowStyle)
                .ignoresSafeArea(isExpanded ? .all : [])
        }
        .padding(.horizontal, animateContent && !isExpanded ? config.horizontalPadding : 0)
        .padding(.bottom, animateContent && !isExpanded ? config.bottomPadding : 0)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: animateContent ? .bottom : .topLeading
        )
        .offset(
            x: animateContent ? 0 : viewPosition.minX,
            y: animateContent ? 0 : viewPosition.minY
        )
        .ignoresSafeArea(animateContent ? [] : .all)
        .background {
            Rectangle()
                .fill(.black.opacity(animateContent ? config.backdropOpacity : 0))
                .ignoresSafeArea()
                .contentShape(.rect)
                .onTapGesture {
                    dismissWithAnimation()
                }
        }
        .task {
            try? await Task.sleep(for: .seconds(0.06))
            withAnimation(morphAnimation) {
                animateContent = true
            }
        }
        .animation(morphAnimation, value: isExpanded)
        .presentationBackground(.clear)
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
        withAnimation(morphAnimation, completionCriteria: .removed) {
            animateContent = false
        } completion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                toggleFullScreenCover(withAnimation: false, status: false)
            }
        }
    }
    
    private func triggerHaptic() {
        #if os(iOS)
        if config.hapticFeedback {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
        #endif
    }
}

// MARK: - Fluent Modifiers

@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
public extension PExpandableFAB {
    
    /// Set the FAB size (width and height)
    func size(_ size: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.size = size
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the corner radius when expanded
    func cornerRadius(_ radius: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.expandedCornerRadius = radius
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the animation duration
    func duration(_ duration: CGFloat) -> PExpandableFAB {
        var newConfig = config
        newConfig.animationDuration = duration
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the backdrop opacity when expanded
    func backdrop(_ opacity: Double) -> PExpandableFAB {
        var newConfig = config
        newConfig.backdropOpacity = opacity
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Enable or disable haptic feedback
    func haptics(_ enabled: Bool) -> PExpandableFAB {
        var newConfig = config
        newConfig.hapticFeedback = enabled
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the FAB tint (background) color
    func tint(_ color: Color) -> PExpandableFAB {
        var newConfig = config
        newConfig.customTint = color
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
    /// Set the icon color
    func iconColor(_ color: Color) -> PExpandableFAB {
        var newConfig = config
        newConfig.customIconColor = color
        return PExpandableFAB(isExpanded: $isExpanded, label: label, menu: menu, detail: detail, config: newConfig)
    }
    
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
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable, message: "PFABMenuItem is not available on macOS")
public struct PFABMenuItem: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let icon: String
    private let title: String
    private let description: String?
    private let showChevron: Bool
    private let action: () -> Void
    
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
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(colors.background, in: .circle)
                    .foregroundStyle(colors.foreground)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(colors.background)
                        .fontWeight(.semibold)
                    
                    if let description {
                        Text(description)
                            .font(.caption)
                            .foregroundStyle(colors.mutedForeground)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(colors.mutedForeground)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Convenience Initializer (No Detail View)

@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
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
@available(iOS 17.0, *)
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

@available(iOS 17.0, *)
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
                
                Section("Menu Only") {
                    Text(
                        """
                        **PExpandableFAB {**
                           Image(systemName: "plus")
                        **} menu: {**
                           MenuContent()
                        **}**
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
                                .foregroundStyle(colors.mutedForeground)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    VStack(spacing: 16) {
                        Image(systemName: selectedItem == "Send" ? "paperplane.circle.fill" :
                                selectedItem == "Swap" ? "arrow.trianglehead.2.counterclockwise.circle.fill" :
                                selectedItem == "Receive" ? "arrow.down.circle.fill" : "qrcode.viewfinder")
                            .font(.system(size: 64))
                            .foregroundStyle(colors.primary)
                            .padding(.top, 40)
                        
                        Text("This is the \(selectedItem) view")
                            .font(.headline)
                        
                        Text("Here you would see the full interface for the \(selectedItem.lowercased()) action.")
                            .font(.subheadline)
                            .foregroundStyle(colors.mutedForeground)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer()
                        
                        Button {
                            isExpanded = false
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .foregroundStyle(colors.primaryForeground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(colors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .foregroundStyle(colors.background)
            }
            .padding(15)
        }
    }
}
#endif

