//
//  Auth.swift
//  FitnessTracker
//
//  Created by Matt on 11/9/25.
//
import SwiftUI
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var user: User? = nil
    @Published var isAuthenticated: Bool = false
    typealias FBAuth = FirebaseAuth.Auth
    
    init() {
        self.user = FBAuth.auth().currentUser
        self.isAuthenticated = user != nil
    }
    
    func registerUser(email: String, password: String) {
        FBAuth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
                return
            }
            self.user = authResult?.user
            self.isAuthenticated = true
            print("User created successfully!")
        }
    }
    
    func signIn(email: String, password: String) {
        FBAuth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
                return
            }
            self.user = result?.user
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        do {
            try FBAuth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
        self.user = nil
        self.isAuthenticated = false
    }
}

