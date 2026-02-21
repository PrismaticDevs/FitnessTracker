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
    @State private var dragOffset: CGFloat = 0

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
            .offset(x: dragOffset)
            .animation(.interactiveSpring(), value: dragOffset)
            .padding(.top, 130)
            customFloatingBar
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Color.clear
                        .frame(width: 24) // leading-edge grab area
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    // Only respond to drags that start near the leading edge and move right
                                    if value.startLocation.x < 24, value.translation.width > 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.startLocation.x < 24, value.translation.width > 80 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
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
