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

    // 1. KEEP: Essential for security and multi-user support
    func clearLocalDefaults(for userId: String) {
        let prefix = "user_\(userId)"
        let allKeys = defaults.dictionaryRepresentation().keys
        for key in allKeys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }

    // 2. CHANGE: Updated to handle the specific document path you use
    func uploadExercise(userId: String, exerciseName: String, payload: [String: Any]) {
        db.collection("Users").document(userId)
          .collection("WeightEntry").document("ji6X7gqtCCH7zz21Y4qI")
          .setData([exerciseName: payload], merge: true) { error in
              if let error = error {
                  print("Error syncing \(exerciseName): \(error.localizedDescription)")
              }
          }
    }

    // 3. NEW: Move the "Save All" logic here to slim down StrengthEntryView
    func uploadAllToCloud(userId: String, keyScope: DefaultsKeyScope) {
        let prefix = "user_\(userId).note"
        let allKeys = defaults.dictionaryRepresentation().keys
        
        let exerciseNames = allKeys.compactMap { key -> String? in
            guard key.hasPrefix(prefix) else { return nil }
            return String(key.dropFirst(prefix.count))
        }.filter { !$0.isEmpty }

        var combinedPayload: [String: Any] = [:]
        
        for ex in exerciseNames {
            let setsCount = max(1, defaults.integer(forKey: keyScope.scoped("sets\(ex)")))
            var setsArray: [[String: Any]] = []
            
            for idx in 0..<setsCount {
                let isIso = defaults.bool(forKey: keyScope.scoped("iso\(ex)_set\(idx)"))
                var setDict: [String: Any] = [
                    "index": idx,
                    "iso": isIso,
                    "reps": defaults.integer(forKey: keyScope.scoped("reps\(ex)_set\(idx)")),
                    "rest": defaults.integer(forKey: keyScope.scoped("rest\(ex)_set\(idx)"))
                ]
                
                if isIso {
                    setDict["left"] = defaults.integer(forKey: keyScope.scoped("left\(ex)_set\(idx)"))
                    setDict["right"] = defaults.integer(forKey: keyScope.scoped("right\(ex)_set\(idx)"))
                } else {
                    setDict["combined"] = defaults.integer(forKey: keyScope.scoped("weight\(ex)_set\(idx)"))
                }
                setsArray.append(setDict)
            }

            combinedPayload[ex] = [
                "exercise": ex,
                "setsCount": setsCount,
                "sets": setsArray,
                "note": defaults.string(forKey: keyScope.scoped("note\(ex)")) ?? "",
                "updatedAt": Date().timeIntervalSince1970
            ]
        }

        db.collection("Users").document(userId)
          .collection("WeightEntry").document("ji6X7gqtCCH7zz21Y4qI")
          .setData(combinedPayload, merge: true)
    }
    
    func fetchAllFromCloud(userId: String, keyScope: DefaultsKeyScope) {
        db.collection("Users").document(userId)
          .collection("WeightEntry").document("ji6X7gqtCCH7zz21Y4qI")
          .getDocument { document, error in
              guard let data = document?.data(), error == nil else { return }
              
              for (exerciseName, exerciseData) in data {
                  guard let dict = exerciseData as? [String: Any],
                        let sets = dict["sets"] as? [[String: Any]] else { continue }
                  
                  // Restore Note and Sets Count
                  let setsCount = dict["setsCount"] as? Int ?? 1
                  self.defaults.set(setsCount, forKey: keyScope.scoped("sets\(exerciseName)"))
                  self.defaults.set(dict["note"] as? String ?? "", forKey: keyScope.scoped("note\(exerciseName)"))
                  
                  // Restore individual set data
                  for setData in sets {
                      let idx = setData["index"] as? Int ?? 0
                      let iso = setData["iso"] as? Bool ?? false
                      
                      self.defaults.set(iso, forKey: keyScope.scoped("iso\(exerciseName)_set\(idx)"))
                      self.defaults.set(setData["reps"] as? Int ?? 0, forKey: keyScope.scoped("reps\(exerciseName)_set\(idx)"))
                      self.defaults.set(setData["rest"] as? Int ?? 0, forKey: keyScope.scoped("rest\(exerciseName)_set\(idx)"))
                      
                      if iso {
                          self.defaults.set(setData["left"] as? Int ?? 0, forKey: keyScope.scoped("left\(exerciseName)_set\(idx)"))
                          self.defaults.set(setData["right"] as? Int ?? 0, forKey: keyScope.scoped("right\(exerciseName)_set\(idx)"))
                      } else {
                          self.defaults.set(setData["combined"] as? Int ?? 0, forKey: keyScope.scoped("weight\(exerciseName)_set\(idx)"))
                      }
                  }
              }
              // Notify the UI to refresh
              NotificationCenter.default.post(name: NSNotification.Name("DataSynced"), object: nil)
          }
    }
}
