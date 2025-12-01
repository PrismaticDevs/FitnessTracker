//
//  Auth.swift
//  FitnessTracker
//
//  Created by Matt on 11/9/25.
//
import SwiftUI
import FirebaseAuth

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    typealias FBAuth = FirebaseAuth.Auth
    
    init() {
        self.user = FBAuth.auth().currentUser
        self.isAuthenticated = user != nil
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
                
                // Firebase specific error codes
                switch error.code {
                case AuthErrorCode.emailAlreadyInUse.rawValue:
                    print("Email already in use")
                case AuthErrorCode.invalidEmail.rawValue:
                    print("Invalid email format")
                case AuthErrorCode.weakPassword.rawValue:
                    print("Password is too weak")
                default:
                    print("Unknown Firebase authentication error")
                }
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
        FBAuth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
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
        }
        DispatchQueue.main.async {
            self.user = nil
            self.isAuthenticated = false
        }
    }
}

