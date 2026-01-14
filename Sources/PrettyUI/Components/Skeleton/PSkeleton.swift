//
//  PSkeleton.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired skeleton loader with shimmer animation.
//

import SwiftUI

// MARK: - Skeleton Shape

/// Shape options for skeleton loaders
public enum PSkeletonShape: Equatable, Sendable {
    /// Rectangle with specified corner radius
    case rectangle(RadiusSize)
    /// Circular shape
    case circle
    /// Capsule/pill shape
    case capsule
}

// MARK: - PSkeleton

/// A shimmer skeleton loader component inspired by Family.co
///
/// Basic usage:
/// ```swift
/// PSkeleton()
///     .frame(height: 20)
/// ```
///
/// Different shapes:
/// ```swift
/// PSkeleton(shape: .circle)
///     .frame(width: 48, height: 48)
///
/// PSkeleton(shape: .rectangle(.lg))
///     .frame(height: 100)
/// ```
///
/// Custom colors:
/// ```swift
/// PSkeleton()
///     .baseColor(.gray.opacity(0.2))
///     .highlightColor(.gray.opacity(0.4))
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSkeleton: View {
    
    // MARK: - Properties
    
    private let shape: PSkeletonShape
    private var baseColor: Color? = nil
    private var highlightColor: Color? = nil
    private var animationDuration: Double = 1.5
    
    // MARK: - Initializer
    
    /// Create a skeleton loader
    /// - Parameter shape: The shape of the skeleton (default: rectangle with medium radius)
    public init(shape: PSkeletonShape = .rectangle(.md)) {
        self.shape = shape
    }
    
    // Private init for modifiers
    private init(
        shape: PSkeletonShape,
        baseColor: Color?,
        highlightColor: Color?,
        animationDuration: Double
    ) {
        self.shape = shape
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.animationDuration = animationDuration
    }
    
    // MARK: - Body
    
    public var body: some View {
        // Delegate to PSkeletonView for proper shape clipping
        var view = PSkeletonView(shape: shape)
        if let base = baseColor {
            view = view.baseColor(base)
        }
        if let highlight = highlightColor {
            view = view.highlightColor(highlight)
        }
        return view.duration(animationDuration)
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PSkeleton {
    
    /// Set the base color
    public func baseColor(_ color: Color) -> PSkeleton {
        PSkeleton(
            shape: shape,
            baseColor: color,
            highlightColor: highlightColor,
            animationDuration: animationDuration
        )
    }
    
    /// Set the highlight color for shimmer
    public func highlightColor(_ color: Color) -> PSkeleton {
        PSkeleton(
            shape: shape,
            baseColor: baseColor,
            highlightColor: color,
            animationDuration: animationDuration
        )
    }
    
    /// Set the animation duration
    public func duration(_ duration: Double) -> PSkeleton {
        PSkeleton(
            shape: shape,
            baseColor: baseColor,
            highlightColor: highlightColor,
            animationDuration: duration
        )
    }
}

// MARK: - Reimplemented PSkeleton with proper clipping

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSkeletonView: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var isAnimating = false
    
    private let shape: PSkeletonShape
    private var baseColor: Color? = nil
    private var highlightColor: Color? = nil
    private var animationDuration: Double = 1.5
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var resolvedBaseColor: Color {
        baseColor ?? colors.muted
    }
    
    private var resolvedHighlightColor: Color {
        highlightColor ?? colors.card
    }
    
    public init(shape: PSkeletonShape = .rectangle(.md)) {
        self.shape = shape
    }
    
    private init(
        shape: PSkeletonShape,
        baseColor: Color?,
        highlightColor: Color?,
        animationDuration: Double
    ) {
        self.shape = shape
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.animationDuration = animationDuration
    }
    
    public var body: some View {
        GeometryReader { geometry in
            skeletonContent(width: geometry.size.width)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    @ViewBuilder
    private func skeletonContent(width: CGFloat) -> some View {
        let content = Group {
            if reduceMotion {
                resolvedBaseColor
                    .opacity(isAnimating ? 0.6 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            } else {
                resolvedBaseColor
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                resolvedHighlightColor.opacity(0),
                                resolvedHighlightColor.opacity(0.6),
                                resolvedHighlightColor.opacity(0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: width * 0.6)
                        .offset(x: isAnimating ? width * 1.5 : -width * 1.5)
                    )
                    .clipped()
                    .animation(
                        .linear(duration: animationDuration).repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
        }
        
        switch shape {
        case .rectangle(let radius):
            content.clipShape(RoundedRectangle(cornerRadius: theme.radius[radius]))
        case .circle:
            content.clipShape(Circle())
        case .capsule:
            content.clipShape(Capsule())
        }
    }
    
    public func baseColor(_ color: Color) -> PSkeletonView {
        PSkeletonView(
            shape: shape,
            baseColor: color,
            highlightColor: highlightColor,
            animationDuration: animationDuration
        )
    }
    
    public func highlightColor(_ color: Color) -> PSkeletonView {
        PSkeletonView(
            shape: shape,
            baseColor: baseColor,
            highlightColor: color,
            animationDuration: animationDuration
        )
    }
    
    public func duration(_ duration: Double) -> PSkeletonView {
        PSkeletonView(
            shape: shape,
            baseColor: baseColor,
            highlightColor: highlightColor,
            animationDuration: duration
        )
    }
}

// MARK: - PSkeletonText

/// A skeleton placeholder for text content
///
/// Usage:
/// ```swift
/// PSkeletonText(lines: 3)
/// PSkeletonText(lines: 2, lastLineWidth: 0.6)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSkeletonText: View {
    
    @Environment(\.prettyTheme) private var theme
    
    private let lines: Int
    private let lineHeight: CGFloat
    private let spacing: CGFloat
    private let lastLineWidth: CGFloat
    
    /// Create a text skeleton
    /// - Parameters:
    ///   - lines: Number of lines to display
    ///   - lineHeight: Height of each line (default: 14)
    ///   - spacing: Spacing between lines (default: 8)
    ///   - lastLineWidth: Width ratio of last line (0-1, default: 0.7)
    public init(
        lines: Int = 1,
        lineHeight: CGFloat = 14,
        spacing: CGFloat = 8,
        lastLineWidth: CGFloat = 0.7
    ) {
        self.lines = max(1, lines)
        self.lineHeight = lineHeight
        self.spacing = spacing
        self.lastLineWidth = min(1, max(0, lastLineWidth))
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<lines, id: \.self) { index in
                PSkeletonView(shape: .rectangle(.sm))
                    .frame(height: lineHeight)
                    .frame(maxWidth: index == lines - 1 && lines > 1 ? .infinity : .infinity, alignment: .leading)
                    .if(index == lines - 1 && lines > 1) { view in
                        GeometryReader { geometry in
                            view.frame(width: geometry.size.width * lastLineWidth)
                        }
                        .frame(height: lineHeight)
                    }
            }
        }
    }
}

// MARK: - PSkeletonAvatar

/// A circular skeleton placeholder for avatars
///
/// Usage:
/// ```swift
/// PSkeletonAvatar(size: 48)
/// PSkeletonAvatar(size: .lg) // Uses PAvatar sizes
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSkeletonAvatar: View {
    
    private let size: CGFloat
    
    /// Create an avatar skeleton with exact size
    public init(size: CGFloat = 40) {
        self.size = size
    }
    
    /// Create an avatar skeleton using PAvatar size tokens
    public init(size: PAvatarSize) {
        self.size = size.dimension
    }
    
    public var body: some View {
        PSkeletonView(shape: .circle)
            .frame(width: size, height: size)
    }
}

// Note: PAvatarSize is defined in PAvatar.swift

// MARK: - PSkeletonCard

/// A skeleton placeholder for card content
///
/// Usage:
/// ```swift
/// PSkeletonCard()
/// PSkeletonCard(showAvatar: true, lines: 2)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSkeletonCard: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let showAvatar: Bool
    private let lines: Int
    private let showImage: Bool
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Create a card skeleton
    /// - Parameters:
    ///   - showAvatar: Whether to show avatar placeholder
    ///   - lines: Number of text lines
    ///   - showImage: Whether to show image placeholder
    public init(showAvatar: Bool = false, lines: Int = 2, showImage: Bool = false) {
        self.showAvatar = showAvatar
        self.lines = lines
        self.showImage = showImage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            // Image placeholder
            if showImage {
                PSkeletonView(shape: .rectangle(.lg))
                    .frame(height: 160)
            }
            
            // Content
            HStack(alignment: .top, spacing: theme.spacing.md) {
                if showAvatar {
                    PSkeletonAvatar(size: 40)
                }
                
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    // Title
                    PSkeletonView(shape: .rectangle(.sm))
                        .frame(width: 140, height: 16)
                    
                    // Subtitle lines
                    PSkeletonText(lines: lines, lineHeight: 12)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(colors.card)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.xl))
    }
}

// MARK: - Skeleton Modifier

/// A view modifier that shows skeleton or actual content based on loading state
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SkeletonModifier<Placeholder: View>: ViewModifier {
    
    let isLoading: Bool
    let placeholder: Placeholder
    
    public func body(content: Content) -> some View {
        if isLoading {
            placeholder
        } else {
            content
        }
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    
    /// Show a skeleton placeholder while loading
    /// - Parameters:
    ///   - isLoading: Whether content is loading
    ///   - placeholder: The skeleton placeholder to show
    public func skeleton<Placeholder: View>(
        _ isLoading: Bool,
        @ViewBuilder placeholder: () -> Placeholder
    ) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, placeholder: placeholder()))
    }
    
    /// Show a default skeleton rectangle while loading
    public func skeleton(_ isLoading: Bool, shape: PSkeletonShape = .rectangle(.md)) -> some View {
        modifier(SkeletonModifier(isLoading: isLoading, placeholder: PSkeletonView(shape: shape)))
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PSkeleton_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Basic shapes
                Group {
                    Text("Shapes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        PSkeletonView(shape: .rectangle(.md))
                            .frame(width: 80, height: 80)
                        
                        PSkeletonView(shape: .circle)
                            .frame(width: 80, height: 80)
                        
                        PSkeletonView(shape: .capsule)
                            .frame(width: 120, height: 40)
                    }
                }
                
                Divider()
                
                // Text skeleton
                Group {
                    Text("Text Skeleton")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        PSkeletonText(lines: 1)
                        PSkeletonText(lines: 3)
                        PSkeletonText(lines: 2, lastLineWidth: 0.5)
                    }
                }
                
                Divider()
                
                // Avatar skeleton
                Group {
                    Text("Avatar Skeleton")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        PSkeletonAvatar(size: .xs)
                        PSkeletonAvatar(size: .sm)
                        PSkeletonAvatar(size: .md)
                        PSkeletonAvatar(size: .lg)
                        PSkeletonAvatar(size: .xl)
                    }
                }
                
                Divider()
                
                // Card skeleton
                Group {
                    Text("Card Skeleton")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PSkeletonCard(showAvatar: true, lines: 2)
                    
                    PSkeletonCard(showAvatar: false, lines: 3, showImage: true)
                }
                
                Divider()
                
                // List item skeleton
                Group {
                    Text("List Skeleton")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 0) {
                        ForEach(0..<3, id: \.self) { _ in
                            HStack(spacing: 12) {
                                PSkeletonAvatar(size: 40)
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    PSkeletonView(shape: .rectangle(.sm))
                                        .frame(width: 120, height: 14)
                                    PSkeletonView(shape: .rectangle(.sm))
                                        .frame(width: 80, height: 12)
                                }
                                
                                Spacer()
                                
                                PSkeletonView(shape: .rectangle(.sm))
                                    .frame(width: 60, height: 14)
                            }
                            .padding(.vertical, 12)
                            
                            Divider()
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(Color.white)
                    .cornerRadius(16)
                }
            }
            .padding()
        }
        .background(Color(hex: "#EEEEEE10"))
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode")
        
        ScrollView {
            VStack(spacing: 24) {
                PSkeletonCard(showAvatar: true, lines: 2)
                
                HStack(spacing: 12) {
                    PSkeletonAvatar(size: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        PSkeletonView(shape: .rectangle(.sm))
                            .frame(width: 100, height: 14)
                        PSkeletonView(shape: .rectangle(.sm))
                            .frame(width: 60, height: 12)
                    }
                }
            }
            .padding()
        }
        .prettyTheme(.sky)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif

