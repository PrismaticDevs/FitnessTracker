//
//  GymDetailView.swift
//  FitnessTracker
//
//  A gym and the FiT Social members who chose to be listed there.
//  Only people with a public profile AND "Show me at my gym" turned on appear,
//  and only their name and @username are shown. Never when they're at the gym.
//

import SwiftUI
import MapKit

struct GymDetailView: View {
    let gym: GymPlace

    @EnvironmentObject var auth: AuthManager
    @ObservedObject var social = SocialService.shared
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var members: [PublicProfile] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private var isMyGym: Bool { social.myProfile?.homeGymPlace?.id == gym.id }
    private var amListedHere: Bool { isMyGym && (social.myProfile?.isListedAtGym ?? false) }

    var body: some View {
        VStack(spacing: 14) {
            header

            Map(initialPosition: .region(MKCoordinateRegion(center: gym.coordinate,
                                                            latitudinalMeters: 1_200, longitudinalMeters: 1_200))) {
                Marker(gym.name, systemImage: "dumbbell.fill", coordinate: gym.coordinate)
                    .tint(theme.currentTheme.accent)
            }
            .frame(height: 150)
            .cornerRadius(14)
            .allowsHitTesting(false)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text(membersTitle)
                        .font(.headline)
                    membersContent
                    myListingNote
                }
            }

            SheetActionButtons(primaryTitle: "Done", onPrimary: { dismiss() })
        }
        .padding(.horizontal, 25)
        .padding(.bottom, 25)
        .foregroundColor(.textPrimary)
        .presentationDragIndicator(.visible)
        .task { await loadMembers() }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text(gym.name)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
            if !gym.address.isEmpty {
                Text(gym.address)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.top)
    }

    private var membersTitle: String {
        isLoading || members.isEmpty ? "Members who train here" : "Members who train here (\(members.count))"
    }

    @ViewBuilder
    private var membersContent: some View {
        if isLoading {
            ProgressView().frame(maxWidth: .infinity).padding()
        } else if let errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.orange)
        } else if members.isEmpty {
            Text("No one has shared that they train here yet.")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .padding(.vertical, 8)
        } else {
            ForEach(members) { member in
                HStack(spacing: 12) {
                    AvatarView(text: member.initials, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.displayName).font(.subheadline.bold())
                        Text("@\(member.username)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color.fillSubtle)
                .cornerRadius(12)
            }
        }
    }

    @ViewBuilder
    private var myListingNote: some View {
        if amListedHere {
            Label("You're listed here. Turn off \"Show me at my gym\" in your profile to hide.", systemImage: "eye")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.top, 6)
        } else if isMyGym {
            Label("You're not listed here. Turn on Public profile and \"Show me at my gym\" in your profile to appear.", systemImage: "eye.slash")
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.top, 6)
        }
    }

    private func loadMembers() async {
        isLoading = true
        defer { isLoading = false }
        do {
            members = try await social.membersAtGym(gym.id, excluding: auth.user?.uid)
        } catch {
            errorMessage = "Couldn't load members right now."
        }
    }
}
