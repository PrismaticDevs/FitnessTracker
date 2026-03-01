//  SyncManager.swift
//  FitnessTracker
//
//  Created by Matt on 1/19/26.

import Foundation
import FirebaseFirestore
import SwiftUI
import SwiftData

enum SyncStatus: String, Codable {
    case synced        // Local and Cloud are identical
    case localNewer    // User worked out, but hasn't uploaded yet
    case cloudNewer    // User worked out on another device; local is old
    case notInCloud    // This workout history exists only on this phone
    case conflict      // Both have changed since last sync
}

@MainActor
class SyncManager: ObservableObject {
    @Published var currentStatus: SyncStatus = .synced
    private let db = Firestore.firestore()
    private let defaults = UserDefaults.standard
    static let shared = SyncManager()
    
    // MARK: - Blueprints (UserDefaults Sync)
    // Keep this as is - it handles your "last used" weights/reps per exercise
    func uploadAllToCloud(userId: String, keyScope: DefaultsKeyScope, manualPayload: [String: Any]? = nil, exerciseName: String? = nil) {
        if let name = exerciseName, let payload = manualPayload {
            db.collection("users").document(userId)
              .collection("workout_blueprints").document(name)
              .setData(payload, merge: true)
        }

        let prefix = "user_\(userId).note"
        let allKeys = defaults.dictionaryRepresentation().keys
        let exerciseNames = allKeys.compactMap { key -> String? in
            guard key.hasPrefix(prefix) else { return nil }
            return String(key.dropFirst(prefix.count))
        }

        for ex in exerciseNames {
            if ex == exerciseName { continue }
            
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

            db.collection("users").document(userId)
              .collection("workout_blueprints").document(ex)
              .setData(payload, merge: true)
        }
    }

    // MARK: - Completed Sessions Sync (SwiftData)
    
    /// Uploads a specific completed workout session to the cloud
    func uploadCompletedSession(userId: String, session: CompletedSession) async throws {
        let sessionRef = db.collection("users").document(userId)
                           .collection("completed_sessions").document(session.id.uuidString)

        let payload: [String: Any] = [
            "id": session.id.uuidString,
            "date": Timestamp(date: session.date),
            "programTitle": session.programTitle,
            "sessionName": session.sessionName,
            "templateId": session.templateId?.uuidString ?? "",
            "strengthEntries": session.strengthEntries.map { e in
                [
                    "exercise": e.exercise,
                    "date": Timestamp(date: e.date),
                    "note": e.note ?? "",
                    "programTitle": e.programTitle ?? session.programTitle,
                    "sets": e.sets.map { s in
                        ["combined": s.combined, "left": s.left, "right": s.right, "reps": s.reps, "rest": s.rest]
                    }
                ]
            }
            // Add cardio/mobility mapping here if needed
        ]
        
        try await sessionRef.setData(payload)
    }

    /// Fetches all completed sessions from the cloud and merges them locally
    func fetchHistoryFromCloud(userId: String, context: ModelContext) {
        Task {
            do {
                let snapshot = try await db.collection("users").document(userId)
                    .collection("completed_sessions").getDocuments()
                
                for document in snapshot.documents {
                    let data = document.data()
                    let idString = data["id"] as? String ?? document.documentID
                    guard let uuid = UUID(uuidString: idString) else { continue }
                    
                    // Check if we already have this session locally
                    let descriptor = FetchDescriptor<CompletedSession>(predicate: #Predicate { $0.id == uuid })
                    let existing = try? context.fetch(descriptor).first
                    
                    if existing == nil {
                        let newSession = CompletedSession(
                            id: uuid,
                            date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                            programTitle: data["programTitle"] as? String ?? "Unknown Program",
                            sessionName: data["sessionName"] as? String ?? "Workout"
                        )
                        
                        // Map Strength Entries
                        if let strengthData = data["strengthEntries"] as? [[String: Any]] {
                            newSession.strengthEntries = strengthData.map { dict in
                                let setsData = dict["sets"] as? [[String: Any]] ?? []
                                let sets = setsData.map { s in
                                    SetRecord(id: UUID(),
                                              combined: s["combined"] as? Int ?? 0,
                                              left: s["left"] as? Int ?? 0,
                                              right: s["right"] as? Int ?? 0,
                                              reps: s["reps"] as? Int ?? 0,
                                              rest: s["rest"] as? Int ?? 0)
                                }
                                return StrengthEntry(
                                    exercise: dict["exercise"] as? String ?? "",
                                    date: (dict["date"] as? Timestamp)?.dateValue() ?? Date(),
                                    sets: sets,
                                    note: dict["note"] as? String,
                                    programTitle: dict["programTitle"] as? String ?? newSession.programTitle
                                )
                            }
                        }
                        
                        context.insert(newSession)
                    }
                }
                
                try context.save()
                print("History sync complete.")
                
            } catch {
                print("Failed to fetch history: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchUserHistory(userId: String, keyScope: DefaultsKeyScope) {
        // 1. Fetch the latest CompletedSessions from Firebase/Cloud
        // 2. Loop through them to find Personal Bests for each exercise
        // 3. Update UserDefaults using keyScope so the UI reflects the new data
        print("Syncing history for \(userId)...")
    }
}
