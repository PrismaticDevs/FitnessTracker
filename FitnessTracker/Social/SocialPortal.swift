//
//  SocialPortal.swift
//  FitnessTracker
//
//  Created by Matt on 11/29/25.
//

import SwiftUI

struct SocialPortal: View {
    @ObservedObject var theme = ThemeManager.shared
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var navigateToAuthView = false // State variable for navigation
    @State private var returnToRoot = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                HStack {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .foregroundColor(theme.currentTheme.accent2)
                    Text("FiT Social")
                        .font(.headline)
                        .foregroundColor(theme.currentTheme.accent2)
                }
                .padding()
                .foregroundColor(.white.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.top, 130)
            customFloatingBar
        }
        .applyAppBranding()
        .brandedBackButton(title: "", theme: theme.currentTheme, dismiss: dismiss)
    }
    
    private var customFloatingBar: some View {
            HStack {
                Text("Hi")
                Image(systemName: "hand.wave")
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: 50)
            .background(theme.currentTheme.accent) // Themed bar color
            .cornerRadius(30)
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        }
}

#Preview {
    SocialPortal()
}
