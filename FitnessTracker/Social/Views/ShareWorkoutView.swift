//
//  ShareWorkoutView.swift
//  FitnessTracker
//
//  Sheet for posting a completed session to FiT Social.
//

import SwiftUI

struct ShareWorkoutView: View {
    let session: CompletedSession

    @EnvironmentObject var auth: AuthManager
    @ObservedObject var social = SocialService.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var caption = ""
    @State private var isPosting = false
    @State private var errorMessage: String?
    @State private var showProfileSetup = false

    private var snapshot: WorkoutSnapshot { WorkoutSnapshot(session: session) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if auth.user == nil {
                        notice("Sign in to share workouts on FiT Social.")
                    } else if social.hasLoadedProfile && social.myProfile == nil {
                        notice("Create your FiT Social profile before posting.")
                        Button("Set Up Profile") { showProfileSetup = true }
                            .buttonStyle(.borderedProminent)
                    }

                    TextField("Say something about this workout…", text: $caption, axis: .vertical)
                        .lineLimit(3...6)
                        .padding(12)
                        .background(theme.currentTheme.accent2.opacity(0.8))
                        .cornerRadius(12)

                    if snapshot.isEmpty {
                        notice(SocialError.emptyWorkout.localizedDescription)
                    } else {
                        WorkoutSummaryView(workout: snapshot)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
            }
            .navigationTitle("Share Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Button("Post") { Task { await post() } }
                            .bold()
                            .disabled(!canPost)
                    }
                }
            }
            .applyAppBranding()
            .sheet(isPresented: $showProfileSetup) {
                NavigationStack {
                    SocialProfileEditor()
                        .navigationTitle("FiT Social Profile")
                        .navigationBarTitleDisplayMode(.inline)
                        .applyAppBranding()
                }
            }
        }
        .task {
            if let uid = auth.user?.uid, !social.hasLoadedProfile {
                await social.loadMyProfile(uid: uid)
            }
        }
    }

    private var canPost: Bool {
        auth.user != nil && social.myProfile != nil && !snapshot.isEmpty
    }

    private func notice(_ text: String) -> some View {
        Text(text)
            .font(.callout)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
    }

    private func post() async {
        guard let uid = auth.user?.uid else { return }
        isPosting = true
        errorMessage = nil
        defer { isPosting = false }
        do {
            try await social.shareWorkout(session, caption: caption, uid: uid)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
