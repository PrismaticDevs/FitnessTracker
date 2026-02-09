//
//  Settings.swift
//  FitnessTracker
//
//  Created by Matt on 2/8/26.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthManager
    @ObservedObject var theme = ThemeManager.shared
    @State private var showProfile = false
    @State private var showLogoutAlert = false

    var body: some View {
        List {
            Section("User Profile") {
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(auth.profile?.display_name ?? auth.user?.displayName ?? "Fitness User")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(auth.user?.email ?? "No Email Found")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    Spacer()
                    Button("View") {
                        showProfile = true
                    }
                    .buttonStyle(.bordered)
                    .tint(theme.currentTheme.accent)
                }
                .padding(.vertical, 8)
            }
            .listRowBackground(theme.currentTheme.accent2)

            Section("App Customization") {
                Picker(selection: $theme.currentTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.rawValue).tag(theme)
                    }
                } label: {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .imageScale(.small)
                        Text("App Theme")
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .pickerStyle(.menu)            
                .tint(.white)
            }
            .listRowBackground(theme.currentTheme.accent2)
            
            Section("Data & Subscription") {
                Button {
                    // Future: Trigger App Store sheet
                } label: {
                    Label("Manage Subscription", systemImage: "creditcard")
                }
                
                Button {
                    // Future: Generate CSV/JSON of workouts
                } label: {
                    Label("Export Workout Data (.csv)", systemImage: "square.and.arrow.up")
                }
            }
            .listRowBackground(theme.currentTheme.accent2.opacity(0.8))

            Section {
                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    Label("Log Out", systemImage: "arrow.right.square")
                }
            }
            .listRowBackground(theme.currentTheme.accent2)
        }
        .navigationTitle("Settings")
        .navigationBarTitleTextColor(.white)
        .scrollContentBackground(.hidden)
        .applyGradientBackground()
        .tint(theme.currentTheme.accent2)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .alert("Log Out", isPresented: $showLogoutAlert) {
            Button("Log Out", role: .destructive) { auth.signOut() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .onAppear {
            Task {
                await auth.fetchUser()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
