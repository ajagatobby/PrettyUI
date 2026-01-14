//
//  PTapGesture.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//
//  Family.co inspired tap gesture component for adding fluid press animations to any view.
//
//  Implementation based on production patterns from major apps:
//  - Minimum press duration ensures visual feedback is always visible
//  - GestureState for automatic cancellation on scroll
//  - Proper spring animations with bounce on release
//

import SwiftUI

// MARK: - Tap Gesture Configuration

/// Configuration for PTapGesture styling and behavior
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTapGestureConfiguration {
    /// Scale effect when pressed (1.0 = no scale, 0.96 = Family default)
    public var scaleEffect: CGFloat = 0.96
    
    /// Opacity when pressed (1.0 = no change)
    public var opacityEffect: CGFloat = 1.0
    
    /// Brightness adjustment when pressed (0.0 = no change)
    public var brightnessEffect: Double = 0.0
    
    /// Whether to trigger haptic feedback on tap
    public var hapticFeedback: Bool = true
    
    /// Haptic feedback style (iOS only)
    public var hapticStyle: HapticStyle = .light
    
    /// Spring animation response for press (lower = faster)
    public var pressResponse: Double = 0.2
    
    /// Spring animation damping for press
    public var pressDamping: Double = 0.7
    
    /// Spring animation response for release (lower = faster)
    public var releaseResponse: Double = 0.35
    
    /// Spring animation damping for release (lower = bouncier)
    public var releaseDamping: Double = 0.55
    
    /// Minimum duration the press state should be visible (seconds)
    /// This ensures the user always sees the press animation even on quick taps
    public var minimumPressDuration: Double = 0.08
    
    /// Whether the gesture is disabled
    public var isDisabled: Bool = false
    
    /// Haptic feedback styles
    public enum HapticStyle: Sendable {
        case light
        case medium
        case heavy
        case soft
        case rigid
        
        #if os(iOS)
        var uiStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
            case .light: return .light
            case .medium: return .medium
            case .heavy: return .heavy
            case .soft: return .soft
            case .rigid: return .rigid
            }
        }
        #endif
    }
    
    public init() {}
}

// MARK: - Tap Gesture Button Style

/// Button style that provides Family.co-style press animations.
/// Uses Button internally which properly handles scroll gesture conflicts.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
fileprivate struct PTapGestureButtonStyle: ButtonStyle {
    let config: PTapGestureConfiguration
    let reduceMotion: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        PTapGestureButtonContent(
            config: config,
            reduceMotion: reduceMotion,
            isSystemPressed: configuration.isPressed,
            label: configuration.label
        )
    }
}

/// Internal view that manages animation state with minimum press duration.
/// This ensures the press animation is always visible even on quick taps.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
fileprivate struct PTapGestureButtonContent<Label: View>: View {
    let config: PTapGestureConfiguration
    let reduceMotion: Bool
    let isSystemPressed: Bool
    let label: Label
    
    // Track visual press state separately to implement minimum duration
    @State private var isVisuallyPressed = false
    @State private var pressStartTime: Date?
    @State private var releaseTask: Task<Void, Never>?
    
    // MARK: - Animations
    
    private var pressAnimation: Animation {
        .spring(response: config.pressResponse, dampingFraction: config.pressDamping)
    }
    
    private var releaseAnimation: Animation {
        .spring(response: config.releaseResponse, dampingFraction: config.releaseDamping)
    }
    
    var body: some View {
        label
            .scaleEffect(isVisuallyPressed ? config.scaleEffect : 1.0)
            .opacity(isVisuallyPressed ? config.opacityEffect : 1.0)
            .brightness(isVisuallyPressed ? config.brightnessEffect : 0.0)
            .animation(isVisuallyPressed ? pressAnimation : releaseAnimation, value: isVisuallyPressed)
            .onChange(of: isSystemPressed) { pressed in
                handlePressChange(pressed)
            }
    }
    
    private func handlePressChange(_ pressed: Bool) {
        // Cancel any pending release
        releaseTask?.cancel()
        releaseTask = nil
        
        if pressed {
            // Finger down - immediately show pressed state
            pressStartTime = Date()
            if !reduceMotion {
                withAnimation(pressAnimation) {
                    isVisuallyPressed = true
                }
            }
        } else {
            // Finger up
            let startTime = pressStartTime ?? Date()
            pressStartTime = nil
            
            if reduceMotion {
                isVisuallyPressed = false
                return
            }
            
            // Calculate remaining time to meet minimum duration
            let elapsed = Date().timeIntervalSince(startTime)
            let remaining = max(0, config.minimumPressDuration - elapsed)
            
            if remaining > 0 {
                // Delay release to ensure minimum visible duration
                releaseTask = Task { @MainActor in
                    try? await Task.sleep(nanoseconds: UInt64(remaining * 1_000_000_000))
                    guard !Task.isCancelled else { return }
                    withAnimation(releaseAnimation) {
                        isVisuallyPressed = false
                    }
                }
            } else {
                // Already met minimum duration
                withAnimation(releaseAnimation) {
                    isVisuallyPressed = false
                }
            }
        }
    }
}

// MARK: - Tap Gesture View Modifier

/// A view modifier that adds Family.co-style tap gesture animations to any view.
///
/// **How it works (production-grade implementation):**
/// - Uses `Button` with custom `ButtonStyle` for proper scroll support
/// - Button's gesture handling automatically distinguishes taps from scrolls
/// - Minimum press duration ensures visual feedback is always visible
/// - Separate spring animations for press (quick) and release (bouncy)
///
/// Usage:
/// ```swift
/// // Basic usage
/// Image("nft")
///     .pTapGesture { print("Tapped!") }
///
/// // With customization
/// Card()
///     .modifier(
///         PTapGesture { /* action */ }
///             .scaleEffect(0.92)
///             .bouncy()
///     )
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PTapGesture: ViewModifier {
    
    // MARK: - Environment
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    // MARK: - Properties
    
    private let action: () -> Void
    fileprivate var config: PTapGestureConfiguration
    
    // MARK: - Initializer
    
    /// Create a tap gesture modifier
    /// - Parameters:
    ///   - action: Closure to execute on tap
    public init(action: @escaping () -> Void) {
        self.action = action
        self.config = PTapGestureConfiguration()
    }
    
    // Private init for modifiers
    fileprivate init(action: @escaping () -> Void, config: PTapGestureConfiguration) {
        self.action = action
        self.config = config
    }
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        Button {
            guard !config.isDisabled else { return }
            triggerHaptic()
            action()
        } label: {
            content
        }
        .buttonStyle(PTapGestureButtonStyle(config: config, reduceMotion: reduceMotion))
        .disabled(config.isDisabled)
    }
    
    // MARK: - Haptic Feedback
    
    private func triggerHaptic() {
        guard config.hapticFeedback else { return }
        
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: config.hapticStyle.uiStyle)
        generator.impactOccurred()
        #endif
    }
}

// MARK: - Fluent Modifiers

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension PTapGesture {
    
    /// Set the scale effect when pressed
    /// - Parameter scale: Scale value (0.0-1.0, default 0.96)
    func scaleEffect(_ scale: CGFloat) -> PTapGesture {
        var newConfig = config
        newConfig.scaleEffect = scale
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Set the opacity when pressed
    /// - Parameter opacity: Opacity value (0.0-1.0, 1.0 = no change)
    func opacityEffect(_ opacity: CGFloat) -> PTapGesture {
        var newConfig = config
        newConfig.opacityEffect = opacity
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Set the brightness adjustment when pressed
    /// - Parameter brightness: Brightness value (-1.0 to 1.0, 0.0 = no change)
    func brightnessEffect(_ brightness: Double) -> PTapGesture {
        var newConfig = config
        newConfig.brightnessEffect = brightness
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Enable or disable haptic feedback
    /// - Parameter enabled: Whether haptics are enabled
    func haptics(_ enabled: Bool) -> PTapGesture {
        var newConfig = config
        newConfig.hapticFeedback = enabled
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Set the haptic feedback style
    /// - Parameter style: Haptic style (.light, .medium, .heavy, .soft, .rigid)
    func hapticStyle(_ style: PTapGestureConfiguration.HapticStyle) -> PTapGesture {
        var newConfig = config
        newConfig.hapticStyle = style
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Configure press animation parameters
    /// - Parameters:
    ///   - response: Animation response time (lower = faster)
    ///   - damping: Animation damping fraction
    func pressAnimation(response: Double, damping: Double) -> PTapGesture {
        var newConfig = config
        newConfig.pressResponse = response
        newConfig.pressDamping = damping
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Configure release animation parameters
    /// - Parameters:
    ///   - response: Animation response time (lower = faster)
    ///   - damping: Animation damping fraction (lower = bouncier)
    func releaseAnimation(response: Double, damping: Double) -> PTapGesture {
        var newConfig = config
        newConfig.releaseResponse = response
        newConfig.releaseDamping = damping
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Set the minimum press duration (ensures press animation is visible)
    /// - Parameter duration: Minimum seconds the press state is shown
    func minimumPressDuration(_ duration: Double) -> PTapGesture {
        var newConfig = config
        newConfig.minimumPressDuration = duration
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Disable the tap gesture
    func disabled(_ isDisabled: Bool = true) -> PTapGesture {
        var newConfig = config
        newConfig.isDisabled = isDisabled
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Use bouncy animation preset (more playful, visible bounce)
    func bouncy() -> PTapGesture {
        var newConfig = config
        newConfig.scaleEffect = 0.92
        newConfig.pressResponse = 0.15
        newConfig.pressDamping = 0.7
        newConfig.releaseResponse = 0.4
        newConfig.releaseDamping = 0.45
        newConfig.minimumPressDuration = 0.1
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Use subtle animation preset (minimal, elegant feedback)
    func subtle() -> PTapGesture {
        var newConfig = config
        newConfig.scaleEffect = 0.98
        newConfig.opacityEffect = 0.85
        newConfig.pressResponse = 0.15
        newConfig.pressDamping = 0.8
        newConfig.releaseResponse = 0.25
        newConfig.releaseDamping = 0.7
        newConfig.minimumPressDuration = 0.06
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Use prominent animation preset (strong, satisfying feedback)
    func prominent() -> PTapGesture {
        var newConfig = config
        newConfig.scaleEffect = 0.9
        newConfig.pressResponse = 0.12
        newConfig.pressDamping = 0.75
        newConfig.releaseResponse = 0.45
        newConfig.releaseDamping = 0.4
        newConfig.minimumPressDuration = 0.12
        newConfig.hapticStyle = .medium
        return PTapGesture(action: action, config: newConfig)
    }
    
    /// Use snappy animation preset (quick response, subtle bounce)
    func snappy() -> PTapGesture {
        var newConfig = config
        newConfig.scaleEffect = 0.95
        newConfig.pressResponse = 0.1
        newConfig.pressDamping = 0.8
        newConfig.releaseResponse = 0.3
        newConfig.releaseDamping = 0.6
        newConfig.minimumPressDuration = 0.05
        return PTapGesture(action: action, config: newConfig)
    }
}

// MARK: - View Extension

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Add a Family.co-style tap gesture with fluid press animation
    /// - Parameter action: Closure to execute on tap
    /// - Returns: Modified view with tap gesture
    func pTapGesture(action: @escaping () -> Void) -> ModifiedContent<Self, PTapGesture> {
        modifier(PTapGesture(action: action))
    }
    
    /// Add a Family.co-style tap gesture with custom configuration
    /// - Parameters:
    ///   - config: Tap gesture configuration
    ///   - action: Closure to execute on tap
    /// - Returns: Modified view with tap gesture
    func pTapGesture(
        config: PTapGestureConfiguration,
        action: @escaping () -> Void
    ) -> ModifiedContent<Self, PTapGesture> {
        modifier(PTapGesture(action: action, config: config))
    }
}

// MARK: - Convenience Extensions for Common Patterns

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public extension View {
    
    /// Add a bouncy tap gesture (more playful animation with visible bounce)
    /// - Parameter action: Closure to execute on tap
    /// - Returns: Modified view with bouncy tap gesture
    func pTapGestureBouncy(action: @escaping () -> Void) -> ModifiedContent<Self, PTapGesture> {
        modifier(PTapGesture(action: action).bouncy())
    }
    
    /// Add a subtle tap gesture (minimal, elegant feedback)
    /// - Parameter action: Closure to execute on tap
    /// - Returns: Modified view with subtle tap gesture
    func pTapGestureSubtle(action: @escaping () -> Void) -> ModifiedContent<Self, PTapGesture> {
        modifier(PTapGesture(action: action).subtle())
    }
    
    /// Add a prominent tap gesture (strong, satisfying feedback)
    /// - Parameter action: Closure to execute on tap
    /// - Returns: Modified view with prominent tap gesture
    func pTapGestureProminent(action: @escaping () -> Void) -> ModifiedContent<Self, PTapGesture> {
        modifier(PTapGesture(action: action).prominent())
    }
    
    /// Add a snappy tap gesture (quick response, subtle bounce)
    /// - Parameter action: Closure to execute on tap
    /// - Returns: Modified view with snappy tap gesture
    func pTapGestureSnappy(action: @escaping () -> Void) -> ModifiedContent<Self, PTapGesture> {
        modifier(PTapGesture(action: action).snappy())
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, macOS 13.0, *)
struct PTapGesture_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Animation Presets
                Group {
                    Text("Animation Presets")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 12) {
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Text("Default")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                )
                                .pTapGesture { print("Default!") }
                            Text("Standard")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Text("Bouncy")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                )
                                .pTapGestureBouncy { print("Bouncy!") }
                            Text("Playful")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.orange)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Text("Snappy")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                )
                                .pTapGestureSnappy { print("Snappy!") }
                            Text("Quick")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Text("Bold")
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                )
                                .pTapGestureProminent { print("Prominent!") }
                            Text("Strong")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Divider()
                
                // Card Example
                Group {
                    Text("Card with Tap Gesture")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.purple)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Featured Item")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Tap anywhere on the card")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                    .pTapGesture { print("Card tapped!") }
                }
                
                Divider()
                
                // Custom Configurations
                Group {
                    Text("Custom Configurations")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.indigo)
                                .frame(width: 60, height: 60)
                                .modifier(
                                    PTapGesture { }
                                        .scaleEffect(0.85)
                                        .releaseAnimation(response: 0.5, damping: 0.35)
                                )
                            Text("Extra\nBounce")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 60, height: 60)
                                .modifier(
                                    PTapGesture { }
                                        .scaleEffect(0.98)
                                        .opacityEffect(0.6)
                                )
                            Text("Opacity\nFade")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 4) {
                            Circle()
                                .fill(Color.pink)
                                .frame(width: 60, height: 60)
                                .modifier(
                                    PTapGesture { }
                                        .brightnessEffect(-0.2)
                                        .scaleEffect(0.94)
                                )
                            Text("Darken\nPress")
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                
                Divider()
                
                // Scroll Test - NFT Gallery
                Group {
                    Text("Scroll Test - NFT Gallery")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Scrolling works while tap gestures are active")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(0..<9) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hue: Double(index) * 0.1, saturation: 0.7, brightness: 0.9),
                                            Color(hue: Double(index) * 0.1 + 0.1, saturation: 0.8, brightness: 0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .aspectRatio(1, contentMode: .fit)
                                .overlay(
                                    Text("#\(index + 1)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .pTapGestureBouncy { print("NFT #\(index + 1) tapped!") }
                        }
                    }
                }
                
                // Extra content for scroll testing
                ForEach(0..<5) { i in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 60)
                        .overlay(
                            Text("Scroll item \(i + 1)")
                                .foregroundColor(.secondary)
                        )
                        .pTapGestureSubtle { print("Item \(i + 1)") }
                }
            }
            .padding(20)
        }
        .background(Color(hex: "#F8F9FA"))
        .previewDisplayName("Tap Gesture - Family Style")
    }
}
#endif

