//
//  PAvatar.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired avatar component with multiple sources and styles.
//

import SwiftUI

// MARK: - Avatar Size

/// Size options for avatars
public enum PAvatarSize: String, Equatable, Sendable, CaseIterable {
    case xs, sm, md, lg, xl
    
    /// The dimension (width/height) for this size
    public var dimension: CGFloat {
        switch self {
        case .xs: return 24
        case .sm: return 32
        case .md: return 40
        case .lg: return 56
        case .xl: return 72
        }
    }
}

// MARK: - Avatar Shape

/// Shape options for avatars
public enum PAvatarShape: String, Equatable, Sendable, CaseIterable {
    /// Circular avatar
    case circle
    /// Rounded square avatar
    case rounded
}

// MARK: - Avatar Status

/// Status indicator for avatars
public enum PAvatarStatus: Equatable, Sendable {
    /// Online status (green dot)
    case online
    /// Offline status (gray dot)
    case offline
    /// Away status (yellow dot)
    case away
    /// Do not disturb (red dot)
    case dnd
    /// Custom status with color
    case custom(Color)
    /// No status indicator
    case none
}

// MARK: - PAvatar

/// A versatile avatar component inspired by Family.co
///
/// Basic usage with URL string (simplest):
/// ```swift
/// PAvatar("https://pbs.twimg.com/profile_images/123/avatar.jpg")
/// ```
///
/// With URL and name fallback:
/// ```swift
/// PAvatar("https://example.com/avatar.jpg", name: "John Doe")
/// ```
///
/// With initials only:
/// ```swift
/// PAvatar(name: "John Doe")
/// ```
///
/// With local image:
/// ```swift
/// PAvatar(image: Image("profile"))
/// ```
///
/// With size and status:
/// ```swift
/// PAvatar("https://example.com/avatar.jpg")
///     .size(.lg)
///     .status(.online)
/// ```
///
/// With badge:
/// ```swift
/// PAvatar(name: "User")
///     .badge(count: 5)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PAvatar: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Properties
    
    private let url: URL?
    private let image: Image?
    private let name: String?
    private let placeholder: String?
    
    // Configuration
    private var avatarSize: PAvatarSize = .md
    private var shape: PAvatarShape = .circle
    private var status: PAvatarStatus = .none
    private var showBorder: Bool = false
    private var borderColor: Color? = nil
    private var borderWidth: CGFloat = 2
    private var backgroundColor: Color? = nil
    private var foregroundColor: Color? = nil
    private var badgeCount: Int? = nil
    private var badgeColor: Color? = nil
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var dimension: CGFloat {
        avatarSize.dimension
    }
    
    private var fontSize: CGFloat {
        switch avatarSize {
        case .xs: return 10
        case .sm: return 12
        case .md: return 14
        case .lg: return 20
        case .xl: return 26
        }
    }
    
    private var initials: String {
        guard let name = name, !name.isEmpty else {
            return placeholder ?? "?"
        }
        
        let components = name.split(separator: " ")
        if components.count >= 2 {
            let first = components[0].prefix(1)
            let last = components[1].prefix(1)
            return "\(first)\(last)".uppercased()
        } else {
            return String(name.prefix(2)).uppercased()
        }
    }
    
    private var resolvedBackgroundColor: Color {
        backgroundColor ?? colors.muted
    }
    
    private var resolvedForegroundColor: Color {
        foregroundColor ?? colors.mutedForeground
    }
    
    private var resolvedBorderColor: Color {
        borderColor ?? colors.card
    }
    
    private var statusSize: CGFloat {
        switch avatarSize {
        case .xs: return 6
        case .sm: return 8
        case .md: return 10
        case .lg: return 12
        case .xl: return 14
        }
    }
    
    private var badgeSize: CGFloat {
        switch avatarSize {
        case .xs, .sm: return 14
        case .md: return 16
        case .lg: return 18
        case .xl: return 20
        }
    }
    
    // MARK: - Initializers
    
    /// Create an avatar with a remote image URL string
    /// - Parameters:
    ///   - urlString: The URL string for the avatar image (e.g., "https://example.com/avatar.jpg")
    ///   - placeholder: Optional placeholder text if image fails to load
    public init(_ urlString: String, placeholder: String? = nil) {
        self.url = URL(string: urlString)
        self.image = nil
        self.name = nil
        self.placeholder = placeholder
    }
    
    /// Create an avatar with a remote image URL
    public init(url: URL?, placeholder: String? = nil) {
        self.url = url
        self.image = nil
        self.name = nil
        self.placeholder = placeholder
    }
    
    /// Create an avatar with a local image
    public init(image: Image) {
        self.url = nil
        self.image = image
        self.name = nil
        self.placeholder = nil
    }
    
    /// Create an avatar with name (shows initials as fallback)
    public init(name: String) {
        self.url = nil
        self.image = nil
        self.name = name
        self.placeholder = nil
    }
    
    /// Create an avatar with URL string and name fallback
    /// - Parameters:
    ///   - urlString: The URL string for the avatar image
    ///   - name: Name to use for initials if image fails to load
    public init(_ urlString: String, name: String) {
        self.url = URL(string: urlString)
        self.image = nil
        self.name = name
        self.placeholder = nil
    }
    
    /// Create an avatar with URL and name fallback
    public init(url: URL?, name: String) {
        self.url = url
        self.image = nil
        self.name = name
        self.placeholder = nil
    }
    
    // Private init for modifiers
    private init(
        url: URL?,
        image: Image?,
        name: String?,
        placeholder: String?,
        avatarSize: PAvatarSize,
        shape: PAvatarShape,
        status: PAvatarStatus,
        showBorder: Bool,
        borderColor: Color?,
        borderWidth: CGFloat,
        backgroundColor: Color?,
        foregroundColor: Color?,
        badgeCount: Int?,
        badgeColor: Color?
    ) {
        self.url = url
        self.image = image
        self.name = name
        self.placeholder = placeholder
        self.avatarSize = avatarSize
        self.shape = shape
        self.status = status
        self.showBorder = showBorder
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.badgeCount = badgeCount
        self.badgeColor = badgeColor
    }
    
    // MARK: - Body
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContent
                .frame(width: dimension, height: dimension)
                .clipShape(RoundedRectangle(cornerRadius: avatarCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: avatarCornerRadius)
                        .stroke(resolvedBorderColor, lineWidth: showBorder ? borderWidth : 0)
                )
            
            // Status indicator
            if status != .none {
                statusIndicator
                    .offset(x: 2, y: 2)
            }
            
            // Badge
            if let count = badgeCount, count > 0 {
                badgeView(count: count)
                    .offset(x: 4, y: -dimension * 0.6)
            }
        }
    }
    
    @ViewBuilder
    private var avatarContent: some View {
        if let image = image {
            // Local image
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if let url = url {
            // Remote image with AsyncImage
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    placeholderContent
                case .success(let loadedImage):
                    loadedImage
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderContent
                @unknown default:
                    placeholderContent
                }
            }
        } else {
            // Initials or placeholder
            placeholderContent
        }
    }
    
    @ViewBuilder
    private var placeholderContent: some View {
        ZStack {
            resolvedBackgroundColor
            
            if let name = name, !name.isEmpty {
                Text(initials)
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundColor(resolvedForegroundColor)
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: fontSize))
                    .foregroundColor(resolvedForegroundColor)
            }
        }
    }
    
    private var avatarCornerRadius: CGFloat {
        switch shape {
        case .circle:
            return dimension / 2
        case .rounded:
            return dimension * 0.25
        }
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: statusSize, height: statusSize)
            .overlay(
                Circle()
                    .stroke(colors.card, lineWidth: 2)
            )
    }
    
    private var statusColor: Color {
        switch status {
        case .online:
            return colors.success
        case .offline:
            return colors.mutedForeground
        case .away:
            return colors.warning
        case .dnd:
            return colors.destructive
        case .custom(let color):
            return color
        case .none:
            return .clear
        }
    }
    
    @ViewBuilder
    private func badgeView(count: Int) -> some View {
        let displayCount = count > 99 ? "99+" : "\(count)"
        
        Text(displayCount)
            .font(.system(size: badgeSize * 0.65, weight: .semibold))
            .foregroundColor(colors.primaryForeground)
            .padding(.horizontal, 4)
            .frame(minWidth: badgeSize, minHeight: badgeSize)
            .background(badgeColor ?? colors.destructive)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(colors.card, lineWidth: 2)
            )
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension PAvatar {
    
    /// Set the avatar size
    public func size(_ size: PAvatarSize) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: size,
            shape: shape,
            status: status,
            showBorder: showBorder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            badgeCount: badgeCount,
            badgeColor: badgeColor
        )
    }
    
    /// Set the avatar shape
    public func shape(_ shape: PAvatarShape) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: avatarSize,
            shape: shape,
            status: status,
            showBorder: showBorder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            badgeCount: badgeCount,
            badgeColor: badgeColor
        )
    }
    
    /// Set the status indicator
    public func status(_ status: PAvatarStatus) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: avatarSize,
            shape: shape,
            status: status,
            showBorder: showBorder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            badgeCount: badgeCount,
            badgeColor: badgeColor
        )
    }
    
    /// Show a border ring around the avatar
    public func bordered(_ show: Bool = true, color: Color? = nil, width: CGFloat = 2) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: avatarSize,
            shape: shape,
            status: status,
            showBorder: show,
            borderColor: color,
            borderWidth: width,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            badgeCount: badgeCount,
            badgeColor: badgeColor
        )
    }
    
    /// Set custom background color for placeholder
    public func background(_ color: Color) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: avatarSize,
            shape: shape,
            status: status,
            showBorder: showBorder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: color,
            foregroundColor: foregroundColor,
            badgeCount: badgeCount,
            badgeColor: badgeColor
        )
    }
    
    /// Set custom foreground color for initials/icon
    public func foreground(_ color: Color) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: avatarSize,
            shape: shape,
            status: status,
            showBorder: showBorder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            foregroundColor: color,
            badgeCount: badgeCount,
            badgeColor: badgeColor
        )
    }
    
    /// Add a notification badge
    public func badge(count: Int, color: Color? = nil) -> PAvatar {
        PAvatar(
            url: url,
            image: image,
            name: name,
            placeholder: placeholder,
            avatarSize: avatarSize,
            shape: shape,
            status: status,
            showBorder: showBorder,
            borderColor: borderColor,
            borderWidth: borderWidth,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            badgeCount: count,
            badgeColor: color
        )
    }
}

// MARK: - PAvatarGroup

/// A group of overlapping avatars
///
/// Usage:
/// ```swift
/// PAvatarGroup {
///     PAvatar(name: "John Doe")
///     PAvatar(name: "Jane Smith")
///     PAvatar(name: "Bob Wilson")
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PAvatarGroup: View {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let avatars: [AnyView]
    private let maxVisible: Int
    private let size: PAvatarSize
    private let spacing: CGFloat
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    /// Create an avatar group
    /// - Parameters:
    ///   - maxVisible: Maximum number of avatars to show (default: 4)
    ///   - size: Size of avatars (default: .md)
    ///   - spacing: Overlap amount (default: -12)
    ///   - content: The avatars to display
    @MainActor
    public init(
        maxVisible: Int = 4,
        size: PAvatarSize = .md,
        spacing: CGFloat = -12,
        @AvatarGroupBuilder content: () -> [AnyView]
    ) {
        self.maxVisible = maxVisible
        self.size = size
        self.spacing = spacing
        self.avatars = content()
    }
    
    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<min(avatars.count, maxVisible), id: \.self) { index in
                avatars[index]
                    .zIndex(Double(maxVisible - index))
            }
            
            if avatars.count > maxVisible {
                overflowBadge
                    .zIndex(0)
            }
        }
    }
    
    @ViewBuilder
    private var overflowBadge: some View {
        let remaining = avatars.count - maxVisible
        
        ZStack {
            Circle()
                .fill(colors.muted)
            
            Text("+\(remaining)")
                .font(.system(size: size.dimension * 0.35, weight: .semibold))
                .foregroundColor(colors.mutedForeground)
        }
        .frame(width: size.dimension, height: size.dimension)
        .overlay(
            Circle()
                .stroke(colors.card, lineWidth: 2)
        )
    }
}

// MARK: - Avatar Group Builder

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@resultBuilder
public struct AvatarGroupBuilder {
    @MainActor
    public static func buildBlock(_ components: PAvatar...) -> [AnyView] {
        components.map { avatar in
            AnyView(
                avatar
                    .bordered(true)
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PAvatar_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // URL String (simplest usage)
                Group {
                    Text("URL String")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack {
                            PAvatar("https://pbs.twimg.com/profile_images/1966568729887522816/Q2D6vARj_400x400.jpg")
                                .size(.lg)
                            Text("URL only").font(.caption)
                        }
                        VStack {
                            PAvatar("https://pbs.twimg.com/profile_images/1966568729887522816/Q2D6vARj_400x400.jpg", name: "Family")
                                .size(.lg)
                                .status(.online)
                            Text("URL + name").font(.caption)
                        }
                        VStack {
                            PAvatar("invalid-url", name: "Fallback")
                                .size(.lg)
                            Text("Fallback").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // Sizes
                Group {
                    Text("Sizes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack {
                            PAvatar(name: "John Doe").size(.xs)
                            Text("xs").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "John Doe").size(.sm)
                            Text("sm").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "John Doe").size(.md)
                            Text("md").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "John Doe").size(.lg)
                            Text("lg").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "John Doe").size(.xl)
                            Text("xl").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // Shapes
                Group {
                    Text("Shapes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 24) {
                        VStack {
                            PAvatar(name: "Circle").size(.lg).shape(.circle)
                            Text("circle").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "Rounded").size(.lg).shape(.rounded)
                            Text("rounded").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // Status indicators
                Group {
                    Text("Status")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack {
                            PAvatar(name: "Online").size(.lg).status(.online)
                            Text("online").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "Away").size(.lg).status(.away)
                            Text("away").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "DND").size(.lg).status(.dnd)
                            Text("dnd").font(.caption)
                        }
                        VStack {
                            PAvatar(name: "Offline").size(.lg).status(.offline)
                            Text("offline").font(.caption)
                        }
                    }
                }
                
                Divider()
                
                // With badges
                Group {
                    Text("Badges")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 24) {
                        PAvatar(name: "User").size(.lg).badge(count: 3)
                        PAvatar(name: "User").size(.lg).badge(count: 99)
                        PAvatar(name: "User").size(.lg).badge(count: 150)
                        PAvatar(name: "User").size(.lg).badge(count: 5, color: .blue)
                    }
                }
                
                Divider()
                
                // With border
                Group {
                    Text("Bordered")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        PAvatar(name: "Border").size(.lg).bordered()
                        PAvatar(name: "Custom").size(.lg).bordered(true, color: .blue, width: 3)
                    }
                }
                
                Divider()
                
                // Custom colors
                Group {
                    Text("Custom Colors")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        PAvatar(name: "AB")
                            .size(.lg)
                            .background(Color.blue.opacity(0.2))
                            .foreground(.blue)
                        
                        PAvatar(name: "CD")
                            .size(.lg)
                            .background(Color.green.opacity(0.2))
                            .foreground(.green)
                        
                        PAvatar(name: "EF")
                            .size(.lg)
                            .background(Color.purple.opacity(0.2))
                            .foreground(.purple)
                    }
                }
                
                Divider()
                
                // Avatar group
                Group {
                    Text("Avatar Group")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PAvatarGroup(maxVisible: 3, size: .md) {
                        PAvatar(name: "John Doe")
                        PAvatar(name: "Jane Smith")
                        PAvatar(name: "Bob Wilson")
                        PAvatar(name: "Alice Brown")
                        PAvatar(name: "Charlie Davis")
                    }
                    
                    PAvatarGroup(maxVisible: 4, size: .lg) {
                        PAvatar(name: "A")
                        PAvatar(name: "B")
                        PAvatar(name: "C")
                        PAvatar(name: "D")
                    }
                }
                
                Divider()
                
                // Placeholder states
                Group {
                    Text("Placeholders")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        PAvatar(url: nil, placeholder: "?").size(.lg)
                        PAvatar(url: nil).size(.lg) // Shows person icon
                        PAvatar(name: "").size(.lg) // Shows person icon
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: "#F8F9FA"))
        .prettyTheme(.sky)
        .previewDisplayName("Light Mode")
        
        ScrollView {
            VStack(spacing: 24) {
                HStack(spacing: 16) {
                    PAvatar(name: "John Doe").size(.lg).status(.online)
                    PAvatar(name: "Jane Smith").size(.lg).badge(count: 5)
                    PAvatar(name: "Bob Wilson").size(.lg).bordered()
                }
                
                PAvatarGroup(size: .md) {
                    PAvatar(name: "User 1")
                    PAvatar(name: "User 2")
                    PAvatar(name: "User 3")
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

