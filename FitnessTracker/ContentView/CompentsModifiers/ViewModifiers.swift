import SwiftUI

struct AppBranding: ViewModifier {
    @ObservedObject var theme = ThemeManager.shared
    
    func body(content: Content) -> some View {
        content
            .applyGradientBackground()
            .tint(theme.currentTheme.accent)
            .onAppear {
                theme.currentTheme.applyGlobalTint()
            }
            .navigationBarTitleTextColor(.appTextPrimary)
    }
}

extension View {
    /// Applies the global fitness tracker theme, toolbar transparency, and accent colors.
    func applyAppBranding() -> some View {
        self.modifier(AppBranding())
    }
}

extension AppTheme {
    func applyGlobalTint() {
        let uiColor = UIColor(self.accent)
        
        // This is the only UIKit part we still need for "Back" text color
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        // Forces the Back Button and other Bar Buttons to your accent
        UINavigationBar.appearance().tintColor = uiColor
        
        // Optional: If you want the "Back" text to be white but the chevron to be Accent:
        // appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

// Define your available Themes
enum AppTheme: String, CaseIterable, Identifiable {
    case magenta = "Deep Magenta"
    case blue = "Midnight Blue"
    case forest = "Forest Green"
    case crimson = "Racing Red"     // New
    case slate = "Slate Gray"       // New
    case coffee = "Rugged Brown"    // New
    
    var id: String { self.rawValue }

    // MARK: Base colors (UIKit, so they can be mixed and made light/dark adaptive)

    private var accentUI: UIColor {
        switch self {
        case .magenta: return UIColor(red: 0.78, green: 0.08, blue: 0.52, alpha: 1)
        case .blue:    return UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1)
        case .forest:  return UIColor(red: 0.1, green: 0.4, blue: 0.2, alpha: 1)
        case .crimson: return UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1)
        case .slate:   return UIColor(red: 0.2, green: 0.25, blue: 0.3, alpha: 1)
        case .coffee:  return UIColor(red: 0.35, green: 0.25, blue: 0.2, alpha: 1)
        }
    }

    private var darkAccent2UI: UIColor {
        switch self {
        case .magenta: return UIColor(red: 0.45, green: 0.01, blue: 0.35, alpha: 1)
        case .blue:    return UIColor(red: 0.05, green: 0.15, blue: 0.4, alpha: 1)
        case .forest:  return UIColor(red: 0.05, green: 0.2, blue: 0.1, alpha: 1)
        case .crimson: return UIColor(red: 0.4, green: 0.0, blue: 0.0, alpha: 1)
        case .slate:   return UIColor(red: 0.1, green: 0.12, blue: 0.15, alpha: 1)
        case .coffee:  return UIColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1)
        }
    }

    /// Lighter end of the dark-mode background gradient (unchanged from the original look).
    private var darkGradientTopUI: UIColor {
        switch self {
        case .magenta: return UIColor(red: 1.0, green: 0.71, blue: 0.76, alpha: 1)
        case .blue:    return UIColor.cyan.withAlphaComponent(0.5)
        case .forest:  return UIColor.green.withAlphaComponent(0.4)
        case .crimson: return UIColor.orange.withAlphaComponent(0.4)
        case .slate:   return UIColor.gray.withAlphaComponent(0.5)
        case .coffee:  return UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 0.5)
        }
    }

    // MARK: Public theme colors

    /// Brand color for buttons, bars and highlights. Same in light and dark; put `.onAccent` content on it.
    var accent: Color { Color(uiColor: accentUI) }

    /// Card / row / sheet background. Deep tone in dark mode, pale tint of the accent in light mode.
    var accent2: Color {
        Color(uiColor: UIColor(light: accentUI.mixed(with: .white, amount: 0.84), dark: darkAccent2UI))
    }

    /// Accent-colored text that stays readable on the background in both modes.
    var accentText: Color {
        Color(uiColor: UIColor(light: accentUI.mixed(with: .black, amount: 0.1), dark: accentUI.mixed(with: .white, amount: 0.35)))
    }

    /// Accent-tinted surface that holds regular text (inputs, list rows, report cards).
    /// Identical to `accent` in dark mode; a lighter tint in light mode so `.textPrimary` stays readable.
    /// For buttons and bars whose content is `.onAccent`, use `accent` instead.
    var accentSurface: Color {
        Color(uiColor: UIColor(light: accentUI.mixed(with: .white, amount: 0.72), dark: accentUI))
    }

    /// Chart bars: the original deep tone in dark mode, the full accent in light mode.
    var chartBar: Color {
        Color(uiColor: UIColor(light: accentUI, dark: darkAccent2UI))
    }

    /// Screen background gradient, ordered bottom → top.
    var gradientColors: [Color] {
        [
            Color(uiColor: UIColor(light: accentUI.mixed(with: .white, amount: 0.93), dark: darkGradientTopUI)),
            Color(uiColor: UIColor(light: accentUI.mixed(with: .white, amount: 0.7), dark: accentUI))
        ]
    }
}

// Global Theme Manager
class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var currentTheme: AppTheme = .magenta
    @AppStorage("appearance") var appearance: AppAppearance = .system {
        didSet { applyAppearance() }
    }

    static let shared = ThemeManager()

    /// Forces light/dark (or follows the system) on every window, including sheets.
    func applyAppearance() {
        let style = appearance.interfaceStyle
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }
    }
}

struct GradientBackground: ViewModifier {
    @ObservedObject var theme = ThemeManager.shared

    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: theme.currentTheme.gradientColors),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            content
                .foregroundColor(.textPrimary)
        }
    }
}

extension View {
    func applyGradientBackground() -> some View {
        self.modifier(GradientBackground())
    }
}

extension View {
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        navigationBarTitleTextColor(UIColor(color))
    }

    /// Pass a dynamic UIColor (e.g. `.appTextPrimary`) so the title adapts to light/dark.
    func navigationBarTitleTextColor(_ uiColor: UIColor) -> some View {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Keeps your gradient visible

        appearance.titleTextAttributes = [.foregroundColor: uiColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: uiColor]
        
        // This is the crucial part for Lists:
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        
        return self
    }
}

extension View {
    func brandedBackButton(title: String, theme: AppTheme, dismiss: DismissAction) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.top)
            .overlay(alignment: .top) {
                HStack(alignment: .center, spacing: 12) {
                    // 1. The Actual Back Button
                    backButton(theme: theme, dismiss: dismiss)
                    
                    // 2. Centered & Wrapping Title
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2) // Allows wrapping to 2 lines if needed
                        .minimumScaleFactor(0.8) // Shrinks slightly before wrapping
                        .frame(maxWidth: .infinity) // Occupies all available center space
                    
                    // 3. The "Ghost" Spacer
                    // We mirror the button's layout exactly so the title remains perfectly centered
                    backButton(theme: theme, dismiss: dismiss)
                        .opacity(0)
                        .disabled(true)
                        .accessibilityHidden(true)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
    }

    // Helper to keep the button code DRY and ensure identical sizing
    @ViewBuilder
    private func backButton(theme: AppTheme, dismiss: DismissAction) -> some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.onAccent)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(theme.accent)
                .clipShape(Capsule())
                .shadow(color: .shadowColor, radius: 5, y: 3)
        }
    }
}
