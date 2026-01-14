//
//  RadiusTokens.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// Border radius tokens for consistent rounded corners
/// Default values follow the Family.co design system guidelines
public struct RadiusTokens: Equatable, Sendable {
    
    /// No radius (0pt)
    public var none: CGFloat
    
    /// Small radius (6pt) - Small chips, tags
    public var sm: CGFloat
    
    /// Medium radius (10pt) - Inputs, small cards
    public var md: CGFloat
    
    /// Large radius (14pt) - Standard cards
    public var lg: CGFloat
    
    /// Extra large radius (20pt) - Large cards, images
    public var xl: CGFloat
    
    /// 2x Extra large radius (28pt) - Modals, sheets
    public var xxl: CGFloat
    
    /// Full/pill radius (9999pt) - Pill buttons, avatars
    public var full: CGFloat
    
    // MARK: - Initializer
    
    public init(
        none: CGFloat = 0,
        sm: CGFloat = 6,
        md: CGFloat = 10,
        lg: CGFloat = 14,
        xl: CGFloat = 20,
        xxl: CGFloat = 28,
        full: CGFloat = 9999
    ) {
        self.none = none
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.full = full
    }
    
    // MARK: - Default
    
    public static let `default` = RadiusTokens()
    
    // MARK: - Subscript Access
    
    public subscript(_ size: RadiusSize) -> CGFloat {
        switch size {
        case .none: return none
        case .sm: return sm
        case .md: return md
        case .lg: return lg
        case .xl: return xl
        case .xxl: return xxl
        case .full: return full
        case .custom(let value): return value
        }
    }
}

/// Radius size options
public enum RadiusSize: Equatable, Sendable {
    case none
    case sm
    case md
    case lg
    case xl
    case xxl
    case full
    case custom(CGFloat)
}

