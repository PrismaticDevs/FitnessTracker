//
//  FirestoreService.swift
//  FitnessTracker
//
//  Created by Matt on 12/13/25.
//
import Foundation
import FirebaseFirestore

private func convertToFirestoreDocument(entry: StrengthEntry, userId: String) -> [String: Any] {
    return [
        "userId": userId,
        "exercise": entry.exercise,
        "date": entry.date,
        "sets": entry.sets.map { set -> [String: Any] in
            [
                "id": set.id.uuidString,
                "combined": set.combined,
                "left": set.left,
                "right": set.right,
                "reps": set.reps,
                "rest": set.rest
            ]
        },
        "note": entry.note ?? NSNull()
    ]
}

private func convertFirestoreDocumentToStrengthEntry(data: [String: Any]) -> StrengthEntry? {
    guard
        let exercise = data["exercise"] as? String,
        let setsData = data["sets"] as? [[String: Any]]
    else { return nil }
    
    // Handle Firestore Timestamp or Date for the date field
    let date: Date
    if let ts = data["date"] as? Timestamp {
        date = ts.dateValue()
    } else if let d = data["date"] as? Date {
        date = d
    } else {
        return nil
    }
    
    let sets = setsData.compactMap { setData -> SetRecord? in
        guard
            let idString = setData["id"] as? String,
            let id = UUID(uuidString: idString),
            let combined = setData["combined"] as? Int,
            let left = setData["left"] as? Int,
            let right = setData["right"] as? Int,
            let reps = setData["reps"] as? Int,
            let rest = setData["rest"] as? Int
        else { return nil }
        
        return SetRecord(
            id: id,
            combined: combined,
            left: left,
            right: right,
            reps: reps,
            rest: rest
        )
    }
    
    return StrengthEntry(
        exercise: exercise,
        date: date,
        sets: sets,
        note: data["note"] as? String,
        programTitle: (data["programTitle"] as? String) ?? ""
    )
}

@MainActor
class FirestoreService: ObservableObject {
private let db = Firestore.firestore()

/// Save a workout entry to Firestore
    func saveStrengthEntry(for authManager: AuthManager, entry: StrengthEntry) {
        // Ensure user is authenticated
        guard let userId = authManager.user?.uid else {
            print("No authenticated user")
            return
        }
        
        do {
            // Reference to the user's workout entries collection
            let workoutEntriesRef = db.collection("users").document(userId).collection("workoutEntries")
            
            // Convert SwiftData entry to Firestore-compatible dictionary
            let firestoreEntry = convertToFirestoreDocument(entry: entry, userId: userId)
            
            // Add a new document with an auto-generated ID
            workoutEntriesRef.addDocument(data: firestoreEntry) { error in
                if error != nil {
                    print("Error saving workout entry: \\(error.localizedDescription)")
                } else {
                    print("Workout entry saved successfully")
                }
            }
        }
    }
    
/// Fetch workout entries for a specific exercise
    func fetchWorkoutEntries(for authManager: AuthManager, exercise: String, completion: @escaping ([StrengthEntry]) -> Void) {
        guard let userId = authManager.user?.uid else {
            print("No authenticated user")
            completion([])
            return
        }
        
        db.collection("users").document(userId).collection("workoutEntries")
            .whereField("exercise", isEqualTo: exercise)
            .order(by: "date", descending: true)
            .getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Error fetching workout entries: \\(error.localizedDescription)")
                    completion([])
                    return
                }
                
                let entries: [StrengthEntry] = querySnapshot?.documents.compactMap { document in
                    let data = document.data()
                    return convertFirestoreDocumentToStrengthEntry(data: data)
                } ?? []
                
                completion(entries)
            }
    }
}

