//
//  AuthView.swift
//  FitnessTracker
//
//  Created by Matt on 11/26/25.
//

import SwiftUI

struct FirebaseAuthView: View {
    @EnvironmentObject var auth: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var shouldNavigateToSocial: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TextField("Email", text: $email)
                        .padding(8)
                        .background(ColorPalette.accent.opacity(0.8).cornerRadius(8))
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    SecureField("Password", text: $password)
                        .padding(8)
                        .background(ColorPalette.accent.opacity(0.8).cornerRadius(8))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    HStack {
                        Button("Login") {
                            auth.signIn(email: email, password: password)
                        }
                        Button("Sign Up") {
                            auth.registerUser(email: email, password: password)
                        }
                        // If you need programmatic navigation, toggle shouldNavigateToSocial to true
                        // e.g., after successful registration/login in your view model
                    }
                }
                .padding()
            }
            .applyGradientBackground()
            .navigationDestination(isPresented: $shouldNavigateToSocial) {
                SocialPortal(isPresented: $shouldNavigateToSocial)
                    .environmentObject(auth)
            }
            .onChange(of: auth.isAuthenticated) { oldValue, newValue in
                if newValue {
                    shouldNavigateToSocial = true
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        // Dismiss keyboard if needed and sign out
                        #if canImport(UIKit)
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        #endif
                        auth.signOut()
                        shouldNavigateToSocial = false
                    }
                    .tint(.red)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FirebaseAuthView()
            .environmentObject(AuthManager())
    }
}
