//
//  ThemeColors.swift
//  FitnessTracker
//
//  Light/dark appearance and semantic colors that adapt to it.
//
//  Use these instead of hardcoded `.white` / `.white.opacity(x)`:
//
//    .textPrimary     main text and icons on backgrounds/cards   (was .white)
//    .textSecondary   captions, dates, supporting text            (was .white.opacity(0.6–0.8))
//    .textTertiary    hints, placeholders, disabled text          (was .white.opacity(0.4–0.5))
//    .onAccent        text/icons on an accent-filled button/bar   (always white)
//    .fillSubtle      faint fill behind chips/inputs              (was .white.opacity(0.05–0.12))
//    .fillStrong      stronger fill / pressed state               (was .white.opacity(0.15–0.3))
//    .strokeSubtle    hairline borders and separators
//    .shadowColor     drop shadows                                (was .black.opacity(0.3–0.4))
//
//  Theme colors (`theme.currentTheme.accent2`, `.gradientColors`, `.cardBackground`)
//  also adapt on their own.
//

import SwiftUI
import UIKit

// MARK: - Appearance setting

enum AppAppearance: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Adaptive color helpers

extension UIColor {
    /// A color that resolves to `light` or `dark` depending on the current appearance.
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traits in traits.userInterfaceStyle == .dark ? dark : light }
    }

    /// Mixes this color toward `other` by `amount` (0 = self, 1 = other).
    func mixed(with other: UIColor, amount: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = min(max(amount, 0), 1)
        return UIColor(red: r1 + (r2 - r1) * t,
                       green: g1 + (g2 - g1) * t,
                       blue: b1 + (b2 - b1) * t,
                       alpha: a1 + (a2 - a1) * t)
    }

    static let appTextPrimary   = UIColor(light: UIColor(white: 0.08, alpha: 1), dark: .white)
    static let appTextSecondary = UIColor(light: UIColor(white: 0, alpha: 0.62), dark: UIColor(white: 1, alpha: 0.72))
    static let appTextTertiary  = UIColor(light: UIColor(white: 0, alpha: 0.42), dark: UIColor(white: 1, alpha: 0.5))
    static let appFillSubtle    = UIColor(light: UIColor(white: 0, alpha: 0.05), dark: UIColor(white: 1, alpha: 0.1))
    static let appFillStrong    = UIColor(light: UIColor(white: 0, alpha: 0.1), dark: UIColor(white: 1, alpha: 0.2))
    static let appStrokeSubtle  = UIColor(light: UIColor(white: 0, alpha: 0.1), dark: UIColor(white: 1, alpha: 0.12))
    static let appShadow        = UIColor(light: UIColor(white: 0, alpha: 0.14), dark: UIColor(white: 0, alpha: 0.35))
}

extension ShapeStyle where Self == Color {
    static var textPrimary: Color   { Color(uiColor: .appTextPrimary) }
    static var textSecondary: Color { Color(uiColor: .appTextSecondary) }
    static var textTertiary: Color  { Color(uiColor: .appTextTertiary) }
    static var onAccent: Color      { .white }
    static var fillSubtle: Color    { Color(uiColor: .appFillSubtle) }
    static var fillStrong: Color    { Color(uiColor: .appFillStrong) }
    static var strokeSubtle: Color  { Color(uiColor: .appStrokeSubtle) }
    static var shadowColor: Color   { Color(uiColor: .appShadow) }
}
