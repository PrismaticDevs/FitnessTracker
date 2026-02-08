//
//  EditProfile.swift
//  FitnessTracker
//
//  Created by Matt on 2/8/26.
//
import SwiftUI

struct EdProfileView: View {
    @ObservedObject var theme = ThemeManager.shared
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var auth: AuthManager
    
    // Local state for form fields
    @State private var displayName = ""
    @State private var age = ""
    @State private var weight = ""
    @State private var gym = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Details") {
                    TextField("", text: $displayName, prompt: Text("Display Name").foregroundColor(.white.opacity(0.6)))
                        .listRowBackground(theme.currentTheme.accent2)
                    TextField("", text: $age, prompt: Text("Age").foregroundColor(.white.opacity(0.6)))
                        .keyboardType(.numberPad)
                        .listRowBackground(theme.currentTheme.accent2)
                    TextField("", text: $weight, prompt: Text("Weight (lbs)").foregroundColor(.white.opacity(0.6)))
                        .keyboardType(.decimalPad)
                        .listRowBackground(theme.currentTheme.accent2)
                }
                
                Section("Preferences") {
                    TextField("", text: $gym, prompt: Text("Home Gym").foregroundColor(.white.opacity(0.6)))
                        .listRowBackground(theme.currentTheme.accent2)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleTextColor(.white)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .foregroundColor(.white)
            .tint(theme.currentTheme.accent2)
            .onAppear {
                if let user = auth.user {
                    displayName = user.displayName ?? ""
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if auth.isUpdating {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task {
                                await auth.updateUserProfile(
                                    name: displayName,
                                    age: Int(age) ?? 0,
                                    weight: Double(weight) ?? 0)
                                dismiss()
                            }
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .applyGradientBackground()
    }
}

#Preview {
    EditProfileView()
}
