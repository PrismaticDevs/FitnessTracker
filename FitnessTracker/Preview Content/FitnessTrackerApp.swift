//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI

@main
struct FitnessTrackerApp: App {
    @StateObject private var workoutHistory = WorkoutHistory() // Create the WorkoutHistory instance

    var body: some Scene {
        WindowGroup {
            Auth()
                .environmentObject(workoutHistory) // Provide the WorkoutHistory instance to the environment
        }
    }
}
