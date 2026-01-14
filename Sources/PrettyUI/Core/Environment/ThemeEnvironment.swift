//
//  ThemeEnvironment.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

// MARK: - Theme Environment Key

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
private struct PrettyThemeKey: EnvironmentKey {
    static let defaultValue = PrettyTheme.default
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension EnvironmentValues {
    /// The current PrettyUI theme
    public var prettyTheme: PrettyTheme {
        get { self[PrettyThemeKey.self] }
        set { self[PrettyThemeKey.self] = newValue }
    }
}

// MARK: - View Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension View {
    /// Apply a PrettyUI theme to this view and its descendants
    ///
    /// ```swift
    /// ContentView()
    ///     .prettyTheme(.indigo)
    /// ```
    public func prettyTheme(_ theme: PrettyTheme) -> some View {
        environment(\.prettyTheme, theme)
    }
}

// MARK: - Resolved Colors (with ColorScheme)

/// A wrapper that provides theme colors resolved for the current color scheme
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ResolvedColors {
    private let theme: PrettyTheme
    private let colorScheme: ColorScheme
    
    init(theme: PrettyTheme, colorScheme: ColorScheme) {
        self.theme = theme
        self.colorScheme = colorScheme
    }
    
    private var tokens: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    public var primary: Color { tokens.primary }
    public var primaryForeground: Color { tokens.primaryForeground }
    public var secondary: Color { tokens.secondary }
    public var secondaryForeground: Color { tokens.secondaryForeground }
    public var accent: Color { tokens.accent }
    public var accentForeground: Color { tokens.accentForeground }
    public var destructive: Color { tokens.destructive }
    public var destructiveForeground: Color { tokens.destructiveForeground }
    public var success: Color { tokens.success }
    public var successForeground: Color { tokens.successForeground }
    public var warning: Color { tokens.warning }
    public var warningForeground: Color { tokens.warningForeground }
    public var background: Color { tokens.background }
    public var foreground: Color { tokens.foreground }
    public var muted: Color { tokens.muted }
    public var mutedForeground: Color { tokens.mutedForeground }
    public var card: Color { tokens.card }
    public var cardForeground: Color { tokens.cardForeground }
    public var border: Color { tokens.border }
    public var input: Color { tokens.input }
    public var ring: Color { tokens.ring }
}

// MARK: - Theme Reader

/// A view that provides access to the current theme and color scheme
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ThemeReader<Content: View>: View {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let content: (PrettyTheme, ResolvedColors) -> Content
    
    public init(@ViewBuilder content: @escaping (PrettyTheme, ResolvedColors) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(theme, ResolvedColors(theme: theme, colorScheme: colorScheme))
    }
}

// MARK: - Property Wrapper for Components

/// A property wrapper that provides resolved theme values
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@propertyWrapper
public struct ThemeValue<Value>: DynamicProperty {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    private let keyPath: KeyPath<PrettyTheme, Value>
    
    public init(_ keyPath: KeyPath<PrettyTheme, Value>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: Value {
        theme[keyPath: keyPath]
    }
}

