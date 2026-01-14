# PrettyUI

A beautiful, customizable SwiftUI component library with a modern design system. Build friendly and delightful iOS, macOS, tvOS, and watchOS apps with ease.

## Features

- **Comprehensive Theme System** - Full control over colors, typography, spacing, radius, and shadows
- **Light & Dark Mode** - Automatic color scheme support with customizable palettes
- **Modern Design Language** - Soft edges, playful animations, and approachable aesthetics
- **20+ Components** - Buttons, Cards, TextFields, Modals, Toasts, Tabs, and more
- **Fluent API** - Clean, chainable modifiers for easy customization
- **Accessibility** - Reduced motion support and proper contrast ratios

## Requirements

- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+
- Swift 6.0+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add PrettyUI to your project via Xcode:

1. Go to **File → Add Package Dependencies...**
2. Enter the repository URL:
   ```
   https://github.com/mecurylabs/PrettyUI.git
   ```
3. Select your version rules and click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/mecurylabs/PrettyUI.git", from: "1.0.0")
]
```

## Quick Start

### 1. Apply a Theme

Apply a theme at the root of your app:

```swift
import SwiftUI
import PrettyUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .prettyTheme(.sky)
        }
    }
}
```

### 2. Use Components

```swift
import PrettyUI

struct ContentView: View {
    @State private var email = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            PText("Welcome Back")
                .style(.headline)

            PTextField("Email", text: $email)
                .leadingIcon("envelope")

            PButton("Sign In") {
                isLoading = true
            }
            .loading(isLoading)
            .fullWidth()
        }
        .padding()
    }
}
```

## Available Components

| Component     | Description                                              |
| ------------- | -------------------------------------------------------- |
| `PButton`     | Customizable button with variants, sizes, loading states |
| `PIconButton` | Circular icon-only button                                |
| `PCard`       | Container with shadows, borders, and press states        |
| `PTextField`  | Text input with floating labels, validation, icons       |
| `PText`       | Typography component with preset styles                  |
| `PAvatar`     | User avatar with images, initials, status indicators     |
| `PAlert`      | Inline notification banners                              |
| `PModal`      | Dialog/modal presentations                               |
| `PToast`      | Ephemeral notification toasts                            |
| `PTooltip`    | Contextual tooltips                                      |
| `PPopover`    | Interactive popovers anchored to triggers                |
| `PSpinner`    | Loading spinners with multiple styles                    |
| `PSkeleton`   | Content loading placeholders                             |
| `PList`       | Styled list containers                                   |
| `PTopTab`     | Horizontal tab navigation                                |
| `PBottomTab`  | Bottom navigation bar                                    |
| `PAccordion`  | Collapsible content sections                             |

## Theming

### Built-in Themes

```swift
.prettyTheme(.default)   // Neutral grayscale
.prettyTheme(.sky)       // Vibrant cyan-blue
.prettyTheme(.indigo)    // Purple/indigo accent
.prettyTheme(.emerald)   // Teal/green accent
.prettyTheme(.amber)     // Orange/amber accent
```

### Custom Theme

Create your own theme by extending `PrettyTheme`:

```swift
extension PrettyTheme {
    static let myBrand = PrettyTheme(
        colors: ColorTokens(
            primary: Color(hex: "#6366F1"),
            primaryForeground: Color(hex: "#FFFFFF"),
            secondary: Color(hex: "#F4F4F5"),
            secondaryForeground: Color(hex: "#18181B"),
            accent: Color(hex: "#8B5CF6"),
            accentForeground: Color(hex: "#FFFFFF"),
            destructive: Color(hex: "#EF4444"),
            destructiveForeground: Color(hex: "#FFFFFF"),
            success: Color(hex: "#22C55E"),
            successForeground: Color(hex: "#FFFFFF"),
            warning: Color(hex: "#F59E0B"),
            warningForeground: Color(hex: "#18181B"),
            background: Color(hex: "#FFFFFF"),
            foreground: Color(hex: "#09090B"),
            muted: Color(hex: "#F4F4F5"),
            mutedForeground: Color(hex: "#71717A"),
            card: Color(hex: "#FFFFFF"),
            cardForeground: Color(hex: "#09090B"),
            border: Color(hex: "#E4E4E7"),
            input: Color(hex: "#E4E4E7"),
            ring: Color(hex: "#6366F1")
        ),
        darkColors: ColorTokens(
            // ... dark mode colors
        ),
        radius: RadiusTokens(
            sm: 6, md: 10, lg: 14, xl: 20, xxl: 28
        ),
        typography: TypographyTokens(
            fontFamily: .custom("Avenir Next")
        ),
        components: ComponentConfigs(
            button: ButtonConfig(radius: .full, defaultSize: .lg),
            card: CardConfig(radius: .xl, shadow: .md)
        )
    )
}
```

## Design Tokens

### Spacing (8pt Grid)

| Token  | Value |
| ------ | ----- |
| `xxs`  | 2pt   |
| `xs`   | 4pt   |
| `sm`   | 8pt   |
| `md`   | 16pt  |
| `lg`   | 24pt  |
| `xl`   | 32pt  |
| `xxl`  | 48pt  |
| `xxxl` | 64pt  |

### Border Radius

| Token  | Value  | Usage                 |
| ------ | ------ | --------------------- |
| `none` | 0pt    | -                     |
| `sm`   | 6pt    | Small chips, tags     |
| `md`   | 10pt   | Inputs, small cards   |
| `lg`   | 14pt   | Standard cards        |
| `xl`   | 20pt   | Large cards, images   |
| `xxl`  | 28pt   | Modals, sheets        |
| `full` | 9999pt | Pill buttons, avatars |

### Shadows

| Token  | Usage                          |
| ------ | ------------------------------ |
| `none` | No shadow                      |
| `sm`   | Cards at rest                  |
| `md`   | Cards on hover/focus, tooltips |
| `lg`   | Floating elements              |
| `xl`   | Modals, sheets                 |
| `xxl`  | Popovers                       |

## Component Examples

### Buttons

```swift
// Primary button
PButton("Get Started")
    .variant(.primary)
    .icon("plus")
    .fullWidth()

// Loading state
PButton("Processing")
    .loading(true, text: "Please wait...")
    .loadingPosition(.trailing)

// Variants
PButton("Primary").variant(.primary)
PButton("Secondary").variant(.secondary)
PButton("Outline").variant(.outline)
PButton("Ghost").variant(.ghost)
PButton("Destructive").variant(.destructive)
```

### Cards

```swift
// Basic card
PCard {
    Text("Card content")
}

// Pressable card with selection
PCard {
    HStack {
        VStack(alignment: .leading) {
            Text("Main Wallet")
            Text("0x1234...5678").foregroundColor(.gray)
        }
        Spacer()
        Text("$10,234")
    }
}
.pressable { print("Tapped") }
.selected(isSelected)
.variant(.elevated)
```

### Text Fields

```swift
// With floating label and icon
PTextField("Email", text: $email)
    .leadingIcon("envelope")
    .keyboard(.emailAddress)

// Password with validation
PTextField("Password", text: $password)
    .secure()
    .leadingIcon("lock")
    .error(passwordError)

// Search field
PSearchField("Search...", text: $query)
```

## Accessing Theme Values

Use `ThemeReader` or environment to access theme tokens in custom views:

```swift
struct CustomView: View {
    @Environment(\.prettyTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors = theme.colors(for: colorScheme)

        Rectangle()
            .fill(colors.primary)
            .frame(height: theme.spacing.xl)
            .cornerRadius(theme.radius[.lg])
    }
}
```

## License

MIT License - see [LICENSE](LICENSE) for details.

---

Built with ❤️ by **Ajaga Abdulbasit**
