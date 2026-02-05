//
//  ViewModifiers.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/25.
//

import SwiftUI

// Color Palette
let crimson = Color(red: 0.64, green: 0.12, blue: 0.17)
let scarlet = Color(red: 0.86, green: 0.08, blue: 0.24)
let blush = Color(red: 1.0, green: 0.71, blue: 0.76)
let deepMagenta = Color(red: 0.78, green: 0.08, blue: 0.52)
let midnightOrchid = Color(red: 0.45, green: 0.01, blue: 0.35)
struct ColorPalette {
    static let primary: Color = .white
    static let secondary: Color = .gray
    static let accent: Color = deepMagenta
    static let accent2: Color = midnightOrchid
}

// Gradient Background Modifier
struct GradientBackground: ViewModifier {
    var gradient = LinearGradient(gradient: Gradient(colors: [blush, deepMagenta]), startPoint: .bottom, endPoint: .top)

    func body(content: Content) -> some View {
        ZStack {
            gradient
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills the entire view
                .edgesIgnoringSafeArea(.all) // Make the gradient fill the entire screen
            content
                .foregroundColor(.white) // Set the default text color to white
        }
    }
}

extension View {
    func applyGradientBackground() -> some View {
        self.modifier(GradientBackground())
    }
    
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(ColorPalette.primary)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
        return self
    }
}

// Sets NavigationTitle to white
struct NavigationBarModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        let uiColor = UIColor(ColorPalette.primary)
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: uiColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: uiColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}

struct FormBackgroundClear: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            if let table = view.closestSuperview(ofType: UITableView.self) {
                table.backgroundColor = .clear
                table.backgroundView = nil
                table.separatorStyle = .none
            }
            view.superview?.backgroundColor = .clear
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIView {
    func closestSuperview<T: UIView>(ofType type: T.Type) -> T? {
        var parent = self.superview
        while let p = parent {
            if let match = p as? T { return match }
            parent = p.superview
        }
        return nil
    }
}
