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
    @State private var homeGymPlace: GymPlace?
    @State private var showGymPicker = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    private var normalizedUsername: String { UsernameRules.normalize(username) }
    private var usernameProblem: String? {
        username.isEmpty ? nil : UsernameRules.validationMessage(for: normalizedUsername)
    }

    var body: some View {
        VStack(spacing: 0) {
            if !isFirstRun {
                Text(social.myProfile == nil ? "Create Profile" : "Edit Profile")
                    .font(.title3.bold())
                    .padding(.top, 25)
            }
            form
            SheetActionButtons(
                primaryTitle: isFirstRun ? "Create Profile" : "Save",
                isPrimaryEnabled: !normalizedUsername.isEmpty && usernameProblem == nil,
                isWorking: isSaving,
                onCancel: isFirstRun ? nil : { dismiss() },
                onPrimary: { Task { await save() } }
            )
            .padding(.horizontal, 25)
            .padding(.bottom, 25)
        }
        .onAppear(perform: prefill)
        .sheet(isPresented: $showGymPicker) {
            GymPickerView(initialQuery: homeGymPlace == nil ? homeGym : "", initialPlace: homeGymPlace) { choice in
                homeGymPlace = choice.place
                homeGym = choice.name
            }
        }
    }

    private var form: some View {
        Form {
            if isFirstRun {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Set up your FiT Social profile")
                            .font(.headline)
                        Text("Your profile is public to other FiT Social users. Your private stats (age, weight, height) are never shown.")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(theme.currentTheme.accent2)
            }

            Section {
                HStack(spacing: 2) {
                    Text("@").foregroundColor(.textSecondary)
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
            .listRowBackground(theme.currentTheme.accentSurface.opacity(0.6))

            Section("About") {
                TextField("Bio (optional)", text: $bio, axis: .vertical)
                    .lineLimit(2...4)
                    .onChange(of: bio) { _, newValue in
                        if newValue.count > 160 { bio = String(newValue.prefix(160)) }
                    }
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        TextField("Home gym (optional)", text: $homeGym)
                            .onChange(of: homeGym) { _, newValue in
                                // Typing over a gym picked from the map turns it back into plain text.
                                if let place = homeGymPlace, newValue != place.name { homeGymPlace = nil }
                            }
                        Button { showGymPicker = true } label: {
                            Image(systemName: "map.fill")
                                .foregroundColor(.textPrimary)
                                .padding(6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Find gym on map")
                    }
                    if let place = homeGymPlace {
                        Label(place.address.isEmpty ? "From Apple Maps" : place.address, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            .listRowBackground(theme.currentTheme.accentSurface.opacity(0.6))

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.orange)
                }
                .listRowBackground(theme.currentTheme.accent2)
            }
        }
        .scrollContentBackground(.hidden)
    }

    private func prefill() {
        if let profile = social.myProfile {
            username = profile.username
            displayName = profile.displayName
            bio = profile.bio
            homeGym = profile.homeGym
            homeGymPlace = profile.homeGymPlace
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
            try await social.saveProfile(uid: uid, username: normalizedUsername, displayName: displayName, bio: bio,
                                          homeGym: homeGym, homeGymPlace: homeGymPlace)
            if !isFirstRun { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
