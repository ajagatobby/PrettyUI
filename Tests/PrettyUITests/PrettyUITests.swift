//
//  PrettyUITests.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import XCTest
import SwiftUI
@testable import PrettyUI

final class PrettyUITests: XCTestCase {
    
    // MARK: - Theme Tests
    
    func testDefaultThemeExists() {
        let theme = PrettyTheme.default
        XCTAssertNotNil(theme)
    }
    
    func testPresetThemesExist() {
        XCTAssertNotNil(PrettyTheme.indigo)
        XCTAssertNotNil(PrettyTheme.emerald)
        XCTAssertNotNil(PrettyTheme.amber)
    }
    
    func testThemeColorsForColorScheme() {
        let theme = PrettyTheme.default
        
        let lightColors = theme.colors(for: .light)
        let darkColors = theme.colors(for: .dark)
        
        // Light and dark should be different
        XCTAssertNotEqual(lightColors.background, darkColors.background)
    }
    
    // MARK: - Token Tests
    
    func testSpacingTokensDefault() {
        let spacing = SpacingTokens.default
        
        XCTAssertEqual(spacing.xs, 4)
        XCTAssertEqual(spacing.sm, 8)
        XCTAssertEqual(spacing.md, 16)
        XCTAssertEqual(spacing.lg, 24)
        XCTAssertEqual(spacing.xl, 32)
    }
    
    func testRadiusTokensDefault() {
        let radius = RadiusTokens.default
        
        // Family.co design guidelines values
        XCTAssertEqual(radius.none, 0)
        XCTAssertEqual(radius.sm, 6)
        XCTAssertEqual(radius.md, 10)
        XCTAssertEqual(radius.lg, 14)
        XCTAssertEqual(radius.xl, 20)
        XCTAssertEqual(radius.xxl, 28)
        XCTAssertEqual(radius.full, 9999)
    }
    
    func testSpacingSubscript() {
        let spacing = SpacingTokens.default
        
        XCTAssertEqual(spacing[.xs], 4)
        XCTAssertEqual(spacing[.md], 16)
        XCTAssertEqual(spacing[.custom(100)], 100)
    }
    
    func testRadiusSubscript() {
        let radius = RadiusTokens.default
        
        XCTAssertEqual(radius[.sm], 6)
        XCTAssertEqual(radius[.lg], 14)
        XCTAssertEqual(radius[.custom(50)], 50)
    }
    
    // MARK: - Color Extension Tests
    
    func testColorFromHex6() {
        let color = Color(hex: "#FF0000")
        // Red color should have been created
        XCTAssertNotNil(color)
    }
    
    func testColorFromHex3() {
        let color = Color(hex: "#F00")
        XCTAssertNotNil(color)
    }
    
    func testColorFromHexWithoutHash() {
        let color = Color(hex: "00FF00")
        XCTAssertNotNil(color)
    }
    
    // MARK: - Component Config Tests
    
    func testButtonConfigDefaults() {
        let config = ButtonConfig.default
        
        // Family.co style: large pill buttons
        XCTAssertEqual(config.defaultVariant, .primary)
        XCTAssertEqual(config.defaultSize, .lg)
        XCTAssertEqual(config.radius, .full)
        XCTAssertTrue(config.showPressAnimation)
    }
    
    func testCardConfigDefaults() {
        let config = CardConfig.default
        
        XCTAssertEqual(config.radius, .lg)
        XCTAssertEqual(config.shadow, .sm)
        XCTAssertEqual(config.showBorder, true)
    }
    
    func testTextFieldConfigDefaults() {
        let config = TextFieldConfig.default
        
        XCTAssertEqual(config.radius, .md)
        XCTAssertEqual(config.defaultSize, .md)
        XCTAssertEqual(config.borderWidth, 1)
    }
    
    // MARK: - Custom Theme Tests
    
    func testCustomThemeCreation() {
        let customColors = ColorTokens(
            primary: Color(hex: "#6366F1"),
            primaryForeground: .white,
            secondary: Color(hex: "#8B5CF6"),
            secondaryForeground: .white,
            accent: Color(hex: "#F59E0B"),
            accentForeground: .black,
            destructive: .red,
            destructiveForeground: .white,
            success: .green,
            successForeground: .white,
            warning: .orange,
            warningForeground: .black,
            background: .white,
            foreground: .black,
            muted: Color(hex: "#F1F5F9"),
            mutedForeground: .gray,
            card: .white,
            cardForeground: .black,
            border: Color(hex: "#E2E8F0"),
            input: Color(hex: "#E2E8F0"),
            ring: Color(hex: "#6366F1")
        )
        
        let customTheme = PrettyTheme(colors: customColors)
        
        XCTAssertEqual(customTheme.colors.primary, customColors.primary)
    }
}

