//  UserDefaultsMigrationService.swift
//  FitnessTracker
//
//  Created by Assistant on 12/14/25.

import Foundation

import Foundation

class UserDefaultsMigrationService {
    private let defaults: UserDefaults
    private let migrationFlagBase = "com.fitnesstracker.migration.v2"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// LEVEL 2 MIGRATION: Migrates from user-namespaced keys to Program/Session specific keys.
    /// New Key: user_<userId>.<programId>.<sessionId>.<baseKey>
    func migrateToContextual(userId: String, programId: String, sessionId: String, exercises: [String]) {
        let flagKey = "\(migrationFlagBase).\(userId).\(programId).\(sessionId)"
        if defaults.bool(forKey: flagKey) {
                    print("ℹ️ Migration already completed for this session.")
                    return
                }

                print("🚀 Starting Contextual Migration for \(programId) / \(sessionId)...")

        // We are moving data FROM: "user_<userId>.<baseKey>"
        // TO: "user_<userId>.<programId>.<sessionId>.<baseKey>"
        
        for exName in exercises {
            // Define the base patterns we need to move for each exercise
            let patterns = [
                "sets\(exName)",
                "note\(exName)",
                "iso\(exName)"
            ]
            
            // 1. Move basic exercise settings
            for pattern in patterns {
                let sourceKey = "user_\(userId).\(pattern)"
                let destinationKey = "user_\(userId).\(programId).\(sessionId).\(pattern)"
                copyValue(from: sourceKey, to: destinationKey)
            }

            // 2. Move Set-specific data (loops through up to 15 sets)
            for i in 0..<15 {
                let setPatterns = [
                    "reps\(exName)_set\(i)",
                    "weight\(exName)_set\(i)",
                    "rest\(exName)_set\(i)",
                    "left\(exName)_set\(i)",
                    "right\(exName)_set\(i)",
                    "iso\(exName)_set\(i)"
                ]
                
                for pattern in setPatterns {
                    let sourceKey = "user_\(userId).\(pattern)"
                    let destinationKey = "user_\(userId).\(programId).\(sessionId).\(pattern)"
                    copyValue(from: sourceKey, to: destinationKey)
                }
            }
        }

        defaults.set(true, forKey: flagKey)
        print("✅ Contextual Migration Complete for \(programId) / \(sessionId)")
    }

    private func copyValue(from source: String, to destination: String) {
        // Only copy if source exists and destination is currently empty
        if let value = defaults.object(forKey: source),
           defaults.object(forKey: destination) == nil {
            defaults.set(value, forKey: destination)
        }
    }
}
