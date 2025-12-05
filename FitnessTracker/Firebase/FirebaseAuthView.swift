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
                    Image("white-outline")
                        .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 300)
                            .clipped()
                            .cornerRadius(8)
                            .padding(0)
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
        }
    }
}

#Preview {
    NavigationStack {
        FirebaseAuthView()
            .environmentObject(AuthManager())
    }
}
