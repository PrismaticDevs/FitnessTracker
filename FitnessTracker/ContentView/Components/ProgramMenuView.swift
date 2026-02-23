//
//  ProgramMenuView.swift
//  FitnessTracker
//
//  Created by Matt on 2/22/26.
//

import SwiftUI
import SwiftData

struct ProgramMenuView: View {
    @Query(
        sort: \WorkoutProgram.title,
        order: .forward,
        animation: .default
        ) private var programs: [WorkoutProgram]
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.modelContext) var context
    @State private var showSocialPortal = false
    @State private var showSignoutAlert = false
    @State private var navigateToSettings = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                HeaderView()
                Text("Select a Program")
                    .font(.system(size: 24, weight: .bold))
                    .padding(0)
                    .foregroundColor(.white)
                if let uid = auth.user?.uid {
                    ProgramListView(userId: uid)
                } else {
                    ProgressView("Loading your programs...")
                        .tint(.white)
                }
                FloatingActionBar {
                    Spacer()
                    NavigationLink(destination: SocialPortal()) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .foregroundColor(.white)
                            .notificationBadge(show: auth.profile?.preferences.hasSocialUpdate ?? false)
                    }
                    Spacer()
                    NavigationLink(destination: AddWorkoutProgramView()) {
                        AddProgramButton(compact: true)
                            .foregroundColor(.white) // Ensure the "+" is white on the accent
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.white)
                            .notificationBadge(show: auth.profile?.preferences.hasSettingsUpdate ?? false)
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width - 40, height: 50)
                .background(theme.currentTheme.accent)
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .id(theme.currentTheme.id)
        .overlay {
            if programs.isEmpty {
                EmptyStateView()
            }
        }
        .toolbarBackground(.hidden, for: .bottomBar)
        .alert(isPresented: $showSignoutAlert) {
            Alert(
                title: Text("Log Out Confirmation"),
                message: Text("Are you sure you want to log out of FiT?"),
                primaryButton: .destructive(Text("Log Out")) {
                    auth.signOut()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
