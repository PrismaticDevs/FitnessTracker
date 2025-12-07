//
//  AuthView.swift
//  FitnessTracker
//
//  Created by Matt on 11/26/25.
//

import SwiftUI

import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import UIKit

struct FirebaseAuthView: View {
    @EnvironmentObject var auth: AuthManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var shouldNavigateToHome: Bool = false
    
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
                    Text("Sign Up and In")
                        .font(.title2.bold())
                        .padding()
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
                    Spacer()
                    HStack {
                        Spacer()
                        GoogleSignInButton()
                        Spacer()
                        AppleSignInButton()
                        Spacer()
                    }
                }
                .padding()
            }
            .applyGradientBackground()
            .navigationDestination(isPresented: $shouldNavigateToHome) {
                ContentView()
                    .environmentObject(auth)
            }
            .onChange(of: auth.isAuthenticated) { oldValue, newValue in
                if newValue {
                    shouldNavigateToHome = true
                }
            }
        }
    }
}

struct AppleSignInButton: View {
    var body: some View {
        Button(action: handleAppleSignIn) {
            HStack {
                Image("apple")
//                    .resizable().frame(width: 18, height: 18)
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
        .buttonStyle(PlainButtonStyle())
    }
    func handleAppleSignIn() {
        print("Apple")
    }
}

struct GoogleSignInButton: View {
    var body: some View {
        Button(action: handleGoogleSignIn) {
            HStack {
                Image("google-logo")
//                    .resizable().frame(width: 18, height: 18)
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
        .buttonStyle(PlainButtonStyle())
    }

    func handleGoogleSignIn() {
        // Find the top-most presenting view controller
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
                print("Unable to find presenting view controller for Google Sign-In")
                return
            }

        // Use the modern sign-in API: signIn(withPresenting:)
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Google sign in error: \(error.localizedDescription)")
                return
            }

            guard let result = signInResult else {
                print("Google sign in returned no result")
                return
            }

            let user = result.user
            guard let idTokenString = user.idToken?.tokenString else {
                print("Missing Google ID token")
                return
            }
            let accessTokenString = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idTokenString, accessToken: accessTokenString)
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    return
                }
                if let user = authResult?.user {
                    print("Signed in as: \(user.uid)")
                } else {
                    print("Firebase returned no user after sign-in")
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

