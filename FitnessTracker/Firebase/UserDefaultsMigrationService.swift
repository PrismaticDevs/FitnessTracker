//  UserDefaultsMigrationService.swift
//  FitnessTracker
//
//  Created by Assistant on 12/14/25.

import Foundation

/// Handles one-time migration from legacy UserDefaults keys to new per-user namespaced keys.
/// New key format: "<userId>.<key>"
struct UserDefaultsMigrationService {
    private let defaults: UserDefaults
    private let migrationFlagBase = "com.fitnesstracker.migration.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Migrate legacy keys to per-user keys. Safe to call multiple times; runs once per user.
    /// - Parameters:
    ///   - userId: The authenticated user's id used for namespacing.
    ///   - oldToNewKeyMap: Map of legacy key -> new key name (without userId prefix).
    func migrateIfNeeded(for userId: String, oldToNewKeyMap: [String: String]) {
        let flagKey = "\(migrationFlagBase).\(userId)"
        if defaults.bool(forKey: flagKey) { return }

        for (oldKey, newKey) in oldToNewKeyMap {
            let namespaced = namespacedKey(userId: userId, key: newKey)
            if defaults.object(forKey: namespaced) != nil {
                continue // already migrated for this key
            }
            if let value = defaults.object(forKey: oldKey) {
                defaults.set(value, forKey: namespaced)
            }
        }

        defaults.set(true, forKey: flagKey)
    }

    /// Utility to build namespaced keys consistently.
    func namespacedKey(userId: String, key: String) -> String {
        return "\(userId).\(key)"
    }
}
