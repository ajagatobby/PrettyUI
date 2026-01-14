//
//  PCard.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired card component with interactive states.
//

import SwiftUI

// MARK: - Card Variant

/// Card style variants
public enum PCardVariant: String, Equatable, Sendable, CaseIterable {
    /// Standard card with subtle shadow
    case standard
    /// Elevated card with larger shadow for floating appearance
    case elevated
    /// Flat card with no shadow, just border
    case flat
}

// MARK: - PCard

/// A customizable card component that uses PrettyUI theme tokens
///
/// Basic usage:
/// ```swift
/// PCard {
///     Text("Card Content")
/// }
/// ```
///
/// Custom padding (horizontal and vertical):
/// ```swift
/// PCard {
///     Text("Content")
/// }
/// .padding(horizontal: .xl, vertical: .sm)
///
/// // Or use individual modifiers:
/// .paddingHorizontal(.xl)
/// .paddingVertical(.sm)
/// ```
///
/// Pressable card (Family-style wallet card):
/// ```swift
/// PCard {
///     Text("Tap me!")
/// }
/// .pressable {
///     print("Card tapped")
/// }
/// ```
///
/// Elevated card:
/// ```swift
/// PCard {
///     Text("Floating content")
/// }
/// .variant(.elevated)
/// ```
///
/// Selected state:
/// ```swift
/// PCard {
///     Text("Selected card")
/// }
/// .selected(isSelected)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PCard<Content: View, Header: View, Footer: View>: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - State
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    // MARK: - Properties
    
    private let radius: RadiusSize?
    private let shadow: ShadowSize?
    private let padding: SpacingSize?
    private let paddingHorizontal: SpacingSize?
    private let paddingVertical: SpacingSize?
    private let showBorder: Bool?
    private let content: Content
    private let header: Header?
    private let footer: Footer?
    
    // Interactive properties
    private var variant: PCardVariant = .standard
    private var isPressable: Bool = false
    private var isSelected: Bool = false
    private var selectedBorderColor: Color? = nil
    private var action: (() -> Void)? = nil
    
    // MARK: - Computed Properties
    
    private var config: CardConfig {
        theme.components.card
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var resolvedRadius: CGFloat {
        theme.radius[radius ?? config.radius]
    }
    
    private var resolvedShadow: ShadowStyle {
        switch variant {
        case .standard:
            return theme.shadows[shadow ?? config.shadow]
        case .elevated:
            return theme.shadows[shadow ?? .lg]
        case .flat:
            return theme.shadows.none
        }
    }
    
    private var resolvedPadding: CGFloat {
        theme.spacing[padding ?? config.padding]
    }
    
    private var resolvedHorizontalPadding: CGFloat {
        if let h = paddingHorizontal {
            return theme.spacing[h]
        }
        return resolvedPadding
    }
    
    private var resolvedVerticalPadding: CGFloat {
        if let v = paddingVertical {
            return theme.spacing[v]
        }
        return resolvedPadding
    }
    
    private var resolvedShowBorder: Bool {
        if isSelected { return true }
        if variant == .flat { return true }
        return showBorder ?? config.showBorder
    }
    
    private var borderColor: Color {
        if isSelected {
            return selectedBorderColor ?? colors.primary
        }
        return colors.border
    }
    
    private var borderWidth: CGFloat {
        if isSelected { return 2 }
        return config.borderWidth
    }
    
    // MARK: - Animation
    
    private var pressAnimation: Animation? {
        reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.7, blendDuration: 0)
    }
    
    private var scaleEffect: CGFloat {
        guard isPressable && !reduceMotion else { return 1 }
        return isPressed ? 0.97 : 1.0
    }
    
    // MARK: - Initializers
    
    /// Create a card with content, optional header, and optional footer
    public init(
        radius: RadiusSize? = nil,
        shadow: ShadowSize? = nil,
        padding: SpacingSize? = nil,
        paddingHorizontal: SpacingSize? = nil,
        paddingVertical: SpacingSize? = nil,
        showBorder: Bool? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.radius = radius
        self.shadow = shadow
        self.padding = padding
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.showBorder = showBorder
        self.content = content()
        self.header = header()
        self.footer = footer()
    }
    
    // Private init for modifiers
    private init(
        radius: RadiusSize?,
        shadow: ShadowSize?,
        padding: SpacingSize?,
        paddingHorizontal: SpacingSize?,
        paddingVertical: SpacingSize?,
        showBorder: Bool?,
        content: Content,
        header: Header?,
        footer: Footer?,
        variant: PCardVariant,
        isPressable: Bool,
        isSelected: Bool,
        selectedBorderColor: Color?,
        action: (() -> Void)?
    ) {
        self.radius = radius
        self.shadow = shadow
        self.padding = padding
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.showBorder = showBorder
        self.content = content
        self.header = header
        self.footer = footer
        self.variant = variant
        self.isPressable = isPressable
        self.isSelected = isSelected
        self.selectedBorderColor = selectedBorderColor
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        cardContent
            .scaleEffect(scaleEffect)
            .animation(pressAnimation, value: isPressed)
            .if(isPressable) { view in
                view.simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isPressed { isPressed = true }
                        }
                        .onEnded { _ in
                            isPressed = false
                            action?()
                        }
                )
            }
            #if os(macOS)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
            #endif
    }
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            if let header = header {
                header
                    .padding(.horizontal, resolvedHorizontalPadding)
                    .padding(.top, resolvedVerticalPadding)
                    .padding(.bottom, theme.spacing.sm)
            }
            
            // Content
            content
                .padding(.horizontal, resolvedHorizontalPadding)
                .padding(.vertical, header == nil && footer == nil ? resolvedVerticalPadding : theme.spacing.sm)
            
            // Footer
            if let footer = footer {
                Divider()
                    .padding(.horizontal, resolvedHorizontalPadding)
                
                footer
                    .padding(.horizontal, resolvedHorizontalPadding)
                    .padding(.top, theme.spacing.sm)
                    .padding(.bottom, resolvedVerticalPadding)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: resolvedRadius))
        .overlay(
            RoundedRectangle(cornerRadius: resolvedRadius)
                .stroke(borderColor, lineWidth: resolvedShowBorder ? borderWidth : 0)
        )
        .prettyShadow(resolvedShadow)
        .brightness(isHovered && isPressable ? 0.02 : 0)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        if isPressed && isPressable {
            colors.card.opacity(0.95)
        } else {
            colors.card
        }
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PCard {
    
    /// Set the card variant (standard, elevated, flat)
    public func variant(_ variant: PCardVariant) -> PCard {
        PCard(
            radius: radius,
            shadow: shadow,
            padding: padding,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            showBorder: showBorder,
            content: content,
            header: header,
            footer: footer,
            variant: variant,
            isPressable: isPressable,
            isSelected: isSelected,
            selectedBorderColor: selectedBorderColor,
            action: action
        )
    }
    
    /// Make the card pressable with a tap action
    public func pressable(_ action: @escaping () -> Void = {}) -> PCard {
        PCard(
            radius: radius,
            shadow: shadow,
            padding: padding,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            showBorder: showBorder,
            content: content,
            header: header,
            footer: footer,
            variant: variant,
            isPressable: true,
            isSelected: isSelected,
            selectedBorderColor: selectedBorderColor,
            action: action
        )
    }
    
    /// Set the selected state with optional custom border color
    public func selected(_ isSelected: Bool, borderColor: Color? = nil) -> PCard {
        PCard(
            radius: radius,
            shadow: shadow,
            padding: padding,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: paddingVertical,
            showBorder: showBorder,
            content: content,
            header: header,
            footer: footer,
            variant: variant,
            isPressable: isPressable,
            isSelected: isSelected,
            selectedBorderColor: borderColor,
            action: action
        )
    }
    
    /// Set horizontal padding
    public func paddingHorizontal(_ padding: SpacingSize) -> PCard {
        PCard(
            radius: radius,
            shadow: shadow,
            padding: self.padding,
            paddingHorizontal: padding,
            paddingVertical: paddingVertical,
            showBorder: showBorder,
            content: content,
            header: header,
            footer: footer,
            variant: variant,
            isPressable: isPressable,
            isSelected: isSelected,
            selectedBorderColor: selectedBorderColor,
            action: action
        )
    }
    
    /// Set vertical padding
    public func paddingVertical(_ padding: SpacingSize) -> PCard {
        PCard(
            radius: radius,
            shadow: shadow,
            padding: self.padding,
            paddingHorizontal: paddingHorizontal,
            paddingVertical: padding,
            showBorder: showBorder,
            content: content,
            header: header,
            footer: footer,
            variant: variant,
            isPressable: isPressable,
            isSelected: isSelected,
            selectedBorderColor: selectedBorderColor,
            action: action
        )
    }
    
    /// Set both horizontal and vertical padding separately
    public func padding(horizontal: SpacingSize, vertical: SpacingSize) -> PCard {
        PCard(
            radius: radius,
            shadow: shadow,
            padding: self.padding,
            paddingHorizontal: horizontal,
            paddingVertical: vertical,
            showBorder: showBorder,
            content: content,
            header: header,
            footer: footer,
            variant: variant,
            isPressable: isPressable,
            isSelected: isSelected,
            selectedBorderColor: selectedBorderColor,
            action: action
        )
    }
}

// MARK: - Convenience Initializers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PCard where Header == EmptyView, Footer == EmptyView {
    /// Create a card with only content
    public init(
        radius: RadiusSize? = nil,
        shadow: ShadowSize? = nil,
        padding: SpacingSize? = nil,
        paddingHorizontal: SpacingSize? = nil,
        paddingVertical: SpacingSize? = nil,
        showBorder: Bool? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.radius = radius
        self.shadow = shadow
        self.padding = padding
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.showBorder = showBorder
        self.content = content()
        self.header = nil
        self.footer = nil
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PCard where Footer == EmptyView {
    /// Create a card with content and header
    public init(
        radius: RadiusSize? = nil,
        shadow: ShadowSize? = nil,
        padding: SpacingSize? = nil,
        paddingHorizontal: SpacingSize? = nil,
        paddingVertical: SpacingSize? = nil,
        showBorder: Bool? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) {
        self.radius = radius
        self.shadow = shadow
        self.padding = padding
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.showBorder = showBorder
        self.content = content()
        self.header = header()
        self.footer = nil
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PCard where Header == EmptyView {
    /// Create a card with content and footer
    public init(
        radius: RadiusSize? = nil,
        shadow: ShadowSize? = nil,
        padding: SpacingSize? = nil,
        paddingHorizontal: SpacingSize? = nil,
        paddingVertical: SpacingSize? = nil,
        showBorder: Bool? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.radius = radius
        self.shadow = shadow
        self.padding = padding
        self.paddingHorizontal = paddingHorizontal
        self.paddingVertical = paddingVertical
        self.showBorder = showBorder
        self.content = content()
        self.header = nil
        self.footer = footer()
    }
}

// MARK: - View Extension for Conditional Modifier

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Apply a modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Card Header Component

/// A styled header for use within PCard
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PCardHeader<Content: View>: View {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .font(.system(size: theme.typography.sizes.lg, weight: .semibold))
            .foregroundColor(theme.colors(for: colorScheme).cardForeground)
    }
}

/// A styled title and description for card headers
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PCardTitle: View {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let title: String
    private let description: String?
    
    public init(_ title: String, description: String? = nil) {
        self.title = title
        self.description = description
    }
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(.system(size: theme.typography.sizes.lg, weight: .semibold))
                .foregroundColor(colors.cardForeground)
            
            if let description = description {
                Text(description)
                    .font(.system(size: theme.typography.sizes.sm))
                    .foregroundColor(colors.mutedForeground)
            }
        }
    }
}

// MARK: - Card Footer Component

/// A styled footer for use within PCard
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PCardFooter<Content: View>: View {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        HStack {
            content
        }
        .font(.system(size: theme.typography.sizes.sm))
        .foregroundColor(theme.colors(for: colorScheme).mutedForeground)
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Basic card
                PCard {
                    Text("This is a basic card with some content.")
                }
                
                // Pressable card (Family-style)
                PCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Main Wallet")
                                .font(.headline)
                            Text("0x1234...5678")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("$10,234.56")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .pressable {
                    print("Wallet card tapped")
                }
                
                // Elevated card
                PCard {
                    Text("Elevated card with larger shadow")
                }
                .variant(.elevated)
                
                // Selected card
                PCard {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Selected option")
                    }
                }
                .selected(true)
                
                // Flat card
                PCard {
                    Text("Flat card with border only")
                }
                .variant(.flat)
                
                // Card with header
                PCard {
                    Text("Card content goes here. This can be any view.")
                } header: {
                    PCardTitle("Card Title", description: "This is a description")
                }
                
                // Card with header and footer
                PCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("john@example.com")
                    }
                } header: {
                    PCardTitle("Account Settings")
                } footer: {
                    HStack {
                        Spacer()
                        PButton("Cancel") {}
                            .variant(.ghost)
                            .size(.md)
                        PButton("Save") {}
                            .variant(.primary)
                            .size(.md)
                    }
                }
            }
            .padding()
        }
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode - Sky Theme")
        
        ScrollView {
            VStack(spacing: 24) {
                PCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Main Wallet")
                                .font(.headline)
                            Text("0x1234...5678")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("$1,234.56")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .pressable {}
                .variant(.elevated)
                
                PCard {
                    Text("Dark mode card")
                } header: {
                    PCardTitle("Dark Theme", description: "Using Family theme")
                }
            }
            .padding()
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode - Sky Theme")
    }
}
#endif


