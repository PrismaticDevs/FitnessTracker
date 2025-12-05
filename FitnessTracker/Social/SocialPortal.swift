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

    var body: some View {
        // Use NavigationStack for navigation
        NavigationStack {
            ZStack {
                // Your main content can go here
            }
            .applyGradientBackground()
            .navigationTitle("FiT Social")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        #if canImport(UIKit)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        #endif
                        auth.signOut()
                        isPresented = false
                        navigateToAuthView = true // Trigger navigation
                    }
                }
            }
            .navigationBarTitleTextColor(.white)
            // Use navigationDestination to define the next view
            .navigationDestination(for: Bool.self) { _ in
                FirebaseAuthView() // Destination view
            }
            .onChange(of: navigateToAuthView) { newValue, oldValue in
                if newValue && !oldValue{
                    // Triggers the navigation to FireBaseAuthView when navigateToAuthView is true
                    navigateToAuthView = false
                }
            }
        }
    }
}

#Preview {
    SocialPortal(isPresented: .constant(true))
}
