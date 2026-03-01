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
            .navigationBarTitleTextColor(.white)
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
    
    var accent: Color {
        switch self {
        case .magenta: return Color(red: 0.78, green: 0.08, blue: 0.52)
        case .blue:    return Color(red: 0.1, green: 0.3, blue: 0.6)
        case .forest:  return Color(red: 0.1, green: 0.4, blue: 0.2)
        case .crimson: return Color(red: 0.7, green: 0.0, blue: 0.0)
        case .slate:   return Color(red: 0.2, green: 0.25, blue: 0.3)
        case .coffee:  return Color(red: 0.35, green: 0.25, blue: 0.2)
        }
    }
    
    var accent2: Color {
        switch self {
        case .magenta: return Color(red: 0.45, green: 0.01, blue: 0.35)
        case .blue:    return Color(red: 0.05, green: 0.15, blue: 0.4)
        case .forest:  return Color(red: 0.05, green: 0.2, blue: 0.1)
        case .crimson: return Color(red: 0.4, green: 0.0, blue: 0.0)
        case .slate:   return Color(red: 0.1, green: 0.12, blue: 0.15)
        case .coffee:  return Color(red: 0.2, green: 0.15, blue: 0.1)
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .magenta: return [Color(red: 1.0, green: 0.71, blue: 0.76), accent]
        case .blue:    return [Color.cyan.opacity(0.5), accent]
        case .forest:  return [Color.green.opacity(0.4), accent]
        case .crimson: return [Color.orange.opacity(0.4), accent]
        case .slate:   return [Color.gray.opacity(0.5), accent]
        case .coffee:  return [Color(red: 0.6, green: 0.5, blue: 0.4).opacity(0.5), accent]
        }
    }
}

// Global Theme Manager
class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var currentTheme: AppTheme = .magenta
    
    static let shared = ThemeManager()
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
                .foregroundColor(.white)
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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // Keeps your gradient visible
        
        let uiColor = UIColor(color)
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
                        .foregroundColor(.white)
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
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(theme.accent)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
        }
    }
}
