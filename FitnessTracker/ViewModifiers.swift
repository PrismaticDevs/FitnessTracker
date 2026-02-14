import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct AppBranding: ViewModifier {
    @AppStorage("selectedTheme") var currentTheme: AppTheme = .magenta
    
    func body(content: Content) -> some View {
        content
            .applyGradientBackground()
            .tint(currentTheme.accent)
            .onAppear {
                currentTheme.applyGlobalTint()
            }
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
        #if canImport(UIKit)
        let uiColor = UIColor(self.accent)

        // Keep default tint for regular nav bar items (icons/controls)
        UINavigationBar.appearance().tintColor = uiColor
        UIBarButtonItem.appearance().tintColor = uiColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]

        // --- Back button styling: white chevron on an accent-colored capsule ---
        // 1) White chevron (use alwaysOriginal so it doesn't inherit tintColor)
        if let whiteChevron = UIImage(systemName: "chevron.left")?.withTintColor(.white, renderingMode: .alwaysOriginal) {
            UINavigationBar.appearance().backIndicatorImage = whiteChevron
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = whiteChevron
        }

        // 2) Capsule background for the back button (resizable so it scales with title)
        let capsule = UIImage.rounded(cornerRadius: 14, color: uiColor, size: CGSize(width: 44, height: 28))
        let resizableCapsule = capsule.resizableImage(
            withCapInsets: UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14),
            resizingMode: .stretch
        )
        // Apply only to the back button (keeps other bar buttons unaffected)
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(resizableCapsule, for: .normal, barMetrics: .default)
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(resizableCapsule, for: .highlighted, barMetrics: .default)

        // 3) Ensure the back button title + chevron are white while other button titles remain accent
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: uiColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: uiColor]
        appearance.setBackIndicatorImage(UIImage(systemName: "chevron.left")?.withTintColor(.white, renderingMode: .alwaysOriginal),
                                         transitionMaskImage: UIImage(systemName: "chevron.left")?.withTintColor(.white, renderingMode: .alwaysOriginal))
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: uiColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Slightly nudge the back-title so it sits nicely inside the capsule
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -6, vertical: 0), for: .default)
        #else
        // No-op on non-UIKit platforms
        #endif
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
        #if canImport(UIKit)
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
        #else
        return self
        #endif
    }
}

extension View {
    func brandedBackButton(theme: AppTheme, dismiss: DismissAction) -> some View {
        self
            .navigationBarBackButtonHidden(true)
            // 1. Hide the system bar background entirely
            #if os(iOS)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .edgesIgnoringSafeArea(.top)
            // 2. Overlay our own button at the top
            .overlay(alignment: .topLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 26, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(theme.accent)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 5, y: 3)
                }
                .padding(.leading, 16)
                .padding(.top, 10) // Adjust based on the iPhone notch/island
            }
    }
}

#if canImport(UIKit)
private extension UIImage {
    static func rounded(cornerRadius: CGFloat, color: UIColor, size: CGSize = CGSize(width: 44, height: 28)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            color.setFill()
            path.fill()
        }.withRenderingMode(.alwaysOriginal)
    }
}
#endif
