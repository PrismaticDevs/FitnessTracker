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
private let didRunNamespaceMigrationKey = "didRunNamespaceMigration_v1"

public struct DataMigration {
    
    /// Main entry point for all startup migrations.
    public static func runAll(context: ModelContext, userId: String?) {
        runOneTimeExerciseTypeBackfill(context: context)
        
        if let userId = userId {
            runOneTimeNamespaceMigration(userId: userId)
        }
    }

    /// Backfills Exercise.type to .strength for existing SwiftData records.
    private static func runOneTimeExerciseTypeBackfill(context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: didRunExerciseTypeBackfillKey) else { return }

        do {
            let descriptor = FetchDescriptor<Exercise>()
            let exercises = try context.fetch(descriptor)

            for exercise in exercises {
                exercise.type = .strength
            }

            try context.save()
            defaults.set(true, forKey: didRunExerciseTypeBackfillKey)
            print("✅ SwiftData Exercise Type Backfill Complete")
        } catch {
            print("❌ Exercise type backfill failed: \(error)")
        }
    }

    private static func runOneTimeNamespaceMigration(userId: String) {
        let defaults = UserDefaults.standard
        let flagKey = "\(didRunNamespaceMigrationKey).\(userId)"
        guard !defaults.bool(forKey: flagKey) else { return }

        let allKeys = defaults.dictionaryRepresentation().keys
        
        // 1. Migrate base keys (setsCount, notes, etc.)
        for key in allKeys {
            // Skip keys already namespaced or system keys
            if !key.hasPrefix("user_") && !key.hasPrefix("apple") && !key.hasPrefix("com.apple") {
                let value = defaults.object(forKey: key)
                let namespacedKey = "user_\(userId).\(key)"
                
                // Only copy if the namespaced version doesn't exist yet
                if defaults.object(forKey: namespacedKey) == nil {
                    defaults.set(value, forKey: namespacedKey) // Fixed the argument label here
                }
            }
        }

        // 2. Explicitly migrate per-set keys
        // We find every key that looks like "setsExerciseName" to identify the exercises
        let setCountKeys = allKeys.filter { $0.hasPrefix("sets") && !$0.hasPrefix("user_") }
        
        for fullSetKey in setCountKeys {
            // Extract the exercise name (e.g., "Bench Press" from "setsBench Press")
            let exerciseName = fullSetKey.replacingOccurrences(of: "sets", with: "")
            let setCount = defaults.integer(forKey: fullSetKey)
            
            // Loop through the sets to move the set-specific data
            for i in 0..<setCount {
                let suffixes = ["weight", "left", "right", "reps", "rest", "iso"]
                for suffix in suffixes {
                    let oldKey = "\(suffix)\(exerciseName)_set\(i)"
                    let namespacedKey = "user_\(userId).\(oldKey)"
                    
                    // If the old data exists, move it to the namespaced key
                    if let value = defaults.object(forKey: oldKey) {
                        if defaults.object(forKey: namespacedKey) == nil {
                            defaults.set(value, forKey: namespacedKey)
                        }
                    }
                }
            }
        }

        defaults.set(true, forKey: flagKey)
        print("✅ Comprehensive Namespace Migration Complete for \(userId)")
    }
    
}
