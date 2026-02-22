//
//  UpdatePasswordView.swift
//  FitnessTracker
//
//  Created by Matt on 2/21/26.
//
import SwiftUI
import FirebaseAuth

struct UpdatePasswordView: View {
        @EnvironmentObject var auth: AuthManager
        @Environment(\.dismiss) var dismiss
        @ObservedObject var theme = ThemeManager.shared
        @State private var newPassword = ""
        @State private var confirmPassword = ""
        @State private var errorMsg = ""
        @FocusState private var isInputActive: Bool

        var body: some View {
            NavigationStack {
                Form {
                    Section("Update Password") {
                        SecureField("New Password", text: $newPassword)
                            .focused($isInputActive, equals: true)
                        SecureField("Confirm New Password", text: $confirmPassword)
                            .focused($isInputActive, equals: true)
                    }
                    .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                    
                    if !errorMsg.isEmpty {
                        Text(errorMsg)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Section {
                        Button(action: submitPassword) {
                            Text("Update Password")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding() // This creates the "height" of your button
                                .background(
                                    // Use a Gradient or Solid color that stands out
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(newPassword.isEmpty || newPassword != confirmPassword ?
                                              Color.gray.opacity(0.3) : theme.currentTheme.accent)
                                )
                        }
                        .buttonStyle(.plain) // 👈 This removes the "blue rectangle" overlay
                        .disabled(newPassword.isEmpty || newPassword != confirmPassword)
                        if !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword != confirmPassword {
                            Text("Passwords do not match")
                                .font(.caption)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .listRowBackground(Color.clear) // 👈 This lets the button float on the gradient
                    .listRowInsets(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)) // Adds some breathing room
                }
                .scrollContentBackground(.hidden)
                .applyGradientBackground()
                .navigationTitle("Password")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }

        func submitPassword() {
            isInputActive = false
            guard newPassword == confirmPassword else {
                errorMsg = "Passwords do not match"
                return
            }

            Task {
                do {
                    try await auth.updatePassword(to: newPassword)
                    dismiss()
                } catch let error as NSError {
                    if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                        errorMsg = "Security timeout. Please log out and back in to change your password."
                    } else {
                        errorMsg = error.localizedDescription
                    }
                }
            }
        }
    }
