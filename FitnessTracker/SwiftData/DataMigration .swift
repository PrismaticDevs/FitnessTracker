//  DataMigration.swift
//  FitnessTracker
//
//  Created by Assistant on 1/11/26.
//
//  This file provides a one-time migration utility to backfill Exercise.type to .strength
//  for existing persisted data that predates the introduction of the `type` property.

import Foundation
import SwiftUI
import SwiftData

private let didRunExerciseTypeBackfillKey = "didRunExerciseTypeBackfill"

/// Run once to ensure all existing Exercise records have a valid `type`.
/// - Note: Call this early in app startup (e.g., in App body via `.task {}`) after the model context is available.
public func runOneTimeExerciseTypeBackfill(context: ModelContext) {
    // Ensure we only run this once on a given install.
    let defaults = UserDefaults.standard
    guard defaults.bool(forKey: didRunExerciseTypeBackfillKey) == false else { return }

    do {
        let descriptor = FetchDescriptor<Exercise>()
        let exercises = try context.fetch(descriptor)

        var didChange = false
        for exercise in exercises {
            // If your model currently defines `type` as optional, only set when nil.
            // If it is non-optional, you can still assign to be defensive.
            // The code below assumes non-optional with a desire to force-set all to `.strength` once.
            exercise.type = .strength
            didChange = true
        }

        if didChange {
            try context.save()
        }

        defaults.set(true, forKey: didRunExerciseTypeBackfillKey)
    } catch {
        // If the migration fails, do not set the flag to allow retry on next launch.
        print("Exercise type backfill failed: \(error)")
    }
}
