//
//  SocialPortal.swift
//  FitnessTracker
//
//  Created by Matt on 11/29/25.
//

import SwiftUI

struct SocialPortal: View {
    @ObservedObject var theme = ThemeManager.shared
    @ObservedObject var social = SocialService.shared
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    @State private var dragOffset: CGFloat = 0
    @State private var showProfileEditor = false
    @State private var showGymBrowser = false
    @State private var gymToShow: GymPlace?
    @State private var postToDelete: WorkoutPost?

    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .padding(.top, 100)
                .offset(x: dragOffset)
                .animation(.interactiveSpring(), value: dragOffset)

            if social.myProfile != nil {
                FloatingActionBar {
                    Spacer()
                    Button { showProfileEditor = true } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    .accessibilityLabel("Edit profile")
                    Spacer()
                    Button { showGymBrowser = true } label: {
                        Image(systemName: "mappin.and.ellipse")
                    }
                    .accessibilityLabel("Browse gyms")
                    Spacer()
                    Button { Task { await social.refreshFeed() } } label: {
                        if social.isLoadingFeed {
                            ProgressView().tint(.onAccent)
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(social.isLoadingFeed)
                    Spacer()
                }
                .padding(.bottom, 10)
            }

            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(false)
                .overlay(alignment: .leading) {
                    Color.clear
                        .frame(width: 24) // leading-edge grab area
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    if value.startLocation.x < 24, value.translation.width > 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.startLocation.x < 24, value.translation.width > 80 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) { dragOffset = 0 }
                                    }
                                }
                        )
                }
        }
        .applyAppBranding()
        .brandedBackButton(title: "FiT Social", theme: theme.currentTheme, dismiss: dismiss)
        .task(id: auth.user?.uid) {
            guard let uid = auth.user?.uid else {
                social.reset()
                return
            }
            if social.myProfile?.id != uid || !social.hasLoadedProfile {
                social.reset()
                await social.loadMyProfile(uid: uid)
            }
            if social.myProfile != nil { await social.refreshFeed() }
            // The private profile holds the age used to decide who may go public.
            if auth.profile == nil { await auth.fetchUser() }
            await auth.clearNotification(for: .social)
        }
        .onChange(of: social.myProfile) { old, new in
            // First profile just got created: load the feed.
            if old == nil, new != nil { Task { await social.refreshFeed() } }
        }
        .sheet(isPresented: $showProfileEditor) {
            SocialProfileEditor()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showGymBrowser) {
            GymPickerView(mode: .browse)
        }
        .sheet(item: $gymToShow) { gym in
            GymDetailView(gym: gym)
        }
        .confirmationDialog(
            "Delete this post?",
            isPresented: Binding(get: { postToDelete != nil }, set: { if !$0 { postToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button("Delete Post", role: .destructive) {
                if let post = postToDelete, let uid = auth.user?.uid {
                    Task {
                        do { try await social.deletePost(post, uid: uid) }
                        catch { social.errorMessage = error.localizedDescription }
                    }
                }
                postToDelete = nil
            }
        } message: {
            Text("This removes it from FiT Social. Your workout history isn't affected.")
        }
    }

    // MARK: - States

    @ViewBuilder
    private var content: some View {
        if auth.user == nil {
            messageView(icon: "person.crop.circle.badge.questionmark",
                        title: "Sign in to use FiT Social",
                        detail: "Share your workouts and see what others are training.")
        } else if !social.hasLoadedProfile {
            ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if social.myProfile == nil {
            SocialProfileEditor(isFirstRun: true)
        } else {
            feedView
        }
    }

    private var feedView: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let profile = social.myProfile { profileHeader(profile) }

                if let error = social.errorMessage {
                    Text(error)
                        .font(.callout)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if social.feed.isEmpty && !social.isLoadingFeed {
                    messageView(icon: "square.and.arrow.up",
                                title: "No posts yet",
                                detail: "Open a program's Session Data and tap Share on a completed session to post it here.")
                        .padding(.top, 20)
                } else {
                    LazyVStack(spacing: 14) {
                        ForEach(social.feed) { post in
                            let isMine = post.authorId == auth.user?.uid
                            WorkoutPostCard(post: post, isMine: isMine) {
                                postToDelete = post
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // room for the floating bar
        }
        .refreshable { await social.refreshFeed() }
    }

    private func profileHeader(_ profile: PublicProfile) -> some View {
        HStack(alignment: .top, spacing: 14) {
            AvatarView(text: profile.initials, size: 60)
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.displayName).font(.headline)
                HStack(spacing: 6) {
                    Text("@\(profile.username)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    visibilityChip(profile)
                }
                if !profile.homeGym.isEmpty {
                    if let place = profile.homeGymPlace {
                        // Tap to see who else trains there.
                        Button { gymToShow = place } label: {
                            Label(profile.homeGym, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundColor(theme.currentTheme.accentText)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Label(profile.homeGym, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                if !profile.bio.isEmpty {
                    Text(profile.bio).font(.subheadline).padding(.top, 2)
                }
                HStack(spacing: 16) {
                    countLabel(profile.postCount, "posts")
                    countLabel(profile.followerCount, "followers")
                    countLabel(profile.followingCount, "following")
                }
                .padding(.top, 4)
            }
            Spacer()
            Button { showProfileEditor = true } label: {
                Image(systemName: "pencil.circle.fill").font(.title2)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(theme.currentTheme.accent2.opacity(0.85))
        .cornerRadius(18)
    }

    private func visibilityChip(_ profile: PublicProfile) -> some View {
        Label(profile.isPubliclyVisible ? "Public" : "Private",
              systemImage: profile.isPubliclyVisible ? "globe" : "lock.fill")
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.fillStrong)
            .clipShape(Capsule())
            .accessibilityLabel(profile.isPubliclyVisible ? "Public profile" : "Private profile")
    }

    private func countLabel(_ value: Int, _ label: String) -> some View {
        HStack(spacing: 3) {
            Text("\(value)").font(.caption.bold())
            Text(label).font(.caption).foregroundColor(.textSecondary)
        }
    }

    private func messageView(icon: String, title: String, detail: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon).font(.system(size: 40))
            Text(title).font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(30)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SocialPortal()
            .environmentObject(AuthManager())
    }
}
