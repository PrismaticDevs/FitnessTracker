//
//  Auth.swift
//  FitnessTracker
//
//  Created by Matt on 11/9/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseCore

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var authErrorMessage: String? = nil
    // Preview-only override for a stable user id in SwiftUI previews
    var previewUserID: String? = nil
    typealias FBAuth = FirebaseAuth.Auth
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.user = FBAuth.auth().currentUser
        self.isAuthenticated = self.user != nil
        
        authStateListenerHandle = FBAuth.auth().addStateDidChangeListener { [weak self] (auth: FirebaseAuth.Auth, user: FirebaseAuth.User?) in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = (user != nil)
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            FBAuth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func registerUser(email: String, password: String) {
        print("Attempting to register user: \(email)")
        
        // Add more verbose error logging
        FBAuth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error as NSError? {
                print("Full Error Details:")
                print("Error Domain: \(error.domain)")
                print("Error Code: \(error.code)")
                print("Localized Description: \(error.localizedDescription)")

                var message = error.localizedDescription
                switch error.code {
                case FirebaseAuth.AuthErrorCode.emailAlreadyInUse.rawValue:
                    message = "That email is already in use. Try logging in instead."
                case FirebaseAuth.AuthErrorCode.invalidEmail.rawValue:
                    message = "That email address looks invalid."
                case FirebaseAuth.AuthErrorCode.weakPassword.rawValue:
                    message = "Your password is too weak. Please choose a stronger one."
                default:
                    break
                }
                DispatchQueue.main.async { [weak self] in
                    self?.authErrorMessage = message
                }
                return
            }
            
            guard let user = authResult?.user else {
                print("No user returned from Firebase")
                return
            }
            
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = true
            }
            print("User created successfully!")
        }
    }

    
    func signIn(email: String, password: String) {
        FBAuth.auth().signIn(withEmail: email, password: password) { (result: AuthDataResult?, error: Error?) in
            if let error = error as NSError? {
                print("Error signing in: \(error.localizedDescription)")
                var message = error.localizedDescription
                switch error.code {
                case FirebaseAuth.AuthErrorCode.userNotFound.rawValue:
                    message = "No account found with that email."
                case FirebaseAuth.AuthErrorCode.wrongPassword.rawValue:
                    message = "Incorrect password. Please try again."
                case FirebaseAuth.AuthErrorCode.invalidEmail.rawValue:
                    message = "That email address looks invalid."
                case FirebaseAuth.AuthErrorCode.userDisabled.rawValue:
                    message = "This account has been disabled."
                default:
                    break
                }
                DispatchQueue.main.async {
                    self.authErrorMessage = message
                }
                return
            }
            DispatchQueue.main.async {
                self.user = result?.user
                self.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        do {
            try FBAuth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.authErrorMessage = error.localizedDescription
            }
        }
        DispatchQueue.main.async {
            self.user = nil
            self.isAuthenticated = false
        }
    }
}

