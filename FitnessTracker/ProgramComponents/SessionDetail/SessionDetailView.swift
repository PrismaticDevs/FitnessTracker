//
//  SessionDetailView.swift
//  FitnessTracker
//
//  Created by Matt on 3/1/25.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    @ObservedObject var theme = ThemeManager.shared
    var defaults = UserDefaults.standard
    var session: Session
    var workoutProgram: WorkoutProgram // This is the property holding the program
    var exercises: [Exercise]
    
    @Environment(\.modelContext) var context
    @Environment(AIContextManager.self) var aiManager
    @EnvironmentObject var auth: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var editMode: EditMode = .inactive
    @State private var completedExerciseIds: Set<UUID> = []
    var liveCompletedCount: Int {
        session.exercises.filter { $0.isCompleted }.count
    }
    @State private var dragOffset: CGFloat = 0
    @State private var showingRenameSheet = false
    @State private var newSessionName: String = ""
    
    // Save/Upload State
    @State private var network = NetworkMonitor()
    @State private var hasSavedLocally = false
    @State private var isUploading = false
    @State private var showSyncError = false
    
    

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 120)
                
                ExerciseListSection(
                    session: session,
                    workoutProgram: workoutProgram, // Pass workoutProgram directly
                    completedExerciseIds: $completedExerciseIds,
                    onDelete: deleteExercise
                )
                
                BottomControls(
                    session: session,
                    theme: theme,
                    isUploading: isUploading,
                    isOnline: network.isConnected,
                    hasSavedLocally: hasSavedLocally, // Direct access to the property
                    onRename: {
                        newSessionName = session.name
                        showingRenameSheet = true
                    },
                    onAdd: addExercise,
                    onSave: {
                        if !hasSavedLocally { handleLocalSave() }
                        else { handleCloudUpload() }
                    }
                )
                
            }
            .offset(x: dragOffset)
            .applyAppBranding()
            
            LeadingEdgeDragHandler(dragOffset: $dragOffset, onDismiss: { dismiss() })
        }
        .brandedBackButton(title: session.name, theme: theme.currentTheme, dismiss: dismiss)
        .sheet(isPresented: $showingRenameSheet) {
            RenameSheet(newName: $newSessionName, onRename: renameSession)
        }
    }

    // MARK: - Reordering Logic
    private func startCloudUpload() {
        guard network.isConnected else {
            showSyncError = true
            return
        }
        guard let userId = auth.user?.uid else {
            showSyncError = true
            return
        }
        
        isUploading = true
        
//        Task {
//            do {
//                // Pass the session/history object here
//                try await SyncManager.shared.uploadWholeSession(from: session, userId: userId)
//                
//                await MainActor.run {
//                    isUploading = false
//                    // Haptic feedback for successful cloud sync
//                    UINotificationFeedbackGenerator().notificationOccurred(.success)
//                    dismiss()
//                }
//            } catch {
//                await MainActor.run {
//                    isUploading = false
//                    showSyncError = true
//                }
//            }
//        }
    }
    
    private func handleLocalSave() {
        // 1. Process and save the workout history
        finishWorkoutSession()
        
        // 2. Reset the exercises so the session is fresh for next time
        for exercise in session.exercises {
            exercise.isCompleted = false
        }
        completedExerciseIds.removeAll()
        try? context.save()
        
        // 3. Trigger haptic feedback for success
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            hasSavedLocally = true
        }
    }

    private func handleCloudUpload() {
        // Look at the network monitor directly instead of a local 'isOnline' state
        guard network.isConnected else { return }
        
        isUploading = true
        
        // Your existing cloud upload logic
        uploadWholeSessionToCloud()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isUploading = false
            dismiss()
        }
    }
    
    private func updateAIWithLiveSessionData() {
        let details = generateSessionContext()
        
        aiManager.updateContext(
            screen: "Active Session \(session.name)",
            details: "User is vieting their full workout session list",
            preferences: details
        )
    }
    
    private func uploadWholeSessionToCloud() {
        guard let userId = auth.user?.uid else { return }
        
        // We use the SyncManager to handle the heavy lifting
        // This ensures consistency across the app
//        SyncManager.shared.uploadAllToCloud(userId: userId, keyScope: keyScope)
        
        // Optional: Trigger Haptic feedback or a toast notification
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // Add this computed property to SessionDetailView to match StrengthEntryView logic
    private var keyScope: DefaultsKeyScope {
        DefaultsKeyScope.from(
            previewUserID: auth.previewUserID,
            liveUserID: auth.user?.uid,
            programID: workoutProgram.id.uuidString,
            sessionID: session.id.uuidString
        )
    }
    
    private func addExercise(named exerciseName: String) {
        let newExercise = Exercise(name: exerciseName)
        session.exercises.append(newExercise)
        
        // Save the updated session back to the workout program
        if let index = workoutProgram.sessions.firstIndex(where: { $0.id == session.id }) {
            workoutProgram.sessions[index] = session
        }
        
        // Save the context to persist changes
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func deleteExercise(withId id: UUID) {
        // Find the specific instance by its unique ID
        if let index = session.exercises.firstIndex(where: { $0.id == id }) {
            let exerciseName = session.exercises[index].name
            
            withAnimation {
                session.exercises.remove(at: index)
                
                // Cleanup per-set keys
                // Note: Since name is used for keys, this cleans up the "Bench Press" defaults.
                // (If you want separate data for duplicate exercises, use .id in the key instead of .name)
                let baseStrengthKeys = ["weight", "left", "right", "reps", "rest"]
                for i in 0..<20 { // Assuming max 20 sets
                    for base in baseStrengthKeys {
                        defaults.removeObject(forKey: keyScope.scoped("\(base)\(exerciseName)_set\(i)"))
                    }
                }
                defaults.removeObject(forKey: keyScope.scoped("sets\(exerciseName)")) // Total sets
                defaults.removeObject(forKey: keyScope.scoped("iso\(exerciseName)")) // ISO flag

                // Cleanup Cardio keys
                defaults.removeObject(forKey: keyScope.scoped("duration\(exerciseName)"))
                defaults.removeObject(forKey: keyScope.scoped("distance\(exerciseName)"))
                defaults.removeObject(forKey: keyScope.scoped("calories\(exerciseName)"))

                // Cleanup Mobility keys
                defaults.removeObject(forKey: keyScope.scoped("holdTime\(exerciseName)"))
                defaults.removeObject(forKey: keyScope.scoped("rounds\(exerciseName)"))
                
                // Common note key
                defaults.removeObject(forKey: keyScope.scoped("note\(exerciseName)"))

                try? context.save()
            }
        }
    }
    
    private func renameSession() {
        // Update the session name
        session.name = newSessionName
        
        // Update the workout program to reflect the changes
        if let programIndex = workoutProgram.sessions.firstIndex(where: { $0.id == session.id }) {
            workoutProgram.sessions[programIndex] = session
        }
        
        // Save the context to persist changes
        do {
            try context.save()
        } catch {
            print("Failed to save context after renaming session: \(error)")
        }
    }
    private func generateSessionContext() -> String {
        var contextString = "Current Session: \(session.name)\n"
        
        for exercise in session.exercises {
            contextString += "\nExercise: \(exercise.name)\n"
            
            let cleanName = exercise.name // Ensure clean name is used for keys

            // Fetch the data from UserDefaults (matches your EntryView keys)
            // CORRECTED: Use keyScope.scoped for consistency
            
            // STRENGTH
            let strengthSets = defaults.integer(forKey: keyScope.scoped("sets\(cleanName)"))
            if strengthSets > 0 {
                contextString += "- Strength Sets: \(strengthSets)\n"
                for i in 0..<strengthSets {
                    let weight = defaults.integer(forKey: keyScope.scoped("weight\(cleanName)_set\(i)"))
                    let reps = defaults.integer(forKey: keyScope.scoped("reps\(cleanName)_set\(i)"))
                    if weight > 0 || reps > 0 {
                        contextString += "  [Set \(i+1)]: \(weight)kg x \(reps) reps\n"
                    }
                }
            }
            
            // CARDIO
            let cardioDuration = defaults.double(forKey: keyScope.scoped("duration\(cleanName)"))
            let cardioDistance = defaults.double(forKey: keyScope.scoped("distance\(cleanName)"))
            let cardioCalories = defaults.integer(forKey: keyScope.scoped("calories\(cleanName)"))
            if cardioDuration > 0 || cardioDistance > 0 || cardioCalories > 0 {
                contextString += "- Cardio: \(String(format: "%.0f", cardioDuration / 60))m, \(String(format: "%.1f", cardioDistance)) mi, \(cardioCalories) kcal\n"
            }
            
            // MOBILITY
            let mobilityHoldTime = defaults.double(forKey: keyScope.scoped("holdTime\(cleanName)"))
            let mobilityRounds = defaults.integer(forKey: keyScope.scoped("rounds\(cleanName)"))
            if mobilityHoldTime > 0 || mobilityRounds > 0 {
                contextString += "- Mobility: \(String(format: "%.0f", mobilityHoldTime))s hold x \(mobilityRounds) rounds\n"
            }

            // NOTE (Common to all, if present)
            let note = defaults.string(forKey: keyScope.scoped("note\(cleanName)")) ?? "No notes"
            contextString += "- Note: \(note)\n"
        }
        return contextString
    }
    
    private func finishWorkoutSession() {
        print("--- Starting finishWorkoutSession for session: \(session.name) ---")
        print("KeyScope for this session: programID=\(workoutProgram.id.uuidString), sessionID=\(session.id.uuidString), userID=\(auth.user?.uid ?? auth.previewUserID ?? "guest_id")")

        // 1. Get User ID (handle both Firebase and Preview states)
        let userId = auth.user?.uid ?? auth.previewUserID ?? "guest_id"
        let sessionDate = Date()
        
        // 2. Create the Master Record
        let completedSession = CompletedSession(
            date: sessionDate,
            userId: userId,
            programTitle: workoutProgram.title,
            sessionName: session.name
        )
        
        // 3. Loop through your live session exercises
        for exercise in session.exercises {
            let cleanName = exercise.name
            let note = defaults.string(forKey: keyScope.scoped("note\(cleanName)"))
            print("\nProcessing exercise: \(cleanName)")
            
            // --- STRENGTH ENTRIES ---
            let setCountKey = keyScope.scoped("sets\(cleanName)")
            let setCount = defaults.integer(forKey: setCountKey)
            print("  Strength: Checking key '\(setCountKey)', retrieved setCount: \(setCount)")

            if setCount > 0 {
                let isIsoSessionKey = keyScope.scoped("iso\(cleanName)")
                let isIsoSession = defaults.bool(forKey: isIsoSessionKey)
                print("  Strength: isIsoSession (key: '\(isIsoSessionKey)'): \(isIsoSession)")

                var setRecords: [SetRecord] = []
                
                for i in 0..<setCount {
                    let repsKey = keyScope.scoped("reps\(cleanName)_set\(i)")
                    let combinedKey = keyScope.scoped("weight\(cleanName)_set\(i)")
                    let leftKey = keyScope.scoped("left\(cleanName)_set\(i)")
                    let rightKey = keyScope.scoped("right\(cleanName)_set\(i)")
                    let restKey = keyScope.scoped("rest\(cleanName)_set\(i)")

                    let reps = defaults.integer(forKey: repsKey)
                    let combined = defaults.integer(forKey: combinedKey)
                    let left = defaults.integer(forKey: leftKey)
                    let right = defaults.integer(forKey: rightKey)
                    let rest = defaults.integer(forKey: restKey)
                    
                    print("    Set \(i+1): Reps(key:'\(repsKey)')=\(reps), Combined(key:'\(combinedKey)')=\(combined), Left(key:'\(leftKey)')=\(left), Right(key:'\(rightKey)')=\(right), Rest(key:'\(restKey)')=\(rest)")
                    
                    // Only save the set if there is actual data
                    if reps > 0 || combined > 0 || left > 0 || right > 0 {
                        let record = SetRecord(
                            id: UUID(),
                            combined: combined,
                            left: left,
                            right: right,
                            reps: reps,
                            rest: rest
                        )
                        setRecords.append(record)
                    } else {
                        print("    Set \(i+1) has no data, skipping.")
                    }
                }
                
                // Create StrengthEntry only if there are actual set records
                if !setRecords.isEmpty {
                    let entry = StrengthEntry(
                        exercise: exercise.name,
                        date: sessionDate,
                        sets: setRecords,
                        note: note,
                        iso: isIsoSession
                    )
                    entry.session = completedSession
                    completedSession.strengthEntries.append(entry)
                    print("  Strength: Added StrengthEntry with \(setRecords.count) sets.")
                } else {
                    print("  Strength: No set records found for \(cleanName). StrengthEntry not created.")
                }
            } else {
                print("  Strength: No setCount (>0) found for \(cleanName). Skipping strength entries.")
            }
            
            // --- CARDIO ENTRIES ---
            let durationKey = keyScope.scoped("duration\(cleanName)")
            let distanceKey = keyScope.scoped("distance\(cleanName)")
            let caloriesKey = keyScope.scoped("calories\(cleanName)")

            let duration = defaults.double(forKey: durationKey)
            let distance = defaults.double(forKey: distanceKey)
            let calories = defaults.integer(forKey: caloriesKey)
            
            print("  Cardio: Duration(key:'\(durationKey)')=\(duration), Distance(key:'\(distanceKey)')=\(distance), Calories(key:'\(caloriesKey)')=\(calories)")

            if duration > 0 || distance > 0 || calories > 0 {
                let cardioEntry = CardioEntry(
                    exercise: exercise.name,
                    date: sessionDate,
                    duration: duration,
                    distance: distance == 0 ? nil : distance, // Set to nil if 0 for consistency
                    calories: calories == 0 ? nil : calories, // Set to nil if 0 for consistency
                    note: note
                )
                cardioEntry.session = completedSession
                completedSession.cardioEntries.append(cardioEntry)
                print("  Cardio: Added CardioEntry.")
            } else {
                print("  Cardio: No data found for \(cleanName). Skipping cardio entry.")
            }
            
            // --- MOBILITY ENTRIES ---
            let holdTimeKey = keyScope.scoped("holdTime\(cleanName)")
            let roundsKey = keyScope.scoped("rounds\(cleanName)")

            let holdTime = defaults.double(forKey: holdTimeKey)
            let rounds = defaults.integer(forKey: roundsKey)
            
            print("  Mobility: HoldTime(key:'\(holdTimeKey)')=\(holdTime), Rounds(key:'\(roundsKey)')=\(rounds)")

            if holdTime > 0 || rounds > 0 {
                let mobilityEntry = MobilityEntry(
                    exercise: exercise.name,
                    date: sessionDate,
                    holdTime: holdTime,
                    rounds: rounds,
                    note: note
                )
                mobilityEntry.session = completedSession
                completedSession.mobilityEntries.append(mobilityEntry)
                print("  Mobility: Added MobilityEntry.")
            } else {
                print("  Mobility: No data found for \(cleanName). Skipping mobility entry.")
            }
        }
        
        // 4. Save to SwiftData if ANY entries were recorded
        if !completedSession.strengthEntries.isEmpty ||
           !completedSession.cardioEntries.isEmpty ||
           !completedSession.mobilityEntries.isEmpty {
            
            context.insert(completedSession)
            
            do {
                try context.save()
                print("--- Successfully logged: \(session.name) with \(completedSession.strengthEntries.count) strength, \(completedSession.cardioEntries.count) cardio, \(completedSession.mobilityEntries.count) mobility entries. ---")
            } catch {
                print("--- Save Error: \(error) ---")
            }
        } else {
            print("--- No entries recorded for session \(session.name). Not saving to history. ---")
        }
        print("--- finishWorkoutSession completed ---")
    }
    
}



#Preview {
    // Create mock exercises
    let exercises = [
        Exercise(name: "Push Up"),
        Exercise(name: "Squat"),
        Exercise(name: "Lunge")
    ]
    
    // Create a mock session
    let session = Session(name: "Morning Workout", exercises: exercises)
    
    let workoutProgram = WorkoutProgram(title: "Test Program", sessions: [session])
    
    // Pass the mock session to the preview
    SessionDetailView(session: session, workoutProgram: workoutProgram, exercises: exercises)
}

