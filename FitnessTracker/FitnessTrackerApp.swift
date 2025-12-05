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

@main
struct FitnessTrackerApp: App {
    @StateObject private var authManager = AuthManager()
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            ContentView()
                .environmentObject(authManager)
            #else
            Auth()
            #endif
        }
        .modelContainer(for: [WorkoutProgram.self, Exercise.self, Session.self, ExerciseCategory.self, WorkoutEntry.self])
    }
}
