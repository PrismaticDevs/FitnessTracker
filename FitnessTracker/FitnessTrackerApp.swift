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
import GoogleSignIn

@main
struct FitnessTrackerApp: App {
    @StateObject private var authManager = AuthManager()
    init() {
        FirebaseApp.configure()
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("Couldn't get clientID from FirebaseApp")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.user != nil {
                    ContentView()
                } else {
                    FirebaseAuthView()
                }
            }
            .environmentObject(authManager)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
        .modelContainer(for: [WorkoutProgram.self, Exercise.self, Session.self, ExerciseCategory.self, StrengthEntry.self])
    }
}
