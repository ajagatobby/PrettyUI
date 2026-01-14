//
//  PrettyUI.swift
//  PrettyUI
//
//  A customizable SwiftUI component library with file-based theming.
//
//  Usage:
//  1. Create your custom theme:
//     ```swift
//     extension PrettyTheme {
//         static let myTheme = PrettyTheme(
//             colors: ColorTokens(
//                 primary: Color(hex: "#6366F1"),
//                 // ... customize all colors
//             )
//         )
//     }
//     ```
//
//  2. Apply the theme to your app:
//     ```swift
//     @main
//     struct MyApp: App {
//         var body: some Scene {
//             WindowGroup {
//                 ContentView()
//                     .prettyTheme(.myTheme)
//             }
//         }
//     }
//     ```
//
//  3. Use components:
//     ```swift
//     PButton("Click me") { }
//     PCard { Text("Content") }
//     PTextField("Email", text: $email)
//     ```

// MARK: - Core Theme

@_exported import SwiftUI

// Theme
public typealias Theme = PrettyTheme

// MARK: - Re-exports for cleaner imports

// Tokens
public typealias Colors = ColorTokens
public typealias Spacing = SpacingTokens
public typealias Radius = RadiusTokens
public typealias Typography = TypographyTokens
public typealias Shadows = ShadowTokens

// Component Configs
public typealias Components = ComponentConfigs

// Enums
public typealias ButtonVariant = PButtonVariant
public typealias ButtonSize = PButtonSize
public typealias TextFieldSize = PTextFieldSize
public typealias AvatarSize = PAvatarSize
public typealias AvatarShape = PAvatarShape
public typealias AvatarStatus = PAvatarStatus
public typealias CardVariant = PCardVariant
public typealias ListStyle = PListStyle
public typealias ListDividerStyle = PListDividerStyle
public typealias ListAccessory = PListAccessory
public typealias SkeletonShape = PSkeletonShape
public typealias TextStyle = PTextStyle
public typealias TextColor = PTextColor
public typealias SpinnerSize = PSpinnerSize
public typealias SpinnerStyle = PSpinnerStyle
public typealias AlertVariant = PAlertVariant
public typealias AlertStyle = PAlertStyle
public typealias ModalVariant = PModalVariant
public typealias ModalPosition = PModalPosition
public typealias ModalOverlayStyle = PModalOverlayStyle
public typealias ModalButton = PModalButton

// Expandable FAB (iOS/tvOS/watchOS only - uses fullScreenCover)
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
public typealias ExpandableFAB = PExpandableFAB
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
public typealias ExpandableFABConfiguration = PExpandableFABConfiguration
@available(iOS 17.0, tvOS 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
public typealias FABMenuItem = PFABMenuItem

// Modal (Dialog)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ModalContent = PModalContent
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ModalConfiguration = PModalConfiguration

// Tooltip
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias Tooltip = PTooltip
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TooltipPosition = PTooltipPosition
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TooltipConfiguration = PTooltipConfiguration
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TooltipSuggestions = PTooltipSuggestions
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TooltipRichContent = PTooltipRichContent

// Popover (Interactive Content Anchored to Trigger)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias Popover = PPopover
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverPosition = PPopoverPosition
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverArrowAlignment = PPopoverArrowAlignment
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverStyle = PPopoverStyle
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverConfiguration = PPopoverConfiguration
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverMenu = PPopoverMenu
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverMenuItem = PPopoverMenuItem
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverMenuDivider = PPopoverMenuDivider
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PopoverRootModifier = PPopoverRootModifier

// Toast (Ephemeral Notifications)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias Toast = PToastContent
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ToastVariant = PToastVariant
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ToastPosition = PToastPosition
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ToastManager = PToastManager
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ToastItem = PToastItem
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias ToastConfiguration = PToastConfiguration

// Top Tab (Horizontal Section Navigation)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTab = PTopTab
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabList = PTopTabList
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabTrigger = PTopTabTrigger
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabPane = PTopTabPane
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabContent = PTopTabContent
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabStyle = PTopTabStyle
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabSize = PTopTabSize
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias TopTabTransition = PTopTabTransition

// Bottom Tab (Bottom Navigation Bar)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTab = PBottomTab
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabList = PBottomTabList
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabTrigger = PBottomTabTrigger
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabPane = PBottomTabPane
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabContent = PBottomTabContent
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabStyle = PBottomTabStyle
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabSize = PBottomTabSize
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias BottomTabTransition = PBottomTabTransition

// TapGesture (Family-Style Press Animation)
// Note: Using "Pressable" to avoid conflict with SwiftUI.TapGesture
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias Pressable = PTapGesture
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias PressableConfiguration = PTapGestureConfiguration

// Accordion (Collapsible Content Sections)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias Accordion = PAccordion
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias AccordionItem = PAccordionItem
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias StandaloneAccordionItem = PStandaloneAccordionItem
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias AccordionVariant = PAccordionVariant
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias AccordionExpansionMode = PAccordionExpansionMode

// TextField Variants (Additional Input Components)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias LabeledTextField = PLabeledTextField
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias SearchField = PSearchField

// Card Subcomponents (Header, Footer, Title)
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias CardHeader = PCardHeader
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias CardFooter = PCardFooter
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public typealias CardTitle = PCardTitle
