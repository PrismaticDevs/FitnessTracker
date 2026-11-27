//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//
// Create and customise your own workout programs

import SwiftUI
import SwiftData
import Firebase
import FirebaseAppCheck
import FirebaseFirestore
import GoogleSignIn

@main
struct FitnessTrackerApp: App {
    @StateObject private var auth = AuthManager()
    init() {
        // App Check must be configured BEFORE FirebaseApp.configure().
        // On simulator/debug builds, use the debug provider so the AI Logic
        // API calls succeed. On real device release builds, App Attest is used.
        #if DEBUG
        AppCheck.setAppCheckProviderFactory(AppCheckDebugProviderFactory())
        #else
        AppCheck.setAppCheckProviderFactory(AppAttestProviderFactory())
        #endif

        //Firebase and Firestore
        FirebaseApp.configure()
        // 1. Explicitly Enable Offline Persistence
        let settings = FirestoreSettings()
        // Use the modern cache configuration for better performance
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Couldn't get clientID from FirebaseApp")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.user == nil {
                    FirebaseAuthView()
                } else if !auth.isBiometricallyUnlocked {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                        Text("Login Required")
                        Button("Use FaceID") {
                            auth.requestBiometricUnlock()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(ThemeManager.shared.currentTheme.accent)
                    }
                    .onAppear { auth.requestBiometricUnlock() }
                } else {
                    ContentView()
                }
            }
            .environmentObject(auth)
            .onAppear { ThemeManager.shared.applyAppearance() }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
        .modelContainer(for: [WorkoutProgram.self, Exercise.self, Session.self, ExerciseCategory.self, StrengthEntry.self, CardioEntry.self, MobilityEntry.self])
    }
}
