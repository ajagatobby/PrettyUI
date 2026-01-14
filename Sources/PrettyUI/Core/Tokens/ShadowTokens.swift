//
//  ShadowTokens.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// Shadow tokens for consistent elevation and depth
/// Default values follow the Family.co design system with soft, diffused shadows
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ShadowTokens: Equatable, Sendable {
    
    /// No shadow
    public var none: ShadowStyle
    
    /// Small/subtle shadow - Cards at rest
    public var sm: ShadowStyle
    
    /// Medium shadow - Cards on hover/focus, tooltips
    public var md: ShadowStyle
    
    /// Large shadow - Floating elements
    public var lg: ShadowStyle
    
    /// Extra large shadow - Modals, sheets
    public var xl: ShadowStyle
    
    /// 2x Extra large shadow - Popovers, elevated modals
    public var xxl: ShadowStyle
    
    // MARK: - Initializer
    
    public init(
        none: ShadowStyle = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0),
        sm: ShadowStyle = ShadowStyle(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2),
        md: ShadowStyle = ShadowStyle(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4),
        lg: ShadowStyle = ShadowStyle(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 8),
        xl: ShadowStyle = ShadowStyle(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 12),
        xxl: ShadowStyle = ShadowStyle(color: Color.black.opacity(0.16), radius: 48, x: 0, y: 16)
    ) {
        self.none = none
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
    }
    
    // MARK: - Default
    
    public static let `default` = ShadowTokens()
    
    // MARK: - Subscript Access
    
    public subscript(_ size: ShadowSize) -> ShadowStyle {
        switch size {
        case .none: return none
        case .sm: return sm
        case .md: return md
        case .lg: return lg
        case .xl: return xl
        case .xxl: return xxl
        case .custom(let style): return style
        }
    }
}

/// Shadow size options
public enum ShadowSize: Equatable, Sendable {
    case none
    case sm
    case md
    case lg
    case xl
    case xxl
    case custom(ShadowStyle)
}

/// Individual shadow style definition
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ShadowStyle: Equatable, Sendable {
    public var color: Color
    public var radius: CGFloat
    public var x: CGFloat
    public var y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - View Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Apply a shadow style from tokens
    public func prettyShadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

