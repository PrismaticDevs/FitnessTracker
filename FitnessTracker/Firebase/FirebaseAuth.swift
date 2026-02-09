//
//  Auth.swift
//  FitnessTracker
//
//  Created by Matt on 11/9/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User? = nil
    @Published var profile: UserProfile? = nil
    @Published var isAuthenticated: Bool = false
    @Published var authErrorMessage: String? = nil
    @Published var isUpdating: Bool = false
    // Preview-only override for a stable user id in SwiftUI previews
    var previewUserID: String? = nil
    private let db = Firestore.firestore()
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
    
    func fetchUser() async {
        guard let uid = FBAuth.auth().currentUser?.uid else { return }
        let docRef = Firestore.firestore().collection("users").document(uid)
        
        do {
            let fetchedProfile = try await docRef.getDocument(as: UserProfile.self)
            self.profile = fetchedProfile
            print("Fetched user: \(fetchedProfile.display_name)")
            print("User attrib: \(fetchedProfile.biometrics)")
        } catch {
            print("Error decoding user: \(error)")
        }
    }
    

    func updateUserProfile(name: String, age: Int, weight: Double, height: Double, gender: String) async {
        guard let uid = user?.uid else { return }
        
        // We must mirror the UserProfile struct EXACTLY
        let userData: [String: Any] = [
            "display_name": name,
            "last_updated": FieldValue.serverTimestamp(),
            
            // This creates the 'biometrics' map in Firestore
            "biometrics": [
                "age": age,
                "weight": Int(weight), // Convert Double to Int to match struct
                "gender": gender, // Must exist for non-optional struct
                "height": Int(height),               // Must exist for non-optional struct
                "created_at": FieldValue.serverTimestamp()
            ],
            
            // This creates the 'preferences' map in Firestore
            "preferences": [
                "home_gym": "Default",
                "theme": "Dark",
                "units": "kg"
            ]
        ]
        
        do {
            // 'merge: true' is critical so you don't overwrite other fields
            try await db.collection("users").document(uid).setData(userData, merge: true)
            print("✅ Firestore: Saved with correct nesting")
            await fetchUser() // Refresh local profile
        } catch {
            print("❌ Firestore Error: \(error)")
        }
    }
    
}


