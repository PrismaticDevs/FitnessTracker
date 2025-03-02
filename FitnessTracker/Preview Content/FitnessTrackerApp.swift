//
//  FitnessTrackerApp.swift
//  FitnessTracker
//
//  Created by Matt on 10/1/24.
//

import SwiftUI
import SwiftData

@main
struct FitnessTrackerApp: App {

    var body: some Scene {
        WindowGroup {
            #if DEBUG
            ContentView()
            #else
            Auth()
            #endif
        }
        .modelContainer(for: [WorkoutProgram.self, Exercise.self, Session.self, ExerciseCategory.self])
    }
}
