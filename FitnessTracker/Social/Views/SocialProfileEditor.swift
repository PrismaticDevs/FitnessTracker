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
    @State private var isPublic = false
    @State private var showAtGym = false
    @State private var confirmedAdult = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false

    private var normalizedUsername: String { UsernameRules.normalize(username) }
    private var usernameProblem: String? {
        username.isEmpty ? nil : UsernameRules.validationMessage(for: normalizedUsername)
    }

    /// Age from the private profile (Settings → Profile), if the user entered one.
    private var knownAge: Int? { auth.profile?.biometrics.age }
    private var canBePublic: Bool { SocialPrivacyRules.canBePublic(age: knownAge) }
    /// Without a known age, going public needs an explicit "I'm 18 or older".
    private var needsAgeConfirmation: Bool { isPublic && knownAge == nil && !confirmedAdult }

    private var canSave: Bool {
        !normalizedUsername.isEmpty && usernameProblem == nil && !needsAgeConfirmation && !isDeleting
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
                isPrimaryEnabled: canSave,
                isWorking: isSaving,
                onCancel: isFirstRun ? nil : { dismiss() },
                onPrimary: { Task { await save() } }
            )
            .padding(.horizontal, 25)
            .padding(.bottom, 25)
        }
        .onAppear(perform: prefill)
        .confirmationDialog("Delete your FiT Social data?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Profile and Posts", role: .destructive) { Task { await deleteSocialData() } }
        } message: {
            Text("This permanently deletes your FiT Social profile, username and all your posts. It can't be undone. Your private workout history stays on your account.")
        }
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
                        Text("Your profile starts private: only you see it and your posts. You can make it public below. Your stats (age, weight, height) are never shown.")
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
                                if let place = homeGymPlace, newValue != place.name {
                                    homeGymPlace = nil
                                    showAtGym = false   // can't be listed at a gym that isn't on the map
                                }
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

            privacySection

            if let errorMessage {
                Section {
                    Text(errorMessage).foregroundColor(.orange)
                }
                .listRowBackground(theme.currentTheme.accent2)
            }

            if !isFirstRun && social.myProfile != nil {
                Section {
                    Button(role: .destructive) { showDeleteConfirm = true } label: {
                        HStack {
                            if isDeleting { ProgressView() } else { Image(systemName: "trash") }
                            Text("Delete My FiT Social Data")
                        }
                        .foregroundColor(.red)
                    }
                    .disabled(isDeleting || isSaving)
                } footer: {
                    Text("Removes your profile, username and posts. Your private workout history isn't affected.")
                        .foregroundColor(.textSecondary)
                }
                .listRowBackground(theme.currentTheme.accent2)
            }
        }
        .scrollContentBackground(.hidden)
    }

    @ViewBuilder
    private var privacySection: some View {
        Section {
            Toggle(isOn: $isPublic) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Public profile")
                    Text(isPublic
                         ? "Anyone on FiT Social can see your profile and posts."
                         : "Only you can see your profile and posts.")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .disabled(!canBePublic)
            .onChange(of: isPublic) { _, newValue in
                if !newValue { showAtGym = false }
            }

            if !canBePublic {
                Text("Public profiles are for people \(SocialPrivacyRules.minimumPublicAge) and older, based on the age in your profile.")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            } else if isPublic && knownAge == nil {
                Toggle("I'm \(SocialPrivacyRules.minimumPublicAge) or older", isOn: $confirmedAdult)
            }

            Toggle(isOn: $showAtGym) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show me at my gym")
                    Text(gymListingDescription)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            .disabled(!isPublic || homeGymPlace == nil)
        } header: {
            Text("Privacy")
        } footer: {
            Text("Others only ever see your name, @username, gym and posts. Never your location, stats, or when you're at the gym. You can turn these off at any time.")
                .foregroundColor(.textSecondary)
        }
        .tint(theme.currentTheme.accent)
        .listRowBackground(theme.currentTheme.accentSurface.opacity(0.6))
    }

    private var gymListingDescription: String {
        if !isPublic { return "Needs a public profile." }
        if homeGymPlace == nil { return "Pick your gym from the map to be listed there." }
        return showAtGym
            ? "People browsing \(homeGymPlace?.name ?? "your gym") can see you train there."
            : "You won't appear in your gym's member list."
    }

    private func deleteSocialData() async {
        guard let uid = auth.user?.uid else { return }
        isDeleting = true
        errorMessage = nil
        defer { isDeleting = false }
        do {
            try await social.deleteMySocialData(uid: uid)
            dismiss()
        } catch {
            errorMessage = "Couldn't delete everything: \(error.localizedDescription). Please try again."
        }
    }

    private func prefill() {
        if let profile = social.myProfile {
            username = profile.username
            displayName = profile.displayName
            bio = profile.bio
            homeGym = profile.homeGym
            homeGymPlace = profile.homeGymPlace
            isPublic = profile.isPubliclyVisible
            showAtGym = profile.isPublic == true && profile.showAtGym == true
            confirmedAdult = profile.isPubliclyVisible
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
                                          homeGym: homeGym, homeGymPlace: homeGymPlace,
                                          isPublic: isPublic && canBePublic,
                                          showAtGym: showAtGym && homeGymPlace != nil,
                                          age: knownAge)
            if !isFirstRun { dismiss() }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
