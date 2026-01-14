//
//  ComponentConfigs.swift
//  PrettyUI
//
//  Created by PrettyUI on 2026.
//

import SwiftUI

/// Configuration for all components - customize default behavior
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ComponentConfigs: Equatable, Sendable {
    public var button: ButtonConfig
    public var iconButton: IconButtonConfig
    public var card: CardConfig
    public var textField: TextFieldConfig
    public var tooltip: TooltipConfig
    public var list: ListConfig
    public var skeleton: SkeletonConfig
    public var avatar: AvatarConfig
    public var spinner: SpinnerConfig
    public var alert: AlertConfig
    public var sheet: SheetConfig
    public var modal: ModalConfig
    public var toast: ToastConfig
    public var tab: TabConfig
    public var accordion: AccordionConfig
    public var popover: PopoverConfig
    public var sidebar: SidebarConfig
    
    public init(
        button: ButtonConfig = .default,
        iconButton: IconButtonConfig = .default,
        card: CardConfig = .default,
        textField: TextFieldConfig = .default,
        tooltip: TooltipConfig = .default,
        list: ListConfig = .default,
        skeleton: SkeletonConfig = .default,
        avatar: AvatarConfig = .default,
        spinner: SpinnerConfig = .default,
        alert: AlertConfig = .default,
        sheet: SheetConfig = .default,
        modal: ModalConfig = .default,
        toast: ToastConfig = .default,
        tab: TabConfig = .default,
        accordion: AccordionConfig = .default,
        popover: PopoverConfig = .default,
        sidebar: SidebarConfig = .default
    ) {
        self.button = button
        self.iconButton = iconButton
        self.card = card
        self.textField = textField
        self.tooltip = tooltip
        self.list = list
        self.skeleton = skeleton
        self.avatar = avatar
        self.spinner = spinner
        self.alert = alert
        self.sheet = sheet
        self.modal = modal
        self.toast = toast
        self.tab = tab
        self.accordion = accordion
        self.popover = popover
        self.sidebar = sidebar
    }
    
    public static let `default` = ComponentConfigs()
}

// MARK: - Button Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ButtonConfig: Equatable, Sendable {
    /// Default button variant
    public var defaultVariant: PButtonVariant
    
    /// Default button size
    public var defaultSize: PButtonSize
    
    /// Default border radius
    public var radius: RadiusSize
    
    /// Animation duration for interactions
    public var animationDuration: Double
    
    /// Whether to show press animation
    public var showPressAnimation: Bool
    
    /// Default spinner size for loading state
    public var defaultSpinnerSize: PSpinnerSize
    
    public init(
        defaultVariant: PButtonVariant = .primary,
        defaultSize: PButtonSize = .lg,
        radius: RadiusSize = .full,
        animationDuration: Double = 0.25,
        showPressAnimation: Bool = true,
        defaultSpinnerSize: PSpinnerSize = .md
    ) {
        self.defaultVariant = defaultVariant
        self.defaultSize = defaultSize
        self.radius = radius
        self.animationDuration = animationDuration
        self.showPressAnimation = showPressAnimation
        self.defaultSpinnerSize = defaultSpinnerSize
    }
    
    /// Default Family-style button configuration
    public static let `default` = ButtonConfig()
}

// MARK: - Icon Button Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct IconButtonConfig: Equatable, Sendable {
    /// Default icon button variant
    public var defaultVariant: PButtonVariant
    
    /// Default icon button size
    public var defaultSize: PIconButtonSizeConfig
    
    /// Whether to show press animation
    public var showPressAnimation: Bool
    
    /// Animation duration for interactions
    public var animationDuration: Double
    
    /// Whether to provide haptic feedback on tap
    public var hapticFeedback: Bool
    
    public init(
        defaultVariant: PButtonVariant = .ghost,
        defaultSize: PIconButtonSizeConfig = .md,
        showPressAnimation: Bool = true,
        animationDuration: Double = 0.25,
        hapticFeedback: Bool = true
    ) {
        self.defaultVariant = defaultVariant
        self.defaultSize = defaultSize
        self.showPressAnimation = showPressAnimation
        self.animationDuration = animationDuration
        self.hapticFeedback = hapticFeedback
    }
    
    /// Default Family-style icon button configuration
    public static let `default` = IconButtonConfig()
}

/// Icon button size configuration options
public enum PIconButtonSizeConfig: String, Equatable, Sendable, CaseIterable {
    /// Small (32pt)
    case sm
    /// Medium (40pt) - default
    case md
    /// Large (48pt)
    case lg
    /// Extra large (56pt)
    case xl
    
    /// The dimension for this size
    public var dimension: CGFloat {
        switch self {
        case .sm: return 32
        case .md: return 40
        case .lg: return 48
        case .xl: return 56
        }
    }
    
    /// Icon size for this button size
    public var iconSize: CGFloat {
        switch self {
        case .sm: return 14
        case .md: return 17
        case .lg: return 20
        case .xl: return 24
        }
    }
}

/// Button variants
public enum PButtonVariant: String, Equatable, Sendable, CaseIterable {
    case primary
    case secondary
    case destructive
    case outline
    case ghost
    case link
}

/// Button sizes
public enum PButtonSize: String, Equatable, Sendable, CaseIterable {
    case sm
    case md
    case lg
    case icon
}

// MARK: - Card Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct CardConfig: Equatable, Sendable {
    /// Default border radius
    public var radius: RadiusSize
    
    /// Default shadow
    public var shadow: ShadowSize
    
    /// Default padding
    public var padding: SpacingSize
    
    /// Whether to show border
    public var showBorder: Bool
    
    /// Border width
    public var borderWidth: CGFloat
    
    public init(
        radius: RadiusSize = .lg,
        shadow: ShadowSize = .sm,
        padding: SpacingSize = .lg,
        showBorder: Bool = true,
        borderWidth: CGFloat = 1
    ) {
        self.radius = radius
        self.shadow = shadow
        self.padding = padding
        self.showBorder = showBorder
        self.borderWidth = borderWidth
    }
    
    public static let `default` = CardConfig()
}

// MARK: - TextField Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TextFieldConfig: Equatable, Sendable {
    /// Default border radius
    public var radius: RadiusSize
    
    /// Default size
    public var defaultSize: PTextFieldSize
    
    /// Border width
    public var borderWidth: CGFloat
    
    /// Focus ring width
    public var focusRingWidth: CGFloat
    
    /// Animation duration
    public var animationDuration: Double
    
    public init(
        radius: RadiusSize = .md,
        defaultSize: PTextFieldSize = .md,
        borderWidth: CGFloat = 1,
        focusRingWidth: CGFloat = 2,
        animationDuration: Double = 0.2
    ) {
        self.radius = radius
        self.defaultSize = defaultSize
        self.borderWidth = borderWidth
        self.focusRingWidth = focusRingWidth
        self.animationDuration = animationDuration
    }
    
    public static let `default` = TextFieldConfig()
}

/// TextField sizes
public enum PTextFieldSize: String, Equatable, Sendable, CaseIterable {
    case sm
    case md
    case lg
}

// MARK: - Tooltip Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TooltipConfig: Equatable, Sendable {
    /// Default border radius
    public var radius: RadiusSize
    
    /// Default padding
    public var padding: SpacingSize
    
    /// Arrow size
    public var arrowSize: CGFloat
    
    /// Animation duration
    public var animationDuration: Double
    
    /// Delay before showing
    public var showDelay: Double
    
    public init(
        radius: RadiusSize = .md,
        padding: SpacingSize = .sm,
        arrowSize: CGFloat = 6,
        animationDuration: Double = 0.15,
        showDelay: Double = 0.5
    ) {
        self.radius = radius
        self.padding = padding
        self.arrowSize = arrowSize
        self.animationDuration = animationDuration
        self.showDelay = showDelay
    }
    
    public static let `default` = TooltipConfig()
}

// MARK: - List Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ListConfig: Equatable, Sendable {
    /// Default list style
    public var defaultStyle: PListStyleConfig
    
    /// Default divider style
    public var dividerStyle: PListDividerStyleConfig
    
    /// Default item padding
    public var itemPadding: SpacingSize
    
    /// Corner radius for grouped lists
    public var radius: RadiusSize
    
    /// Whether to show item separators
    public var showDividers: Bool
    
    public init(
        defaultStyle: PListStyleConfig = .insetGrouped,
        dividerStyle: PListDividerStyleConfig = .inset,
        itemPadding: SpacingSize = .md,
        radius: RadiusSize = .xl,
        showDividers: Bool = true
    ) {
        self.defaultStyle = defaultStyle
        self.dividerStyle = dividerStyle
        self.itemPadding = itemPadding
        self.radius = radius
        self.showDividers = showDividers
    }
    
    public static let `default` = ListConfig()
}

/// List style configuration options (matches PListStyle but Sendable-safe)
public enum PListStyleConfig: String, Equatable, Sendable, CaseIterable {
    case grouped
    case insetGrouped
    case plain
}

/// Divider style configuration options (matches PListDividerStyle but Sendable-safe)
public enum PListDividerStyleConfig: String, Equatable, Sendable, CaseIterable {
    case full
    case inset
    case none
}

// MARK: - Skeleton Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SkeletonConfig: Equatable, Sendable {
    /// Default corner radius for skeleton shapes
    public var radius: RadiusSize
    
    /// Animation duration for shimmer effect
    public var animationDuration: Double
    
    /// Default line height for text skeletons
    public var lineHeight: CGFloat
    
    /// Default spacing between skeleton lines
    public var lineSpacing: CGFloat
    
    /// Last line width ratio (0-1)
    public var lastLineWidth: CGFloat
    
    public init(
        radius: RadiusSize = .md,
        animationDuration: Double = 1.5,
        lineHeight: CGFloat = 14,
        lineSpacing: CGFloat = 8,
        lastLineWidth: CGFloat = 0.7
    ) {
        self.radius = radius
        self.animationDuration = animationDuration
        self.lineHeight = lineHeight
        self.lineSpacing = lineSpacing
        self.lastLineWidth = lastLineWidth
    }
    
    public static let `default` = SkeletonConfig()
}

// MARK: - Avatar Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AvatarConfig: Equatable, Sendable {
    /// Default avatar size
    public var defaultSize: PAvatarSizeConfig
    
    /// Default avatar shape
    public var defaultShape: PAvatarShapeConfig
    
    /// Default border width when bordered
    public var borderWidth: CGFloat
    
    /// Status indicator size ratio relative to avatar size
    public var statusSizeRatio: CGFloat
    
    /// Badge minimum size
    public var badgeMinSize: CGFloat
    
    public init(
        defaultSize: PAvatarSizeConfig = .md,
        defaultShape: PAvatarShapeConfig = .circle,
        borderWidth: CGFloat = 2,
        statusSizeRatio: CGFloat = 0.25,
        badgeMinSize: CGFloat = 16
    ) {
        self.defaultSize = defaultSize
        self.defaultShape = defaultShape
        self.borderWidth = borderWidth
        self.statusSizeRatio = statusSizeRatio
        self.badgeMinSize = badgeMinSize
    }
    
    public static let `default` = AvatarConfig()
}

/// Avatar size configuration options (matches PAvatarSize)
public enum PAvatarSizeConfig: String, Equatable, Sendable, CaseIterable {
    case xs, sm, md, lg, xl
    
    /// The dimension for this size
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

/// Avatar shape configuration options (matches PAvatarShape)
public enum PAvatarShapeConfig: String, Equatable, Sendable, CaseIterable {
    case circle
    case rounded
}

// MARK: - Spinner Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SpinnerConfig: Equatable, Sendable {
    /// Default spinner size
    public var defaultSize: PSpinnerSizeConfig
    
    /// Animation duration for one full rotation
    public var animationDuration: Double
    
    /// Stroke width multiplier (relative to size)
    public var strokeWidthMultiplier: CGFloat
    
    public init(
        defaultSize: PSpinnerSizeConfig = .md,
        animationDuration: Double = 0.8,
        strokeWidthMultiplier: CGFloat = 1.0
    ) {
        self.defaultSize = defaultSize
        self.animationDuration = animationDuration
        self.strokeWidthMultiplier = strokeWidthMultiplier
    }
    
    public static let `default` = SpinnerConfig()
}

/// Spinner size configuration options
public enum PSpinnerSizeConfig: String, Equatable, Sendable, CaseIterable {
    case sm, md, lg, xl
}

// MARK: - Alert Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AlertConfig: Equatable, Sendable {
    /// Default alert variant
    public var defaultVariant: PAlertVariantConfig
    
    /// Border radius for alerts
    public var radius: RadiusSize
    
    /// Border width
    public var borderWidth: CGFloat
    
    /// Background opacity for alert backgrounds
    public var backgroundOpacity: Double
    
    /// Animation duration for show/hide
    public var animationDuration: Double
    
    public init(
        defaultVariant: PAlertVariantConfig = .info,
        radius: RadiusSize = .lg,
        borderWidth: CGFloat = 1,
        backgroundOpacity: Double = 0.1,
        animationDuration: Double = 0.25
    ) {
        self.defaultVariant = defaultVariant
        self.radius = radius
        self.borderWidth = borderWidth
        self.backgroundOpacity = backgroundOpacity
        self.animationDuration = animationDuration
    }
    
    public static let `default` = AlertConfig()
}

/// Alert variant configuration options
public enum PAlertVariantConfig: String, Equatable, Sendable, CaseIterable {
    case info
    case success
    case warning
    case error
}

// MARK: - Sheet Config

/// Configuration for bottom sheet presentation style
///
/// > Note: Reserved for future PSheet component. This configuration is provided
/// > to allow pre-configuration and ensure consistency when the sheet component
/// > is added. The config can be used with custom sheet implementations.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SheetConfig: Equatable, Sendable {
    /// Default border radius for sheet corners (Family guidelines: xxl = 28pt)
    public var radius: RadiusSize
    
    /// Whether to show the drag handle indicator
    public var showHandle: Bool
    
    /// Width of the drag handle
    public var handleWidth: CGFloat
    
    /// Height of the drag handle
    public var handleHeight: CGFloat
    
    /// Maximum height ratio relative to screen height (0.0-1.0)
    public var maxHeightRatio: CGFloat
    
    /// Minimum top padding from screen edge
    public var minTopPadding: CGFloat
    
    /// Spring animation response time
    public var springResponse: Double
    
    /// Spring animation damping fraction
    public var springDamping: Double
    
    /// Default content padding
    public var contentPadding: SpacingSize
    
    /// Whether to show close button in header
    public var showCloseButton: Bool
    
    public init(
        radius: RadiusSize = .xxl,
        showHandle: Bool = true,
        handleWidth: CGFloat = 36,
        handleHeight: CGFloat = 5,
        maxHeightRatio: CGFloat = 0.9,
        minTopPadding: CGFloat = 110,
        springResponse: Double = 0.35,
        springDamping: Double = 0.7,
        contentPadding: SpacingSize = .lg,
        showCloseButton: Bool = false
    ) {
        self.radius = radius
        self.showHandle = showHandle
        self.handleWidth = handleWidth
        self.handleHeight = handleHeight
        self.maxHeightRatio = maxHeightRatio
        self.minTopPadding = minTopPadding
        self.springResponse = springResponse
        self.springDamping = springDamping
        self.contentPadding = contentPadding
        self.showCloseButton = showCloseButton
    }
    
    /// Default Family-style sheet configuration
    public static let `default` = SheetConfig()
}

// MARK: - Modal Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ModalConfig: Equatable, Sendable {
    /// Default modal variant
    public var defaultVariant: PModalVariantConfig
    
    /// Default corner radius (Family guidelines: xxl = 28pt)
    public var radius: RadiusSize
    
    /// Maximum width for the modal card
    public var maxWidth: CGFloat
    
    /// Content padding inside the modal
    public var contentPadding: SpacingSize
    
    /// Whether to show the close button by default
    public var showCloseButton: Bool
    
    /// Whether tapping the backdrop dismisses the modal
    public var dismissOnBackgroundTap: Bool
    
    /// Backdrop opacity (0.0-1.0)
    public var backdropOpacity: Double
    
    /// Spring animation response time
    public var springResponse: Double
    
    /// Spring animation damping fraction
    public var springDamping: Double
    
    public init(
        defaultVariant: PModalVariantConfig = .standard,
        radius: RadiusSize = .xxl,
        maxWidth: CGFloat = 340,
        contentPadding: SpacingSize = .lg,
        showCloseButton: Bool = true,
        dismissOnBackgroundTap: Bool = true,
        backdropOpacity: Double = 0.5,
        springResponse: Double = 0.35,
        springDamping: Double = 0.7
    ) {
        self.defaultVariant = defaultVariant
        self.radius = radius
        self.maxWidth = maxWidth
        self.contentPadding = contentPadding
        self.showCloseButton = showCloseButton
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.backdropOpacity = backdropOpacity
        self.springResponse = springResponse
        self.springDamping = springDamping
    }
    
    /// Default Family-style modal configuration
    public static let `default` = ModalConfig()
}

/// Modal variant configuration options
public enum PModalVariantConfig: String, Equatable, Sendable, CaseIterable {
    case standard
    case destructive
    case success
    case warning
}

// MARK: - Toast Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ToastConfig: Equatable, Sendable {
    /// Default toast variant
    public var defaultVariant: PToastVariantConfig
    
    /// Default toast position
    public var defaultPosition: PToastPositionConfig
    
    /// Default auto-dismiss duration (nil = no auto-dismiss)
    public var defaultDuration: TimeInterval?
    
    /// Border radius for toasts (Family guidelines: xl = 20pt)
    public var radius: RadiusSize
    
    /// Maximum width for the toast
    public var maxWidth: CGFloat
    
    /// Whether to show progress bar by default
    public var showProgress: Bool
    
    /// Whether tapping dismisses the toast by default
    public var dismissOnTap: Bool
    
    /// Whether to provide haptic feedback
    public var hapticFeedback: Bool
    
    /// Spring animation response time
    public var springResponse: Double
    
    /// Spring animation damping fraction
    public var springDamping: Double
    
    public init(
        defaultVariant: PToastVariantConfig = .info,
        defaultPosition: PToastPositionConfig = .top,
        defaultDuration: TimeInterval? = 3.0,
        radius: RadiusSize = .xl,
        maxWidth: CGFloat = 400,
        showProgress: Bool = false,
        dismissOnTap: Bool = true,
        hapticFeedback: Bool = true,
        springResponse: Double = 0.28,
        springDamping: Double = 0.85
    ) {
        self.defaultVariant = defaultVariant
        self.defaultPosition = defaultPosition
        self.defaultDuration = defaultDuration
        self.radius = radius
        self.maxWidth = maxWidth
        self.showProgress = showProgress
        self.dismissOnTap = dismissOnTap
        self.hapticFeedback = hapticFeedback
        self.springResponse = springResponse
        self.springDamping = springDamping
    }
    
    /// Default Family-style toast configuration
    public static let `default` = ToastConfig()
}

/// Toast variant configuration options
public enum PToastVariantConfig: String, Equatable, Sendable, CaseIterable {
    case info
    case success
    case warning
    case error
}

/// Toast position configuration options
public enum PToastPositionConfig: String, Equatable, Sendable, CaseIterable {
    case top
    case bottom
}

// MARK: - Tab Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct TabConfig: Equatable, Sendable {
    /// Default tab variant
    public var defaultVariant: PTabVariantConfig
    
    /// Default tab size
    public var defaultSize: PTabSizeConfig
    
    /// Border radius for pill tabs (Family guidelines: full = pill shape)
    public var radius: RadiusSize
    
    /// Spring animation response time (controls animation speed)
    public var animationResponse: Double
    
    /// Spring animation damping fraction (controls bounciness)
    public var animationDamping: Double
    
    /// Whether to show press animation on tabs
    public var showPressAnimation: Bool
    
    public init(
        defaultVariant: PTabVariantConfig = .pill,
        defaultSize: PTabSizeConfig = .md,
        radius: RadiusSize = .full,
        animationResponse: Double = 0.35,
        animationDamping: Double = 0.7,
        showPressAnimation: Bool = true
    ) {
        self.defaultVariant = defaultVariant
        self.defaultSize = defaultSize
        self.radius = radius
        self.animationResponse = animationResponse
        self.animationDamping = animationDamping
        self.showPressAnimation = showPressAnimation
    }
    
    /// Default Family-style tab configuration
    public static let `default` = TabConfig()
}

/// Tab variant configuration options
public enum PTabVariantConfig: String, Equatable, Sendable, CaseIterable {
    /// Sliding pill background indicator (Family style)
    case pill
    /// Bottom border indicator that slides
    case underline
    /// No background, subtle color change only
    case minimal
}

/// Tab size configuration options
public enum PTabSizeConfig: String, Equatable, Sendable, CaseIterable {
    case sm
    case md
    case lg
}

// MARK: - Accordion Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct AccordionConfig: Equatable, Sendable {
    /// Default accordion variant
    public var defaultVariant: PAccordionVariantConfig
    
    /// Default expansion mode
    public var defaultExpansionMode: PAccordionExpansionModeConfig
    
    /// Border radius for accordion items (Family guidelines: xl = 20pt)
    public var radius: RadiusSize
    
    /// Spring animation response time (controls animation speed)
    public var springResponse: Double
    
    /// Spring animation damping fraction (controls bounciness)
    public var springDamping: Double
    
    /// Chevron rotation amount in degrees
    public var chevronRotation: Double
    
    /// Whether to show dividers between items
    public var showDividers: Bool
    
    /// Whether to provide haptic feedback on toggle
    public var hapticFeedback: Bool
    
    public init(
        defaultVariant: PAccordionVariantConfig = .standard,
        defaultExpansionMode: PAccordionExpansionModeConfig = .multiple,
        radius: RadiusSize = .xl,
        springResponse: Double = 0.35,
        springDamping: Double = 0.7,
        chevronRotation: Double = 180,
        showDividers: Bool = true,
        hapticFeedback: Bool = true
    ) {
        self.defaultVariant = defaultVariant
        self.defaultExpansionMode = defaultExpansionMode
        self.radius = radius
        self.springResponse = springResponse
        self.springDamping = springDamping
        self.chevronRotation = chevronRotation
        self.showDividers = showDividers
        self.hapticFeedback = hapticFeedback
    }
    
    /// Default Family-style accordion configuration
    public static let `default` = AccordionConfig()
}

/// Accordion variant configuration options
public enum PAccordionVariantConfig: String, Equatable, Sendable, CaseIterable {
    /// Connected items with shared background
    case standard
    /// Each item has a visible border
    case bordered
    /// Each item is a separate card with spacing between
    case separated
}

/// Accordion expansion mode configuration options
public enum PAccordionExpansionModeConfig: String, Equatable, Sendable, CaseIterable {
    /// Only one item can be expanded at a time
    case single
    /// Multiple items can be expanded simultaneously
    case multiple
}

// MARK: - Popover Config

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct PopoverConfig: Equatable, Sendable {
    /// Default border radius (Family guidelines: xl = 20pt)
    public var radius: RadiusSize
    
    /// Default content padding
    public var padding: SpacingSize
    
    /// Arrow size (width/height)
    public var arrowSize: CGFloat
    
    /// Distance from anchor element
    public var offset: CGFloat
    
    /// Maximum width for the popover
    public var maxWidth: CGFloat?
    
    /// Whether to show arrow by default
    public var showArrow: Bool
    
    /// Whether tapping outside dismisses the popover
    public var dismissOnOutsideTap: Bool
    
    /// Backdrop opacity (0.0-1.0) - very subtle by default for tap dismissal
    public var backdropOpacity: Double
    
    /// Spring animation response time
    public var springResponse: Double
    
    /// Spring animation damping fraction
    public var springDamping: Double
    
    /// Shadow size for floating effect
    public var shadow: ShadowSize
    
    public init(
        radius: RadiusSize = .xl,
        padding: SpacingSize = .md,
        arrowSize: CGFloat = 8,
        offset: CGFloat = 6,
        maxWidth: CGFloat? = nil,
        showArrow: Bool = true,
        dismissOnOutsideTap: Bool = true,
        backdropOpacity: Double = 0.01,
        springResponse: Double = 0.28,
        springDamping: Double = 0.82,
        shadow: ShadowSize = .md
    ) {
        self.radius = radius
        self.padding = padding
        self.arrowSize = arrowSize
        self.offset = offset
        self.maxWidth = maxWidth
        self.showArrow = showArrow
        self.dismissOnOutsideTap = dismissOnOutsideTap
        self.backdropOpacity = backdropOpacity
        self.springResponse = springResponse
        self.springDamping = springDamping
        self.shadow = shadow
    }
    
    /// Default Family-style popover configuration
    public static let `default` = PopoverConfig()
}

/// Popover position configuration options
public enum PPopoverPositionConfig: String, Equatable, Sendable, CaseIterable {
    /// Popover appears above the anchor
    case top
    /// Popover appears below the anchor
    case bottom
    /// Popover appears to the left of the anchor
    case leading
    /// Popover appears to the right of the anchor
    case trailing
}

/// Popover style configuration options
public enum PPopoverStyleConfig: String, Equatable, Sendable, CaseIterable {
    /// Light card background
    case light
    /// Dark inverted background
    case dark
}

// MARK: - Sidebar Config

/// Configuration for sidebar menu presentation
///
/// Family.co-inspired sidebar with smooth spring animations, gesture-based dismissal,
/// and flexible content structure supporting headers, navigation items, and footers.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct SidebarConfig: Equatable, Sendable {
    /// Default sidebar position (leading or trailing edge)
    public var defaultPosition: PSidebarPositionConfig
    
    /// Default sidebar style (full height or floating card)
    public var defaultStyle: PSidebarStyleConfig
    
    /// Width of the sidebar panel
    public var width: CGFloat
    
    /// Border radius for floating style (Family guidelines: xxl = 28pt)
    public var radius: RadiusSize
    
    /// Content padding inside the sidebar
    public var contentPadding: SpacingSize
    
    /// Margin from screen edge for floating style
    public var floatingMargin: CGFloat
    
    /// Whether tapping the backdrop dismisses the sidebar
    public var dismissOnBackgroundTap: Bool
    
    /// Backdrop opacity (0.0-1.0)
    public var backdropOpacity: Double
    
    /// Whether to enable drag-to-dismiss gesture
    public var enableDragToDismiss: Bool
    
    /// Drag threshold to trigger dismiss (in points)
    public var dragDismissThreshold: CGFloat
    
    /// Spring animation response time for panel entry
    public var springResponse: Double
    
    /// Spring animation damping fraction for panel entry
    public var springDamping: Double
    
    /// Exit animation duration
    public var exitAnimationDuration: Double
    
    /// Stagger delay between menu items (in seconds)
    public var itemStaggerDelay: Double
    
    /// Shadow size for floating style
    public var shadow: ShadowSize
    
    /// Whether to provide haptic feedback on open/close
    public var hapticFeedback: Bool
    
    public init(
        defaultPosition: PSidebarPositionConfig = .leading,
        defaultStyle: PSidebarStyleConfig = .fullHeight,
        width: CGFloat = 300,
        radius: RadiusSize = .xxl,
        contentPadding: SpacingSize = .lg,
        floatingMargin: CGFloat = 16,
        dismissOnBackgroundTap: Bool = true,
        backdropOpacity: Double = 0.5,
        enableDragToDismiss: Bool = true,
        dragDismissThreshold: CGFloat = 100,
        springResponse: Double = 0.35,
        springDamping: Double = 0.75,
        exitAnimationDuration: Double = 0.2,
        itemStaggerDelay: Double = 0.05,
        shadow: ShadowSize = .xl,
        hapticFeedback: Bool = true
    ) {
        self.defaultPosition = defaultPosition
        self.defaultStyle = defaultStyle
        self.width = width
        self.radius = radius
        self.contentPadding = contentPadding
        self.floatingMargin = floatingMargin
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.backdropOpacity = backdropOpacity
        self.enableDragToDismiss = enableDragToDismiss
        self.dragDismissThreshold = dragDismissThreshold
        self.springResponse = springResponse
        self.springDamping = springDamping
        self.exitAnimationDuration = exitAnimationDuration
        self.itemStaggerDelay = itemStaggerDelay
        self.shadow = shadow
        self.hapticFeedback = hapticFeedback
    }
    
    /// Default Family-style sidebar configuration
    public static let `default` = SidebarConfig()
}

/// Sidebar position configuration options
public enum PSidebarPositionConfig: String, Equatable, Sendable, CaseIterable {
    /// Sidebar slides in from the leading edge (left on LTR)
    case leading
    /// Sidebar slides in from the trailing edge (right on LTR)
    case trailing
}

/// Sidebar style configuration options
public enum PSidebarStyleConfig: String, Equatable, Sendable, CaseIterable {
    /// Full height edge-to-edge sidebar (classic style)
    case fullHeight
    /// Floating card with rounded corners and margin
    case floating
}

