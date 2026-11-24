//
//  SocialProfileEditor.swift
//  FitnessTracker
//
//  Create or edit the public FiT Social profile.
//

import SwiftUI

struct SocialProfileEditor: View {
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var social = SocialService.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    /// True when shown as the first-run setup inside the portal (no Cancel button).
    var isFirstRun = false

    @State private var username = ""
    @State private var displayName = ""
    @State private var bio = ""
    @State private var homeGym = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var normalizedUsername: String { UsernameRules.normalize(username) }
    private var usernameProblem: String? {
        username.isEmpty ? nil : UsernameRules.validationMessage(for: normalizedUsername)
    }

    var body: some View {
        Form {
            if isFirstRun {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Set up your FiT Social profile")
                            .font(.headline)
                        Text("Your profile is public to other FiT Social users. Your private stats (age, weight, height) are never shown.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(theme.currentTheme.accent2)
            }

            Section {
                HStack(spacing: 2) {
                    Text("@").foregroundColor(.white.opacity(0.6))
                    TextField("username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onChange(of: username) { _, newValue in
                            let cleaned = UsernameRules.normalize(newValue)
                            if cleaned != newValue { username = cleaned }
                        }
                }
                TextField("Display name", text: $displayName)
            } header: {
                Text("Name")
            } footer: {
                if let usernameProblem {
                    Text(usernameProblem).foregroundColor(.orange)
                }
            }
            .listRowBackground(theme.currentTheme.accent.opacity(0.6))

            Section("About") {
                TextField("Bio (optional)", text: $bio, axis: .vertical)
                    .lineLimit(2...4)
                    .onChange(of: bio) { _, newValue in
                        if newValue.count > 160 { bio = String(newValue.prefix(160)) }
                    }
                TextField("Home gym (optional)", text: $homeGym)
            }
            .listRowBackground(theme.currentTheme.accent.opacity(0.6))

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.orange)
                }
                .listRowBackground(theme.currentTheme.accent2)
            }

            Section {
                Button {
                    Task { await save() }
                } label: {
                    HStack {
                        Spacer()
                        if isSaving { ProgressView() } else { Text(isFirstRun ? "Create Profile" : "Save").bold() }
                        Spacer()
                    }
                }
                .disabled(isSaving || normalizedUsername.isEmpty || usernameProblem != nil)
            }
            .listRowBackground(theme.currentTheme.accent2)
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            if !isFirstRun {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onAppear(perform: prefill)
    }

    private func prefill() {
        if let profile = social.myProfile {
            username = profile.username
            displayName = profile.displayName
            bio = profile.bio
            homeGym = profile.homeGym
        } else if let privateProfile = auth.profile {
            displayName = privateProfile.display_name
            let gym = privateProfile.preferences.home_gym
            homeGym = gym == "Default" ? "" : gym
        }
    }

    private func save() async {
        guard let uid = auth.user?.uid else {
            errorMessage = SocialError.notSignedIn.localizedDescription
            return
        }
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }
        do {
            try await social.saveProfile(uid: uid, username: normalizedUsername, displayName: displayName, bio: bio, homeGym: homeGym)
            if !isFirstRun { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
