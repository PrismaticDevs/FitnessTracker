import Foundation

/// Handles one-time migrations of UserDefaults keys when scoping changes.
struct DefaultsMigration {
    /// A unique flag to ensure we only migrate once per app install/version for this case.
    /// If you need to re-run in future, bump the suffix (e.g., _v2).
    static let migratedStrengthEntriesFlag = "didMigrateStrengthEntriesToScopedKeys_v1"

    /// Migrates a single base key from a legacy scope (userID only) to the new scope which may include program/session.
    /// - Parameters:
    ///   - legacyScope: A scope representing the old format (userID only).
    ///   - newScope: The new scoped format (may include programID/sessionID).
    ///   - baseKey: The base key to migrate (e.g., "strengthEntries").
    static func migrateIfNeeded(
        legacyScope: DefaultsKeyScope,
        newScope: DefaultsKeyScope,
        baseKey: String
    ) {
        let defaults = UserDefaults.standard

        // If we've already migrated, do nothing.
        if defaults.bool(forKey: migratedStrengthEntriesFlag) { return }

        let oldKey = legacyScope.legacyScoped(baseKey)
        let newKey = newScope.scoped(baseKey)

        // If new key already exists, mark migrated and return.
        if defaults.object(forKey: newKey) != nil {
            defaults.set(true, forKey: migratedStrengthEntriesFlag)
            return
        }

        // Attempt to read the old value and move it to the new key.
        if let value = defaults.object(forKey: oldKey) {
            defaults.set(value, forKey: newKey)
            // Optionally remove the old key. Uncomment if desired.
            // defaults.removeObject(forKey: oldKey)
        }

        // Mark migration done either way to avoid repeated work.
        defaults.set(true, forKey: migratedStrengthEntriesFlag)
    }
}
