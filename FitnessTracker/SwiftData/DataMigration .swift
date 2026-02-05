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

    /// Moves legacy global keys (e.g. "bench_press_weight")
    /// to the first-tier namespace (e.g. "user_123.bench_press_weight").
    private static func runOneTimeNamespaceMigration(userId: String) {
        let defaults = UserDefaults.standard
        let flagKey = "\(didRunNamespaceMigrationKey).\(userId)"
        guard !defaults.bool(forKey: flagKey) else { return }

        // We don't need a map here; we can just find all keys that
        // don't start with "user_" and prefix them.
        let allKeys = defaults.dictionaryRepresentation().keys
        
        for key in allKeys {
            // Avoid migrating system keys or keys already namespaced
            if !key.contains(".") && !key.hasPrefix("apple") && !key.hasPrefix("com.apple") {
                let value = defaults.object(forKey: key)
                let namespacedKey = "user_\(userId).\(key)"
                
                // Only copy if the namespaced version doesn't exist yet
                if defaults.object(forKey: namespacedKey) == nil {
                    defaults.set(value, forKey: namespacedKey)
                }
            }
        }

        defaults.set(true, forKey: flagKey)
        print("✅ User Namespace Migration Complete for \(userId)")
    }
}
