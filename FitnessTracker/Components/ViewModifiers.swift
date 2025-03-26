//
//  ViewModifiers.swift
//  FitnessTracker
//
//  Created by Matt on 2/28/25.
//

import SwiftUI

// Gradient Background Modifier
//struct GradientBackground: ViewModifier {
//    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)
//
//    func body(content: Content) -> some View {
//        ZStack {
//            gradient
//                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills the entire view
//                .edgesIgnoringSafeArea(.all) // Make the gradient fill the entire screen
//            content
//                .foregroundColor(.white) // Set the default text color to white
//        }
//    }
//}
//
//extension View {
//    func applyGradientBackground() -> some View {
//        self.modifier(GradientBackground())
//    }
//    func navigationBarTitleTextColor(_ color: Color) -> some View {
//        let uiColor = UIColor(color)
//        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
//        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
//        return self
//    }
//}

// Gradient Background Modifier
struct GradientBackground: ViewModifier {
    var gradient = LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .bottom, endPoint: .top)

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
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor]
        return self
    }
}

// Sets NavigationTitle to white
struct NavigationBarModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    func body(content: Content) -> some View {
        content
    }
}
