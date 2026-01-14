//
//  PSpinner.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired loading spinner with smooth animations.
//

import SwiftUI

// MARK: - Spinner Size

/// Size options for PSpinner
public enum PSpinnerSize: String, Equatable, Sendable, CaseIterable {
    /// Small spinner (16pt)
    case sm
    /// Medium spinner (24pt) - default
    case md
    /// Large spinner (32pt)
    case lg
    /// Extra large spinner (48pt)
    case xl
    
    var dimension: CGFloat {
        switch self {
        case .sm: return 16
        case .md: return 24
        case .lg: return 32
        case .xl: return 48
        }
    }
    
    var strokeWidth: CGFloat {
        switch self {
        case .sm: return 2
        case .md: return 2.5
        case .lg: return 3
        case .xl: return 4
        }
    }
}

// MARK: - Spinner Style

/// Visual style options for PSpinner
public enum PSpinnerStyle: Equatable, Sendable {
    /// Circular arc spinner (default)
    case circular
    /// Pulsing dots
    case dots
    /// Spinner with track background and gradient arc
    case track
    /// Minimal spinner with subtle track and solid arc
    case minimal
    /// Dots arranged in a circle with sequential fade animation
    case orbit
}

// MARK: - PSpinner Configuration

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSpinnerConfiguration {
    var size: PSpinnerSize = .md
    var style: PSpinnerStyle = .circular
    var color: Color? = nil
    var label: String? = nil
    var labelPlacement: LabelPlacement = .bottom
    
    public enum LabelPlacement: Sendable {
        case bottom
        case trailing
    }
}

// MARK: - PSpinner

/// A customizable loading spinner inspired by Family.co's design.
///
/// Uses a fluent modifier API for configuration:
/// ```swift
/// PSpinner()
///     .size(.lg)
///     .color(.primary)
///
/// PSpinner(label: "Loading...")
///     .size(.md)
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PSpinner: View {
    
    // MARK: - Environment
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - State
    
    @State private var isAnimating = false
    @State private var dotScale: CGFloat = 0.5
    
    // MARK: - Properties
    
    private var config: PSpinnerConfiguration
    
    // MARK: - Computed Properties
    
    private var colors: ColorTokens {
        theme.colors(for: colorScheme)
    }
    
    private var resolvedColor: Color {
        config.color ?? colors.primary
    }
    
    private var spinnerConfig: SpinnerConfig {
        theme.components.spinner
    }
    
    // MARK: - Initializer
    
    /// Create a loading spinner
    /// - Parameter label: Optional label text to display
    public init(label: String? = nil) {
        var config = PSpinnerConfiguration()
        config.label = label
        self.config = config
    }
    
    // Private init for modifiers
    private init(config: PSpinnerConfiguration) {
        self.config = config
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if let label = config.label {
                labeledContent(label)
            } else {
                spinnerView
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    @ViewBuilder
    private func labeledContent(_ label: String) -> some View {
        switch config.labelPlacement {
        case .bottom:
            VStack(spacing: theme.spacing.sm) {
                spinnerView
                Text(label)
                    .font(.system(size: theme.typography.sizes.sm))
                    .foregroundColor(colors.mutedForeground)
            }
        case .trailing:
            HStack(spacing: theme.spacing.sm) {
                spinnerView
                Text(label)
                    .font(.system(size: theme.typography.sizes.sm))
                    .foregroundColor(colors.mutedForeground)
            }
        }
    }
    
    @ViewBuilder
    private var spinnerView: some View {
        switch config.style {
        case .circular:
            circularSpinner
        case .dots:
            dotsSpinner
        case .track:
            trackSpinner
        case .minimal:
            minimalSpinner
        case .orbit:
            orbitSpinner
        }
    }
    
    // MARK: - Circular Spinner
    
    private var circularSpinner: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                resolvedColor,
                style: StrokeStyle(
                    lineWidth: config.size.strokeWidth,
                    lineCap: .round
                )
            )
            .frame(width: config.size.dimension, height: config.size.dimension)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(rotationAnimation, value: isAnimating)
    }
    
    // MARK: - Dots Spinner
    
    private var dotsSpinner: some View {
        HStack(spacing: config.size.dimension * 0.25) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(resolvedColor)
                    .frame(
                        width: config.size.dimension * 0.3,
                        height: config.size.dimension * 0.3
                    )
                    .scaleEffect(dotScale(for: index))
                    .animation(dotAnimation(for: index), value: isAnimating)
            }
        }
        .frame(height: config.size.dimension)
    }
    
    private func dotScale(for index: Int) -> CGFloat {
        guard isAnimating else { return 0.5 }
        // Stagger the animation for each dot
        return 1.0
    }
    
    private func dotAnimation(for index: Int) -> Animation {
        guard !reduceMotion else {
            return .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        }
        
        return .easeInOut(duration: 0.6)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.15)
    }
    
    // MARK: - Track Spinner
    
    private var trackSpinner: some View {
        ZStack {
            // Track (background circle)
            Circle()
                .stroke(
                    trackColor,
                    style: StrokeStyle(
                        lineWidth: config.size.strokeWidth,
                        lineCap: .round
                    )
                )
            
            // Gradient arc
            Circle()
                .trim(from: 0, to: 0.28)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            resolvedColor.opacity(0.1),
                            resolvedColor.opacity(0.5),
                            resolvedColor
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(100)
                    ),
                    style: StrokeStyle(
                        lineWidth: config.size.strokeWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(trackRotationAnimation, value: isAnimating)
        }
        .frame(width: config.size.dimension, height: config.size.dimension)
    }
    
    private var trackColor: Color {
        colorScheme == .dark
            ? colors.muted.opacity(0.4)
            : colors.border.opacity(0.6)
    }
    
    private var trackRotationAnimation: Animation {
        guard !reduceMotion else {
            return .linear(duration: 2.0).repeatForever(autoreverses: false)
        }
        
        return .linear(duration: 1.0)
            .repeatForever(autoreverses: false)
    }
    
    // MARK: - Minimal Spinner
    
    private var minimalSpinner: some View {
        ZStack {
            // Subtle track
            Circle()
                .stroke(
                    minimalTrackColor,
                    style: StrokeStyle(
                        lineWidth: config.size.strokeWidth * 0.8,
                        lineCap: .round
                    )
                )
            
            // Solid arc
            Circle()
                .trim(from: 0, to: 0.18)
                .stroke(
                    minimalArcColor,
                    style: StrokeStyle(
                        lineWidth: config.size.strokeWidth * 0.8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(minimalRotationAnimation, value: isAnimating)
        }
        .frame(width: config.size.dimension, height: config.size.dimension)
    }
    
    private var minimalTrackColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color.black.opacity(0.06)
    }
    
    private var minimalArcColor: Color {
        config.color ?? (colorScheme == .dark
            ? Color.white.opacity(0.5)
            : Color.black.opacity(0.35))
    }
    
    private var minimalRotationAnimation: Animation {
        guard !reduceMotion else {
            return .linear(duration: 2.0).repeatForever(autoreverses: false)
        }
        
        return .linear(duration: 0.9)
            .repeatForever(autoreverses: false)
    }
    
    // MARK: - Orbit Spinner
    
    private let orbitDotCount = 6
    
    private var orbitSpinner: some View {
        ZStack {
            ForEach(0..<orbitDotCount, id: \.self) { index in
                Circle()
                    .fill(config.color ?? resolvedColor)
                    .frame(width: orbitDotSize, height: orbitDotSize)
                    .offset(y: -orbitRadius)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(orbitDotCount))))
                    .opacity(orbitDotOpacity(for: index))
            }
        }
        .frame(width: config.size.dimension, height: config.size.dimension)
        .rotationEffect(.degrees(isAnimating ? 360 : 0))
        .animation(orbitRotationAnimation, value: isAnimating)
    }
    
    private var orbitDotSize: CGFloat {
        config.size.dimension * 0.18
    }
    
    private var orbitRadius: CGFloat {
        (config.size.dimension - orbitDotSize) / 2
    }
    
    private func orbitDotOpacity(for index: Int) -> Double {
        // Create a gradient of opacities around the circle
        let baseOpacity = 0.3
        let maxOpacity = 1.0
        let step = (maxOpacity - baseOpacity) / Double(orbitDotCount - 1)
        return baseOpacity + (step * Double(index))
    }
    
    private var orbitRotationAnimation: Animation {
        guard !reduceMotion else {
            return .linear(duration: 2.0).repeatForever(autoreverses: false)
        }
        
        return .linear(duration: 1.2)
            .repeatForever(autoreverses: false)
    }
    
    // MARK: - Animation
    
    private var rotationAnimation: Animation {
        guard !reduceMotion else {
            // Slower animation for reduced motion
            return .linear(duration: 2.0).repeatForever(autoreverses: false)
        }
        
        return .linear(duration: spinnerConfig.animationDuration)
            .repeatForever(autoreverses: false)
    }
    
    private func startAnimation() {
        isAnimating = true
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PSpinner {
    
    /// Set the spinner size
    func size(_ size: PSpinnerSize) -> PSpinner {
        var newConfig = config
        newConfig.size = size
        return PSpinner(config: newConfig)
    }
    
    /// Set the spinner style
    func style(_ style: PSpinnerStyle) -> PSpinner {
        var newConfig = config
        newConfig.style = style
        return PSpinner(config: newConfig)
    }
    
    /// Set the spinner color
    func color(_ color: Color) -> PSpinner {
        var newConfig = config
        newConfig.color = color
        return PSpinner(config: newConfig)
    }
    
    /// Use primary color
    func primary() -> PSpinner {
        var newConfig = config
        newConfig.color = nil // Will use theme primary
        return PSpinner(config: newConfig)
    }
    
    /// Set the label text
    func label(_ text: String?) -> PSpinner {
        var newConfig = config
        newConfig.label = text
        return PSpinner(config: newConfig)
    }
    
    /// Set the label placement
    func labelPlacement(_ placement: PSpinnerConfiguration.LabelPlacement) -> PSpinner {
        var newConfig = config
        newConfig.labelPlacement = placement
        return PSpinner(config: newConfig)
    }
}

// MARK: - Spinner View Modifier

/// A view modifier that overlays a spinner when loading
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SpinnerOverlayModifier: ViewModifier {
    
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    
    let isLoading: Bool
    let size: PSpinnerSize
    let dimBackground: Bool
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .opacity(isLoading && dimBackground ? 0.5 : 1)
            
            if isLoading {
                PSpinner()
                    .size(size)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Show a spinner overlay when loading
    /// - Parameters:
    ///   - isLoading: Whether to show the spinner
    ///   - size: Size of the spinner
    ///   - dimBackground: Whether to dim the background content
    func spinnerOverlay(
        _ isLoading: Bool,
        size: PSpinnerSize = .md,
        dimBackground: Bool = true
    ) -> some View {
        modifier(SpinnerOverlayModifier(
            isLoading: isLoading,
            size: size,
            dimBackground: dimBackground
        ))
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PSpinner_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 48) {
                // Sizes
                Group {
                    Text("Sizes")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 32) {
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.sm)
                            Text("SM")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.md)
                            Text("MD")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.lg)
                            Text("LG")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.xl)
                            Text("XL")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Divider()
                
                // Styles
                Group {
                    Text("Styles")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 24) {
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.lg)
                                .style(.circular)
                            Text("Circular")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.lg)
                                .style(.dots)
                            Text("Dots")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.lg)
                                .style(.track)
                            Text("Track")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.lg)
                                .style(.minimal)
                            Text("Minimal")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 8) {
                            PSpinner()
                                .size(.lg)
                                .style(.orbit)
                            Text("Orbit")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Divider()
                
                // Colors
                Group {
                    Text("Colors")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 32) {
                        PSpinner()
                            .size(.lg)
                            .primary()
                        
                        PSpinner()
                            .size(.lg)
                            .style(.track)
                            .color(.green)
                        
                        PSpinner()
                            .size(.lg)
                            .color(.orange)
                        
                        PSpinner()
                            .size(.lg)
                            .color(.red)
                    }
                }
                
                Divider()
                
                // With Labels
                Group {
                    Text("With Labels")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 48) {
                        PSpinner(label: "Loading...")
                            .size(.lg)
                        
                        PSpinner(label: "Please wait")
                            .size(.md)
                            .labelPlacement(.trailing)
                    }
                }
                
                Divider()
                
                // Overlay Example
                Group {
                    Text("Spinner Overlay")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PCard {
                        VStack(spacing: 12) {
                            Text("Card Content")
                                .font(.headline)
                            Text("This card has a loading state")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    }
                    .spinnerOverlay(true, size: .lg)
                }
            }
            .padding()
        }
        .prettyTheme(.family)
        .previewDisplayName("Light Mode")
        
        VStack(spacing: 40) {
            PSpinner()
                .size(.xl)
                .style(.orbit)
            
            PSpinner(label: "Loading wallet...")
                .size(.lg)
                .style(.track)
            
            HStack(spacing: 32) {
                PSpinner()
                    .size(.lg)
                    .style(.minimal)
                
                PSpinner()
                    .size(.lg)
                    .style(.orbit)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "#0D0D0D"))
        .prettyTheme(.family)
        .preferredColorScheme(.dark)
        .previewDisplayName("Dark Mode")
    }
}
#endif

