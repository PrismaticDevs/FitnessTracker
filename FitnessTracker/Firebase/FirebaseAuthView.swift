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

enum AuthField {
    case email
    case password
}

struct FirebaseAuthView: View {
    @EnvironmentObject var auth: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var shouldNavigateToHome = false
    @State private var showAuthError = false
    @State private var authErrorMessage: String = ""
    @FocusState private var focusedField: AuthField?
    @State private var showGmailRedirect = false

    private let fieldHeight: CGFloat = 48
    private let corner: CGFloat = 10

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                Image("white-outline")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 300, height: 300)
                    .clipped()
                    .cornerRadius(8)

                Text("Sign Up and In")
                    .font(.title.bold())

                // Inputs
                VStack(spacing: 12) {
                    InputField(placeholder: "Email", text: $email, keyboard: .emailAddress)
                        .focused($focusedField, equals: .email)
                    InputField(placeholder: "Password", text: $password, isSecure: true)
                        .focused($focusedField, equals: .password)
                }
                .onSubmit {
                    if focusedField == .email {
                        focusedField = .password
                    } else {
                        focusedField = nil
                    }
                }

                // Primary auth actions
                AuthButtons(
                    onLogin: {
                        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
                            authErrorMessage = "Please enter both email and password."
                            showAuthError = true
                            return
                        }
                        // Very light email shape check
                        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
                            authErrorMessage = "Please enter a valid email address."
                            showAuthError = true
                            return
                        }
                        auth.signIn(email: trimmedEmail, password: trimmedPassword)
                    },
                    onSignUp: {
                        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
                            authErrorMessage = "Please enter both email and password."
                            showAuthError = true
                            return
                        }
                        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
                            authErrorMessage = "Please enter a valid email address."
                            showAuthError = true
                            return
                        }
                        // Basic password guidance (customize as needed)
                        guard trimmedPassword.count >= 6 else {
                            authErrorMessage = "Password must be at least 6 characters."
                            showAuthError = true
                            return
                        }
                        
                        if trimmedEmail.lowercased().hasSuffix("@gmail.com") {
                            showGmailRedirect = true
                            return
                        }
                        
                        auth.registerUser(email: trimmedEmail, password: trimmedPassword)
                    },
                    corner: corner,
                    height: fieldHeight
                )
                .alert("Use Google Sign-In", isPresented: $showGmailRedirect) {
                                Button("OK", role: .cancel) { }
                } message: {
                    Text("Gmail users are required to use the 'Sign in with Google' button below for a safer experience.")
                }

                // Third-party sign in
                VStack(spacing: 12) {
                    AppleSignInButton()
                    GoogleSignInButton(onError: { message in
                        authErrorMessage = message
                        showAuthError = true
                    })
                }
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding()
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .applyGradientBackground()
            .alert("Sign-In Error", isPresented: $showAuthError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authErrorMessage)
            }
            .navigationDestination(isPresented: $shouldNavigateToHome) {
                ContentView().environmentObject(auth)
            }
            .onChange(of: auth.isAuthenticated) { _, newValue in
                if newValue { shouldNavigateToHome = true }
            }
            .onChange(of: auth.authErrorMessage) { _, newValue in
                if let newValue, !newValue.isEmpty {
                    authErrorMessage = newValue
                    showAuthError = true
                    // Clear the message on the manager so the alert doesn't reappear unexpectedly
                    auth.authErrorMessage = nil
                }
            }
        }
    }
}

// MARK: - Reusable input field
struct InputField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default

    private let corner: CGFloat = 10
    private let height: CGFloat = 48

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: height)
        .background(ColorPalette.accent.opacity(0.8))
        .cornerRadius(corner)
    }
}

// MARK: - Login / Sign Up buttons (side-by-side)
struct AuthButtons: View {
    let onLogin: () -> Void
    let onSignUp: () -> Void
    var corner: CGFloat = 10
    var height: CGFloat = 48

    var body: some View {
        HStack(spacing: 12) {
            AuthActionButton(title: "Login", isPrimary: false, corner: corner, height: height, action: onLogin)
            AuthActionButton(title: "Sign Up", isPrimary: true, corner: corner, height: height, action: onSignUp)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AuthActionButton: View {
    let title: String
    let isPrimary: Bool
    var corner: CGFloat = 10
    var height: CGFloat = 48
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: height)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: corner)
                .fill(isPrimary ? ColorPalette.accent : ColorPalette.accent2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: corner)
                .stroke(isPrimary ? Color.clear : ColorPalette.accent, lineWidth: 1)
        )
        .foregroundColor(isPrimary ? .accent : ColorPalette.primary)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}
private let buttonHeight: CGFloat = 48
private let buttonCorner: CGFloat = 10

struct AppleSignInButton: View {
    @State private var isSigningIn = false
    var body: some View {
        ZStack {
            // background behind content so it doesn't darken the images
            RoundedRectangle(cornerRadius: buttonCorner)
                .fill(ColorPalette.accent.opacity(0.3))

            HStack(spacing: 12) {
                Image("apple")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .opacity(1.0)

                Text("Sign in with Apple")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(ColorPalette.primary)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: buttonHeight)
        .frame(maxWidth: .infinity)                // makes it expand to available width
        .overlay(RoundedRectangle(cornerRadius: buttonCorner).stroke(ColorPalette.accent, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .cornerRadius(buttonCorner)
        .buttonStyle(PlainButtonStyle())
        .onTapGesture(perform: handleAppleSignIn)
    }

    func handleAppleSignIn() { print("Apple") }
}

struct GoogleSignInButton: View {
    var onError: ((String) -> Void)? = nil
    @State private var isSigningIn = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: buttonCorner)
                .fill(ColorPalette.accent.opacity(0.3))

            ZStack {
                HStack(spacing: 12) {
                    Image("google-logo")
                        .resizable()
                        .frame(width: 20, height: 20)

                    Text("Sign in with Google")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(ColorPalette.primary)
                }
                .opacity(isSigningIn ? 0.5 : 1.0)

                if isSigningIn {
                    SpinningRing(size: 20, lineWidth: 3, color: .white)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: buttonHeight)
        .frame(maxWidth: .infinity)                // same width as Apple button when placed in a VStack/HStack
        .overlay(RoundedRectangle(cornerRadius: buttonCorner).stroke(ColorPalette.accent, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        .cornerRadius(buttonCorner)
        .buttonStyle(PlainButtonStyle())
        .disabled(isSigningIn)
        .onTapGesture { handleGoogleSignIn() }
    }

    func handleGoogleSignIn() {
        // Prevent double-taps starting multiple sessions
        if isSigningIn { return }
        isSigningIn = true
        
        // Ensure Firebase is configured
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Configure Google Sign-In from Firebase clientID (reliable single source)
        if let clientID = FirebaseApp.app()?.options.clientID {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        }
        
        // Find the top-most presenting view controller
        guard let presentingVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
                print("Unable to find presenting view controller for Google Sign-In")
                onError?("We couldn't start Google Sign-In. Please try again.")
                isSigningIn = false
                return
            }

        // Use the modern sign-in API: signIn(withPresenting:)
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
            if let error = error {
                print("Google sign in error: \(error.localizedDescription)")
                onError?(error.localizedDescription)
                isSigningIn = false
                return
            }

            guard let result = signInResult else {
                print("Google sign in returned no result")
                onError?("Google didn't return a sign-in result. Please try again.")
                isSigningIn = false
                return
            }

            let user = result.user
            guard let idTokenString = user.idToken?.tokenString else {
                print("Missing Google ID token")
                onError?("Couldn't verify your Google account. Please try again.")
                isSigningIn = false
                return
            }
            let accessTokenString = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idTokenString, accessToken: accessTokenString)
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign in error: \(error.localizedDescription)")
                    onError?(error.localizedDescription)
                    isSigningIn = false
                    return
                }
                if let user = authResult?.user {
                    print("Signed in as: \(user.uid)")
                } else {
                    print("Firebase returned no user after sign-in")
                    onError?("Signed in with Google, but no user was returned. Please try again.")
                }
                isSigningIn = false
            }
        }
    }
}

struct SpinningRing: View {
    @State private var rotate = false
    var size: CGFloat = 22
    var lineWidth: CGFloat = 3
    var color: Color = .white
    
    var body: some View {
        Circle()
            .trim(from: 0.2, to: 1.0)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotate ? 360 : 0))
            .animation(.linear(duration: 0.9).repeatForever(autoreverses: false), value: rotate)
            .onAppear { rotate = true }
            .onDisappear { rotate = false }
    }
}

#Preview {
    NavigationStack {
        FirebaseAuthView()
            .environmentObject(AuthManager())
    }
}

