//
//  SyncManager.swift
//  FitnessTracker
//
//  Created by Matt on 1/19/26.
//
import Foundation
import FirebaseFirestore
import SwiftUI

class SyncManager: ObservableObject {
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    static let shared = SyncManager()

    // 1. Improved Clear: Removes all user-specific keys on logout
    func clearLocalDefaults(for userId: String) {
        let prefix = "user_\(userId)"
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }

    // 2. The Main Upload: Maps local keys to Firestore fields
    func uploadAllToCloud(userId: String, keyScope: DefaultsKeyScope, manualPayload: [String: Any]? = nil, exerciseName: String? = nil) {
        let db = Firestore.firestore()
        
        // 1. If we have a specific exercise being saved right now, prioritize its data
        if let name = exerciseName, let payload = manualPayload {
            db.collection("Users").document(userId)
              .collection("weightEntries").document(name)
              .setData(payload, merge: true)
        }

        // 2. Sync everything else in the background
        let prefix = "user_\(userId).note"
        let allKeys = defaults.dictionaryRepresentation().keys
        let exerciseNames = allKeys.compactMap { key -> String? in
            guard key.hasPrefix(prefix) else { return nil }
            return String(key.dropFirst(prefix.count))
        }

        for ex in exerciseNames {
            if ex == exerciseName { continue } // Skip the one we just handled manually
            
            let setsCount = max(1, defaults.integer(forKey: keyScope.scoped("sets\(ex)")))
            var setsMap: [String: Any] = [:]
            
            for idx in 0..<setsCount {
                let isIso = defaults.bool(forKey: keyScope.scoped("iso\(ex)_set\(idx)"))
                var setValues: [String: Any] = [
                    "iso": isIso,
                    "reps": defaults.integer(forKey: keyScope.scoped("reps\(ex)_set\(idx)")),
                    "rest": defaults.integer(forKey: keyScope.scoped("rest\(ex)_set\(idx)"))
                ]
                if isIso {
                    setValues["left"] = defaults.integer(forKey: keyScope.scoped("left\(ex)_set\(idx)"))
                    setValues["right"] = defaults.integer(forKey: keyScope.scoped("right\(ex)_set\(idx)"))
                } else {
                    setValues["combined"] = defaults.integer(forKey: keyScope.scoped("weight\(ex)_set\(idx)"))
                }
                setsMap["\(idx)"] = setValues
            }

            let payload: [String: Any] = [
                "sets": setsMap,
                "note": defaults.string(forKey: keyScope.scoped("note\(ex)")) ?? "",
                "updatedAt": FieldValue.serverTimestamp()
            ]

            db.collection("Users").document(userId)
              .collection("weightEntries").document(ex)
              .setData(payload, merge: true)
        }
    }
    // 3. The Main Fetch: Downloads all exercise documents and restores UserDefaults
    func fetchAllFromCloud(userId: String, keyScope: DefaultsKeyScope) {
        db.collection("Users").document(userId)
          .collection("weightEntries").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else { return }
            
            for document in documents {
                let data = document.data()
                let ex = document.documentID // e.g. "Bench Press"
                
                // Restore top-level exercise info
                self.defaults.set(data["setsCount"] as? Int ?? 1, forKey: keyScope.scoped("sets\(ex)"))
                self.defaults.set(data["note"] as? String ?? "", forKey: keyScope.scoped("note\(ex)"))
                self.defaults.set(data["iso"] as? Bool ?? false, forKey: keyScope.scoped("iso\(ex)"))

                // Correctly parse the "sets" Map
                if let setsMap = data["sets"] as? [String: [String: Any]] {
                    for (key, setValues) in setsMap {
                        guard let idx = Int(key) else { continue }
                        let isIso = setValues["iso"] as? Bool ?? false
                        
                        self.defaults.set(isIso, forKey: keyScope.scoped("iso\(ex)_set\(idx)"))
                        self.defaults.set(setValues["reps"] as? Int ?? 0, forKey: keyScope.scoped("reps\(ex)_set\(idx)"))
                        self.defaults.set(setValues["rest"] as? Int ?? 0, forKey: keyScope.scoped("rest\(ex)_set\(idx)"))
                        
                        if isIso {
                            self.defaults.set(setValues["left"] as? Int ?? 0, forKey: keyScope.scoped("left\(ex)_set\(idx)"))
                            self.defaults.set(setValues["right"] as? Int ?? 0, forKey: keyScope.scoped("right\(ex)_set\(idx)"))
                        } else {
                            self.defaults.set(setValues["combined"] as? Int ?? 0, forKey: keyScope.scoped("weight\(ex)_set\(idx)"))
                        }
                    }
                }
            }
            // Trigger UI refresh
            NotificationCenter.default.post(name: NSNotification.Name("DataSynced"), object: nil)
        }
    }
}
