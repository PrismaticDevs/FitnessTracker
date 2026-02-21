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
    @Environment(\.dismiss) var dismiss
    @State private var showProfile = false
    @State private var showLogoutAlert = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
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
                            NavigationLink(destination: ProfileView()) {
                                HStack {
                                    Text("View")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                            }
                            .fixedSize()
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
                            HStack {
                                Image(systemName: "arrow.right.square")
                                Text("Sign Out")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(theme.currentTheme.accent2.opacity(0.8))
                }
                .padding(.top, 120)
                .brandedBackButton(title: "Settings", theme: theme.currentTheme, dismiss: dismiss)
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
                    Task {
                        await auth.clearNotification(for: .settings)
                    }
                }
            }
            .offset(x: dragOffset)
            .animation(.interactiveSpring(), value: dragOffset)
            // Leading-edge swipe back hit area to avoid ScrollView conflicts
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .leading) {
                    Color.clear
                        .frame(width: 24) // leading-edge grab area
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 10, coordinateSpace: .local)
                                .onChanged { value in
                                    // Only respond to drags that start near the leading edge and move right
                                    if value.startLocation.x < 24, value.translation.width > 0 {
                                        dragOffset = value.translation.width
                                    }
                                }
                                .onEnded { value in
                                    if value.startLocation.x < 24, value.translation.width > 80 {
                                        dismiss()
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                                }
                        )
                }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
