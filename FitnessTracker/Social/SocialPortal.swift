//
//  SocialPortal.swift
//  FitnessTracker
//
//  Created by Matt on 11/29/25.
//

import SwiftUI

struct SocialPortal: View {
    @EnvironmentObject var auth: AuthManager
    @Binding var isPresented: Bool
    @State private var navigateToAuthView = false // State variable for navigation
    @State private var returnToRoot = false

    var body: some View {
        // Use NavigationStack for main content
        NavigationStack {
            ZStack {
                // Your main content can go here
            }
            .applyGradientBackground()
            .navigationTitle("FiT Social")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        #if canImport(UIKit)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        #endif
                        auth.signOut()
                        isPresented = false
                        returnToRoot = true // Trigger return to ContentView
                    }) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(ColorPalette.primary)
                            .padding(10)
                            .background(Color.red)
                            .clipShape(Circle())
                            .accessibilityLabel("Log out")
                    }
                }
            }
            .navigationBarTitleTextColor(.white)
            .fullScreenCover(isPresented: $returnToRoot) {
                ContentView().environmentObject(auth)
            }
        }
    }
}

#Preview {
    SocialPortal(isPresented: .constant(true))
}
