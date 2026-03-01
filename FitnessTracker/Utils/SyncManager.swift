////
////  SyncManager.swift
////  FitnessTracker
////
////  Created by Matt on 1/19/26.
////
//import Foundation
//import FirebaseFirestore
//import SwiftUI
//import SwiftData
//
//enum SyncStatus: String, Codable {
//    case synced        // Local and Cloud are identical
//    case localNewer    // User worked out, but hasn't uploaded yet
//    case cloudNewer    // User worked out on another device; local is old
//    case notInCloud    // This workout history exists only on this phone
//    case conflict      // Both have changed since last sync; requires merge logic
//}
//
//@MainActor
//class SyncManager: ObservableObject {
//    @Published var currentStatus: SyncStatus = .synced
//    private let db = Firestore.firestore()
//    private let defaults = UserDefaults.standard
//    static let shared = SyncManager()
//    
//    func fetchHistoryFromCloud(userId: String, context: ModelContext) {
//        db.collection("users").document(userId)
//          .collection("history").getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents else { return }
//            
//            for doc in documents {
//                let data = doc.data()
//                let idString = data["id"] as? String ?? ""
//                guard let id = UUID(uuidString: idString) else { continue }
//                
//                // Check if it already exists locally to prevent duplicates
//                let predicate = #Predicate<WorkoutHistory> { history in
//                    history.id == id
//                }
//                let fetchDescriptor = FetchDescriptor<WorkoutHistory>(predicate: predicate)
//                if let existing = try? context.fetch(fetchDescriptor), existing.isEmpty {
//                    
//                    // Parse Entries
//                    let entriesData = data["entries"] as? [[String: Any]] ?? []
//                    let strengthEntries = entriesData.map { eData in
//                        let setsData = eData["sets"] as? [[String: Any]] ?? []
//                        let setRecords = setsData.map { s in
//                            SetRecord(id: UUID(),
//                                      combined: s["combined"] as? Int ?? 0,
//                                      left: s["left"] as? Int ?? 0,
//                                      right: s["right"] as? Int ?? 0,
//                                      reps: s["reps"] as? Int ?? 0,
//                                      rest: s["rest"] as? Int ?? 0)
//                        }
//                        return StrengthEntry(exercise: eData["exercise"] as? String ?? "",
//                                             date: (eData["date"] as? Timestamp)?.dateValue() ?? (data["date"] as? Timestamp)?.dateValue() ?? Date(),
//                                             sets: setRecords,
//                                             note: eData["note"] as? String)
//                    }
//                    
//                    let history = WorkoutHistory(
//                        id: id,
//                        userId: userId,
//                        date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
//                        exercise: data["sessionName"] as? String ?? "Unknown Session",
//                        entries: strengthEntries
//                    )
//                    context.insert(history)
//                }
//            }
//            try? context.save()
//        }
//    }
//
//    // 1. Improved Clear: Removes all user-specific keys on logout
//    func clearLocalDefaults(for userId: String) {
//        let prefix = "user_\(userId)"
//        let allKeys = defaults.dictionaryRepresentation().keys
//        for key in allKeys where key.hasPrefix(prefix) {
//            defaults.removeObject(forKey: key)
//        }
//    }
//
//    // 2. The Main Upload: Maps local keys to Firestore fields
//    func uploadAllToCloud(userId: String, keyScope: DefaultsKeyScope, manualPayload: [String: Any]? = nil, exerciseName: String? = nil) {
//        let db = Firestore.firestore()
//        
//        // 1. If we have a specific exercise being saved right now, prioritize its data
//        if let name = exerciseName, let payload = manualPayload {
//            db.collection("users").document(userId)
//              .collection("workout_blueprints").document(name)
//              .setData(payload, merge: true)
//        }
//
//        // 2. Sync everything else in the background
//        let prefix = "user_\(userId).note"
//        let allKeys = defaults.dictionaryRepresentation().keys
//        let exerciseNames = allKeys.compactMap { key -> String? in
//            guard key.hasPrefix(prefix) else { return nil }
//            return String(key.dropFirst(prefix.count))
//        }
//
//        for ex in exerciseNames {
//            if ex == exerciseName { continue } // Skip the one we just handled manually
//            
//            let setsCount = max(1, defaults.integer(forKey: keyScope.scoped("sets\(ex)")))
//            var setsMap: [String: Any] = [:]
//            
//            for idx in 0..<setsCount {
//                let isIso = defaults.bool(forKey: keyScope.scoped("iso\(ex)_set\(idx)"))
//                var setValues: [String: Any] = [
//                    "iso": isIso,
//                    "reps": defaults.integer(forKey: keyScope.scoped("reps\(ex)_set\(idx)")),
//                    "rest": defaults.integer(forKey: keyScope.scoped("rest\(ex)_set\(idx)"))
//                ]
//                if isIso {
//                    setValues["left"] = defaults.integer(forKey: keyScope.scoped("left\(ex)_set\(idx)"))
//                    setValues["right"] = defaults.integer(forKey: keyScope.scoped("right\(ex)_set\(idx)"))
//                } else {
//                    setValues["combined"] = defaults.integer(forKey: keyScope.scoped("weight\(ex)_set\(idx)"))
//                }
//                setsMap["\(idx)"] = setValues
//            }
//
//            let payload: [String: Any] = [
//                "sets": setsMap,
//                "note": defaults.string(forKey: keyScope.scoped("note\(ex)")) ?? "",
//                "updatedAt": FieldValue.serverTimestamp()
//            ]
//
//            db.collection("users").document(userId)
//              .collection("workout_blueprints").document(ex)
//              .setData(payload, merge: true)
//        }
//    }
//    // 3. The Main Fetch: Downloads all exercise documents and restores UserDefaults
//    func fetchAllFromCloud(userId: String, keyScope: DefaultsKeyScope) {
//        // 1. Updated path to lowercase "users" and "exercise_entries" subcollection
//        db.collection("users").document(userId)
//          .collection("exercise_entries").getDocuments { snapshot, error in
//            guard let documents = snapshot?.documents, error == nil else { return }
//            
//            for document in documents {
//                let data = document.data()
//                let ex = document.documentID // e.g. "Abdominal Machine"
//                
//                // 2. Determine type (strength, cardio, mobility)
//                let type = data["type"] as? String ?? "strength"
//                
//                // Handle Strength Type
//                if type == "strength", let strengthData = data["strength_data"] as? [String: Any] {
//                    // Restore top-level exercise info
//                    let isIso = strengthData["iso"] as? Bool ?? false
//                    self.defaults.set(isIso, forKey: keyScope.scoped("iso\(ex)"))
//                    self.defaults.set(data["note"] as? String ?? "", forKey: keyScope.scoped("note\(ex)"))
//                    
//                    // 3. Parse the "sets" Map using your new nested structure
//                    if let setsMap = strengthData["sets"] as? [String: [String: Any]] {
//                        // Set the total sets count based on map size
//                        self.defaults.set(setsMap.count, forKey: keyScope.scoped("sets\(ex)"))
//                        
//                        for (key, setValues) in setsMap {
//                            guard let idx = Int(key) else { continue }
//                            
//                            // Save specific set data back to UserDefaults
//                            self.defaults.set(setValues["reps"] as? Int ?? 0, forKey: keyScope.scoped("reps\(ex)_set\(idx)"))
//                            self.defaults.set(setValues["rest"] as? Int ?? 0, forKey: keyScope.scoped("rest\(ex)_set\(idx)"))
//                            
//                            // Handle iso vs combined
//                            if isIso {
//                                self.defaults.set(setValues["left"] as? Int ?? 0, forKey: keyScope.scoped("left\(ex)_set\(idx)"))
//                                self.defaults.set(setValues["right"] as? Int ?? 0, forKey: keyScope.scoped("right\(ex)_set\(idx)"))
//                            } else {
//                                self.defaults.set(setValues["weight"] as? Int ?? 0, forKey: keyScope.scoped("weight\(ex)_set\(idx)"))
//                            }
//                        }
//                    }
//                }
//                
//                // Note: Add cardio/mobility parsing here later!
//            }
//            
//            // 4. Trigger UI refresh
//            NotificationCenter.default.post(name: NSNotification.Name("DataSynced"), object: nil)
//        }
//    }
//    
//    /// Overload to handle active 'Session' objects by converting them on the fly
//    func uploadWholeSession(from session: Session, userId: String) async throws {
//        // 1. Create a temporary WorkoutHistory object from the session data
//        // You'll need to map your session.exercises to [StrengthEntry] here
//        let history = WorkoutHistory(
//            id: UUID(), // Or session.id if you want them linked
//            userId: userId,
//            date: Date(),
//            exercise: session.name,
//            entries: [] // Add mapping logic for your session's current data
//        )
//        
//        // 2. Pass it to the history upload helper
//        self.uploadSessionHistory(userId: userId, history: history)
//    }
//    
//    func uploadSessionHistory(userId: String, history: WorkoutHistory) {
//        let historyRef = db.collection("Users").document(userId)
//                           .collection("history").document(history.id.uuidString)
//        
//        // Convert StrengthEntries and SetRecords to a dictionary format
//        let entriesData = history.entries.map { entry in
//            [
//                "exercise": entry.exercise,
//                "note": entry.note ?? "",
//                "sets": entry.sets.map { s in
//                    [
//                        "combined": s.combined,
//                        "left": s.left,
//                        "right": s.right,
//                        "reps": s.reps,
//                        "rest": s.rest
//                    ]
//                }
//            ]
//        }
//        
//        let payload: [String: Any] = [
//            "id": history.id.uuidString,
//            "date": Timestamp(date: history.date),
//            "sessionName": history.exercise, // Using the session name
//            "entries": entriesData
//        ]
//        
//        historyRef.setData(payload)
//    }
//    
//    func mapFirestoreToStrengthEntry(docData: [String: Any]) -> [SetRecord] {
//        guard let strengthData = docData["strength_data"] as? [String: Any],
//              let setsMap = strengthData["sets"] as? [String: [String: Any]] else {
//            return []
//        }
//        
//        // Sort the keys ("0", "1", "2") to keep sets in order
//        let sortedKeys = setsMap.keys.sorted { Int($0) ?? 0 < Int($1) ?? 0 }
//        
//        return sortedKeys.compactMap { key in
//            let val = setsMap[key]!
//            return SetRecord(
//                id: UUID(),
//                combined: val["weight"] as? Int ?? 0,
//                left: val["left"] as? Int ?? 0,
//                right: val["right"] as? Int ?? 0,
//                reps: val["reps"] as? Int ?? 0,
//                rest: val["rest"] as? Int ?? 0
//            )
//        }
//    }
//    
//    func checkSyncStatus(for userId: String, localHistory: WorkoutHistory) async -> SyncStatus {
//        // 1. Fetch the corresponding document from Firestore
//        let remoteDoc = try? await db.collection("users").document(userId)
//            .collection("history").document(localHistory.id.uuidString).getDocument()
//        
//        guard let remoteData = remoteDoc?.data() else { return .notInCloud }
//        
//        let remoteTimestamp = remoteData["lastUpdated"] as? Date ?? .distantPast
//        let remoteEntryCount = remoteData["entryCount"] as? Int ?? 0
//        
//        // 2. Compare with Local SwiftData
//        if localHistory.lastUpdated > remoteTimestamp {
//            return .localNewer // Prompt to Push
//        } else if localHistory.lastUpdated < remoteTimestamp {
//            return .cloudNewer // Prompt to Pull
//        } else {
//            return .synced
//        }
//    }
//    
//    func compareLocalToCloud(localHistory: WorkoutHistory) async {
//            guard let userId = localHistory.userId.isEmpty ? nil : localHistory.userId else { return }
//
//            let docRef = db.collection("users").document(userId)
//                          .collection("history").document(localHistory.id.uuidString)
//
//            do {
//                let snapshot = try await docRef.getDocument()
//                
//                if !snapshot.exists {
//                    DispatchQueue.main.async { self.currentStatus = .notInCloud }
//                    return
//                }
//
//                let remoteData = snapshot.data()
//                let remoteTimestamp = (remoteData?["lastUpdated"] as? Timestamp)?.dateValue() ?? .distantPast
//
//                DispatchQueue.main.async {
//                    if localHistory.lastUpdated > remoteTimestamp {
//                        self.currentStatus = .localNewer
//                    } else if localHistory.lastUpdated < remoteTimestamp {
//                        self.currentStatus = .cloudNewer
//                    } else {
//                        self.currentStatus = .synced
//                    }
//                }
//            } catch {
//                print("Sync check failed: \(error)")
//            }
//        }
//    
//}
