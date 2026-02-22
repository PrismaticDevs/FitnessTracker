//
//  UpdateEmailView.swift
//  FitnessTracker
//
//  Created by Matt on 2/21/26.
//
import SwiftUI
import FirebaseAuth

struct UpdateEmailView: View {
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject var theme = ThemeManager.shared
    @State private var newEmail = ""
    @State private var errorMsg = ""
    @State private var emailSent = false // Track if we sent the link
    
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: newEmail)
    }

    var body: some View {
        NavigationStack {
            Form {
                if !emailSent {
                    Section("New Email Address") {
                        TextField("Email", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                        
                        Text("Firebase will send a link to this address. Your account email won't change until you verify the new one.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                } else {
                    Section {
                        Text("✅ Verification link sent! Please check \(newEmail) and click the link to finalize the change.")
                            .multilineTextAlignment(.center)
                            .padding(.vertical)
                    }
                    .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                }
                
                if !errorMsg.isEmpty {
                    Text(errorMsg).foregroundColor(.red).font(.caption)
                }
            }
            .scrollContentBackground(.hidden)
            .applyGradientBackground()
            .navigationTitle("Update Email")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if !emailSent {
                        Button("Send Link") {
                            updateFlow()
                        }
                        .disabled(!isValidEmail)
                        .opacity(isValidEmail ? 1.0 : 0.5)
                    } else {
                        Button("Done") { dismiss() }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    func updateFlow() {
        Task {
            do {
                // Using the non-deprecated method from your AuthManager
                try await auth.startEmailChange(to: newEmail)
                emailSent = true
            } catch let error as NSError {
                // FIX: Use AuthErrorCode.Code to avoid 'out of scope'
                if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    errorMsg = "Security timeout. Please log out and back in to change your email."
                } else {
                    errorMsg = error.localizedDescription
                }
            }
        }
    }
}
