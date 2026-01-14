//
//  SpacingTokens.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// Spacing tokens for consistent spacing throughout your app
public struct SpacingTokens: Equatable, Sendable {
    
    /// Extra extra small spacing (2pt)
    public var xxs: CGFloat
    
    /// Extra small spacing (4pt)
    public var xs: CGFloat
    
    /// Small spacing (8pt)
    public var sm: CGFloat
    
    /// Medium spacing (16pt) - default
    public var md: CGFloat
    
    /// Large spacing (24pt)
    public var lg: CGFloat
    
    /// Extra large spacing (32pt)
    public var xl: CGFloat
    
    /// 2x Extra large spacing (48pt)
    public var xxl: CGFloat
    
    /// 3x Extra large spacing (64pt)
    public var xxxl: CGFloat
    
    // MARK: - Initializer
    
    public init(
        xxs: CGFloat = 2,
        xs: CGFloat = 4,
        sm: CGFloat = 8,
        md: CGFloat = 16,
        lg: CGFloat = 24,
        xl: CGFloat = 32,
        xxl: CGFloat = 48,
        xxxl: CGFloat = 64
    ) {
        self.xxs = xxs
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
    }
    
    // MARK: - Default
    
    public static let `default` = SpacingTokens()
    
    // MARK: - Subscript Access
    
    public subscript(_ size: SpacingSize) -> CGFloat {
        switch size {
        case .xxs: return xxs
        case .xs: return xs
        case .sm: return sm
        case .md: return md
        case .lg: return lg
        case .xl: return xl
        case .xxl: return xxl
        case .xxxl: return xxxl
        case .custom(let value): return value
        }
    }
}

/// Spacing size options
public enum SpacingSize: Equatable, Sendable {
    case xxs
    case xs
    case sm
    case md
    case lg
    case xl
    case xxl
    case xxxl
    case custom(CGFloat)
}

